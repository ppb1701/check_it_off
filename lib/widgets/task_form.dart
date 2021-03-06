import 'dart:io' show Platform;
import 'package:check_it_off/helpers/db.dart';
import 'package:check_it_off/helpers/validator.dart';
import 'package:check_it_off/models/theme_notifier.dart';
import 'package:check_it_off/screens/tasks_screen.dart';
import 'package:check_it_off/widgets/toggle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:check_it_off/models/task.dart';
import 'package:flutter/scheduler.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/Provider.dart';
import 'package:check_it_off/models/task_data.dart';

// import 'package:toggle_switch/toggle_switch.dart';
import 'package:intl/intl.dart';

String taskTitle;

class TaskForm extends StatefulWidget {
  final priority;
  final recurring;
  final interval;
  final addToCalendar;
  final numberOfRecurrences;
  final dueDate;
  final mode;
  final task;
  final index;
  final id;

  TaskForm({
    this.priority,
    this.dueDate,
    this.addToCalendar,
    this.numberOfRecurrences,
    this.interval,
    this.recurring,
    this.mode,
    this.task,
    this.index,
    this.id,
  });

  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  String _selectedPriority;
  String _selectedRecurring;
  String _selectedInterval;
  String _selectedAddToCalendar;
  int _selectedNumberOfRecurrences;
  var initialDate;

  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  refresh() {
    setState(() {});
  }

  void initState() {
    super.initState();
    taskTitle = widget.task != null ? widget.task.name : '';
    _selectedPriority =
        widget.priority.toString().replaceAll('priorityLevel.', '');
    _selectedRecurring = widget.recurring;
    _selectedInterval =
        widget.interval.toString().replaceAll('recurrenceInterval.', '');
    _selectedAddToCalendar = widget.addToCalendar;
    _selectedNumberOfRecurrences = widget.numberOfRecurrences;
    initialDate = (widget.dueDate != null
        ? (widget.dueDate != ''
            ? DateTime.parse(widget.dueDate)
            : DateTime.now())
        : DateTime.now());
    DateFormat formatter = DateFormat('MM/dd/yyyy');
    _setDate = initialDate.toString();
    finaldate = formatter.format(initialDate);
    _showRecurranceOptions = true;
    // = widget.dueDate != null
    //     ? (widget.dueDate != ''
    //     ? true : false) : false;
    // _showRecurranceFrequencyOptions = widget.dueDate != null
    // ? (widget.dueDate != ''
    // ? true : false) : false;
  }

  bool _showRecurranceOptions = false;
  bool _showRecurranceFrequencyOptions = false;
  var finaldate;
  String _setDate;

  bool isDarkMode() {
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;
    return darkModeOn;
  }

  List<Task> _tasks = [];
  List<String> priorityList = ['High', 'Normal', 'Low'];
  List<String> yesNoList = ['Yes', 'No'];
  List<String> recurringIntervalList = ['Daily', 'Weekly', 'Monthly', 'None'];

  NumberPicker integerNumberPicker;

  void callDatePicker() async {
    var order = await getDate();
    setState(() {
      if (order != null) {
        DateFormat formatter = DateFormat('MM/dd/yyyy');
        finaldate = formatter.format(order);
        initialDate = order;
        _setDate = order.toString();
        _showRecurranceOptions = true;
      }
    });
  }

  Future<DateTime> getDate() {
    // Imagine that this function is
    // more complex and slow.
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2018),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: Provider.of<ThemeNotifier>(context)
                  .getCurrentTheme()
                  .contains('dark')
              ? ThemeData.dark()
              : ThemeData.light(),
          child: child,
        );
      },
    );
  }

  Future _showIntDialog() async {
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer(
          minValue: 0,
          maxValue: 25,
          step: 1,
          initialIntegerValue: _selectedNumberOfRecurrences,
        );
      },
    ).then((num value) {
      if (value != null) {
        setState(() => _selectedNumberOfRecurrences = value);
        integerNumberPicker.animateInt(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
          key: _formKey,
      child: Container(
        color: isDarkMode() ? Color(0xFF212121) : Color(0xff757575),
        child: Container(
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: isDarkMode() ? Colors.black : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                widget.mode.toString().contains('add') ? 'Add Task' : 'Edit Task',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30.0,
                  // color: Colors.lightBlueAccent,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              ),
              Column(
                children: [
                  Text(
                    'Name',
                    style: TextStyle(fontSize: 25.0),
                  ),
                  TextFormField(
                    initialValue: widget.mode == 'add' ? '' : widget.task.name,
                    style:
                        TextStyle(fontSize: 20.0, color: Colors.lightBlueAccent),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    autofocus: true,
                    textAlign: TextAlign.center,
                    onChanged: (newText) {
                      taskTitle = newText;
                    },
                    validator: FieldValidator.validateLength,
                  ),
                ],
              ),
              Toggle("Priority", priorityList, (index) {
                _selectedPriority = priorityList[index];
              }, priorityList.indexOf(_selectedPriority)),
              new FlatButton(
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(15.0)),
                onPressed: callDatePicker,
                color: Colors.lightBlueAccent,
                child:
                    new Text('Due Date', style: TextStyle(color: Colors.white)),
              ),
              Center(
                child: Container(
                  // decoration: BoxDecoration(color: Colors.grey[200]),
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: finaldate == null
                      ? Text(
                          "",
                          textScaleFactor: 2.0,
                        )
                      : Text(
                          "$finaldate",
                          textScaleFactor: 2.0,
                        ),
                ),
              ),
              _showRecurranceOptions
                  ? Toggle("Recurring", recurringIntervalList, (index) {
                      setState(() {
                        _selectedInterval = recurringIntervalList[index];
                        _selectedNumberOfRecurrences =
                            _selectedInterval.toString().contains('None') ? 0 : 1;
                        _selectedRecurring =
                            _selectedInterval.toString().contains('None')
                                ? 'No'
                                : 'Yes';
                        // _showRecurranceFrequencyOptions =
                        if (finaldate == '') {
                          if (!_selectedInterval.contains('None')) {
                            DateFormat formatter = DateFormat('MM/dd/yyyy');
                            DateTime order = DateTime.now();
                            finaldate = formatter.format(order);
                            initialDate = order;
                            _setDate = order.toString();
                          }
                        }
                        _selectedInterval.contains('None') ? false : true;
                      });
                    }, recurringIntervalList.indexOf(_selectedInterval))
                  : Container(),
              // _showRecurranceOptions && _showRecurranceFrequencyOptions
              //     ? Container(
              //   // height: 150.0,
              //   alignment: Alignment.center,
              //   // color: Colors.lightBlueAccent,
              //   // child: Platform.isIOS ? iOSPicker() : androidDropdown(),
              //   child: Padding(
              //     padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              //     child: Column(
              //       children: [
              //         Text('Frequency Interval',
              //             style: TextStyle(fontSize: 25.0,)),
              //         Text('(Every x Days/Weeks/Months)',
              //             style: TextStyle(fontSize: 25.0,)),
              //         new FlatButton(
              //           color: Colors.lightBlueAccent,
              //           shape: new RoundedRectangleBorder(
              //               borderRadius: new BorderRadius.circular(15.0)),
              //           onPressed: () => _showIntDialog(),
              //           child: new Text(
              //             _selectedNumberOfRecurrences.toString(),
              //             style: TextStyle(
              //               color: Colors.white,
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // )
              //     : Container(),
              FlatButton(
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(15.0)),
                child: Text(
                  widget.mode.toString().contains('add')
                      ? 'Add Task'
                      : 'Edit Task',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                color: Colors.lightBlueAccent,
                onPressed: widget.mode.toString().contains('add')
                    ? () async {
                        Task t;
                        t = Provider.of<TaskData>(context, listen: false).addTask(
                            newTaskTitle: taskTitle,
                            priority: _selectedPriority,
                            interval: _selectedInterval,
                            dueDate: _setDate,
                            numberOfRecurrences: _selectedNumberOfRecurrences,
                            addToCalendar: (_selectedAddToCalendar.contains('Yes')
                                ? true
                                : false));
                        var db = new DB();
                        final FormState form = _formKey.currentState;
                        if (form.validate()) {
                          dynamic result = await db.insert(t);

                          // await DB.insert(t);

                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => TasksScreen(),
                              transitionDuration: Duration(seconds: 0),
                            ),
                          );
                        }
                      }
                    : () async {
                        Provider.of<TaskData>(context, listen: false).editTask(
                          theTaskTitle:
                              taskTitle == null ? widget.task.name : taskTitle,
                          index: widget.index,
                          selectedPriority: _selectedPriority,
                          interval: _selectedInterval,
                          numberOfRecurrences: _selectedNumberOfRecurrences,
                          dueDate: _setDate,
                          addToCalendar:
                              _selectedAddToCalendar == 'Yes' ? true : false,
                        );
                        final FormState form = _formKey.currentState;
                        if (form.validate()) {
                          var db = new DB();
                          Task t = widget.task;
                          t.id = widget.id;
                          dynamic result = await db.update(t);

                          Navigator.pop(context);
                          Navigator.pop(context);
                        }
                      },
              ),
              FlatButton(
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(15.0)),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                color: Colors.lightBlueAccent,
                onPressed: () {
                  Navigator.pop(context);
                  if (widget.mode.toString().contains('add') == false) {
                    Navigator.pop(context);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
