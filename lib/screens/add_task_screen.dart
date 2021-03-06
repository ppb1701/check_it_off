import 'package:check_it_off/widgets/task_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

String newTaskTitle;

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TaskForm(
      priority: 'Normal',
      recurring: 'No',
      interval: 'None',
      addToCalendar: 'No',
      numberOfRecurrences: 0,
      mode: 'add',
      task: null,
    );
  }
}
