import 'package:flutter/material.dart';
import 'database_helper.dart';
class TaskManager extends StatefulWidget {
  const TaskManager({super.key});

  @override
  State<TaskManager> createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
   final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _tasks = [];

  Future<void> _fetchTasks() async {
    final tasks = await DBHelper().getTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  Future<void> _addTask(String title) async {
    if (title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task title can't be empty")),
      );
      return;
    }
    await DBHelper().insertTask(title);
    _controller.clear();
    _fetchTasks();
  }

  Future<void> _toggleTask(int id, int isCompleted) async {
    await DBHelper().updateTask(id, isCompleted);
    _fetchTasks();
  }

  Future<void> _confirmDeleteTask(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Task"),
        content: const Text("Are you sure you want to delete this task?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await DBHelper().deleteTask(id);
      _fetchTasks();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'New Task',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _addTask(_controller.text),
                  child: const Icon(Icons.add),
                )
              ],
            ),
          ),
          Expanded(
            child: _tasks.isEmpty
                ? const Center(child: Text('No tasks added yet.'))
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return Dismissible(
                        key: Key(task['id'].toString()),
                        direction: DismissDirection.startToEnd,
                        confirmDismiss: (_) => _confirmDeleteTask(task['id']),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: task['isCompleted'] == 1,
                            onChanged: (val) => _toggleTask(
                                task['id'], val! ? 1 : 0),
                          ),
                          title: Text(
                            task['title'],
                            style: TextStyle(
                              decoration: task['isCompleted'] == 1
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
