import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/task.dart';
import '../widgets/task_form.dart';
import '../widgets/task_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  // Đọc danh sách task từ bộ nhớ
  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();

    final String? tasksData = prefs.getString('tasks');

    if (tasksData == null) {
      return;
    }

    final List<dynamic> jsonList = jsonDecode(tasksData);

    setState(() {
      tasks.clear();

      tasks.addAll(
        jsonList.map(
              (json) => Task.fromJson(json),
        ),
      );
    });
  }

  // Lưu danh sách task vào bộ nhớ
  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();

    final String tasksData = jsonEncode(
      tasks.map((task) => task.toJson()).toList(),
    );

    await prefs.setString('tasks', tasksData);
  }

  void addTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return TaskForm(
          onSave: (title, dueDate) {
            setState(() {
              tasks.add(
                Task(
                  id: DateTime.now()
                      .millisecondsSinceEpoch
                      .toString(),
                  title: title,
                  dueDate: dueDate,
                ),
              );
            });

            saveTasks();
          },
        );
      },
    );
  }

  void editTask(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return TaskForm(
          task: task,
          onSave: (title, dueDate) {
            setState(() {
              task.title = title;
              task.dueDate = dueDate;
            });

            saveTasks();
          },
        );
      },
    );
  }

  void deleteTask(Task task) {
    setState(() {
      tasks.remove(task);
    });

    saveTasks();
  }

  void toggleTask(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });

    saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nhiệm vụ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: tasks.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checklist_rounded,
              size: 70,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Chưa có nhiệm vụ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Nhấn + để tạo nhiệm vụ đầu tiên',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];

          return TaskItem(
            task: task,
            onToggle: () {
              toggleTask(task);
            },
            onEdit: () {
              editTask(task);
            },
            onDelete: () {
              deleteTask(task);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}