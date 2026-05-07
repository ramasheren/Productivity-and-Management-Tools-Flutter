import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoading = true;
  String _filterOption = 'All'; // All, Completed, Pending

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    final tasks = await _dbHelper.retrieveTasks();
    if (!mounted) {
      return;
    }

    setState(() {
      _allTasks = tasks;
      _applyFilter();
      _isLoading = false;
    });
  }

  void _applyFilter() {
    if (_filterOption == 'Completed') {
      _filteredTasks =
          _allTasks.where((task) => task.isCompleted).toList();
    } else if (_filterOption == 'Pending') {
      _filteredTasks =
          _allTasks.where((task) => !task.isCompleted).toList();
    } else {
      _filteredTasks = _allTasks;
    }
  }

  Future<void> _deleteTask(int id) async {
    await _dbHelper.deleteTask(id);
    await _loadTasks();
  }

  Future<void> _toggleTaskComplete(Task task) async {
    await _dbHelper.updateTask(task.copyWith(isCompleted: !task.isCompleted));
    await _loadTasks();
  }

  void _showDeleteConfirmation(int taskId, String taskTitle) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "$taskTitle"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _deleteTask(taskId);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tasks',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filterOption = value;
                _applyFilter();
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'All',
                child: Text('All Tasks'),
              ),
              const PopupMenuItem(
                value: 'Pending',
                child: Text('Pending'),
              ),
              const PopupMenuItem(
                value: 'Completed',
                child: Text('Completed'),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.filter_list),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredTasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.checklist,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No $_filterOption tasks',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _filteredTasks.length,
                  itemBuilder: (context, index) {
                    Task task = _filteredTasks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 0,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              task.priority == 'High'
                                  ? Colors.red
                                  : task.priority == 'Medium'
                                      ? Colors.orange
                                      : Colors.green,
                          child: Text(
                            task.priority[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (task.dueDate != null)
                              Text(
                                'Due: ${task.dueDate}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            if (task.description != null)
                              Text(
                                task.description!.length > 50
                                    ? '${task.description!.substring(0, 50)}...'
                                    : task.description!,
                                style: const TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                        trailing: Checkbox(
                          value: task.isCompleted,
                          onChanged: (value) async {
                            await _toggleTaskComplete(task);
                          },
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/addTask',
                            arguments: task,
                          ).then((_) => _loadTasks());
                        },
                        onLongPress: () {
                          _showDeleteConfirmation(task.id!, task.title);
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addTask').then((_) => _loadTasks());
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
