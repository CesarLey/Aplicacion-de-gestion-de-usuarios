import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final SupabaseClient _client = Supabase.instance.client;
  List<Map<String, dynamic>> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _loading = true);
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        _tasks = [];
        return;
      }

      // Use the Supabase client directly. Different versions of the
      // client may return a List<Map<String,dynamic>> or a
      // PostgrestResponse-like object where the rows are in `.data`.
      final dynamic res = await _client
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .order('id', ascending: false);
      // Debug: print runtime type and some sample content so we can
      // understand what the client returned on the device logs.
      try {
        // ignore: avoid_print
        print('[TasksPage] _loadTasks response type: ${res.runtimeType}');
        if (res is List) {
          // ignore: avoid_print
          print('[TasksPage] _loadTasks rows: ${res.length}');
        } else if (res is Map) {
          // ignore: avoid_print
          print('[TasksPage] _loadTasks keys: ${res.keys.toList()}');
        } else {
          // ignore: avoid_print
          print('[TasksPage] _loadTasks raw: $res');
        }
      } catch (_) {}

      List<Map<String, dynamic>> parsed = [];

      if (res is List) {
        parsed = res.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        // Try to read a `.data` field (PostgrestResponse-like)
        dynamic maybeData;
        try {
          maybeData = (res as dynamic).data;
        } catch (_) {
          maybeData = null;
        }

        if (maybeData is List) {
          parsed = maybeData.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        } else if (res is Map) {
          final d = res['data'];
          if (d is List) {
            parsed = d.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
          } else if (res is Map<String, dynamic>) {
            parsed = [Map<String, dynamic>.from(res)];
          }
        } else {
          parsed = [];
        }
      }

      _tasks = parsed;
    } catch (e) {
      // Print the error and keep _tasks empty so the UI shows the empty
      // state instead of failing silently.
      // ignore: avoid_print
      print('[TasksPage] _loadTasks error: $e');
      _tasks = [];
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _createTask() async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva tarea'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título')),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Crear')),
        ],
      ),
    );

    if (ok != true) return;

    final title = titleCtrl.text.trim();
    final description = descCtrl.text.trim();
    if (title.isEmpty) return;

    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('tasks').insert({
      'title': title,
      'description': description,
      'completed': false,
      'user_id': userId,
    }).select();

    await _loadTasks();
  }

  Future<void> _deleteTask(int id) async {
    await _client.from('tasks').delete().eq('id', id);
    setState(() => _tasks.removeWhere((t) => t['id'] == id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas'),
        actions: [
          IconButton(
            onPressed: () async {
              // Capture navigator before the async gap.
              final navigator = Navigator.of(context);
              await _client.auth.signOut();
              // after sign out, go back to login (pop until root)
              if (!mounted) return;
              navigator.pushReplacementNamed('/');
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTasks,
              child: _tasks.isEmpty
                  ? ListView(children: const [Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No hay tareas')))])
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final t = _tasks[index];
                        return Dismissible(
                          key: Key('task_${t["id"]}'),
                          direction: DismissDirection.endToStart,
                          background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                          onDismissed: (d) async {
                            // Capture messenger before the async gap to avoid using
                            // BuildContext after an await.
                            final messenger = ScaffoldMessenger.of(context);
                            await _deleteTask(t['id'] as int);
                            if (!mounted) return;
                            messenger.showSnackBar(const SnackBar(content: Text('Tarea eliminada')));
                          },
                          child: ListTile(
                            title: Text(t['title'] ?? ''),
                            subtitle: Text(t['description'] ?? ''),
                            trailing: Checkbox(
                              value: t['completed'] == true,
                              onChanged: (v) async {
                                await _client.from('tasks').update({'completed': v}).eq('id', t['id']);
                                await _loadTasks();
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}
