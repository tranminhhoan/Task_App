import 'package:flutter/material.dart';

import '../model/task.dart';



class TaskForm extends StatefulWidget {
  final Task? task;
  final Function(String title, DateTime dueDate) onSave;

  const TaskForm({
    super.key,
    this.task,
    required this.onSave,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  late TextEditingController titleController;

  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.task?.title ?? '',
    );

    selectedDate =
        widget.task?.dueDate ?? DateTime.now();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  // Chọn ngày
  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        selectedDate = DateTime(
          date.year,
          date.month,
          date.day,
          selectedDate.hour,
          selectedDate.minute,
        );
      });
    }
  }

  // Chọn giờ
  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        selectedDate,
      ),
    );

    if (time != null) {
      setState(() {
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  // Lưu nhiệm vụ
  void save() {
    final title = titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng nhập tên nhiệm vụ',
          ),
        ),
      );

      return;
    }

    widget.onSave(
      title,
      selectedDate,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom:
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            isEditing
                ? 'Sửa nhiệm vụ'
                : 'Tạo nhiệm vụ',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Tên nhiệm vụ',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.task),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: pickDate,
                  icon: const Icon(
                    Icons.calendar_today,
                  ),
                  label: Text(
                    '${selectedDate.day}/'
                        '${selectedDate.month}/'
                        '${selectedDate.year}',
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: pickTime,
                  icon: const Icon(
                    Icons.access_time,
                  ),
                  label: Text(
                    '${selectedDate.hour.toString().padLeft(2, '0')}:'
                        '${selectedDate.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: save,
              child: Text(
                isEditing
                    ? 'Lưu thay đổi'
                    : 'Tạo nhiệm vụ',
              ),
            ),
          ),
        ],
      ),
    );
  }
}