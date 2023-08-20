import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:planify/controllers/task_controller.dart';
import 'package:planify/models/task.dart';
import 'package:planify/ui/theme.dart';
import 'package:planify/ui/widgets/button.dart';
import 'package:planify/ui/widgets/input_field.dart';

import '../services/theme_services.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  //get access to task controller
  final TaskController _taskController = Get.put(TaskController());

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _startTime = DateFormat("hh:mm a").format(DateTime.now()).toString();
  String _endTime = "11:30 PM";
  //(default) for remind list
  int _selectedRemind = 5;
  //Drop down remind list
  List<int> remindList = [
    5,
    10,
    15,
    20,
  ];
  //(default) for repeat list
  String _selectedRepeat = "None";
  //Drop down repeat list
  List<String> repeatList = [
    "None",
    "Daily",
    "Weekly",
    "Monthly",
  ];

  // index of selected color
  int _selectedColor = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _appBar(),
      body: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        // SingleChildScrollView so column can scroll up when keyboard pops up
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "Add Task",
                style: headingStyle,
              ),
              MyInputField(title: 'title', hint: "Enter your title", controller: _titleController,),
              MyInputField(title: 'Note', hint: "Enter your note", controller: _noteController,),
              MyInputField(title: 'Date', hint: DateFormat.yMd().format(_selectedDate),
                widget: IconButton(
                  icon: const Icon(
                      Icons.calendar_today_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: (){
                    _getDateFromUser();
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: MyInputField(
                      title: 'Start Time',
                      hint: _startTime,
                      widget: IconButton(
                        icon: const Icon(
                            Icons.access_time_rounded,
                          color: Colors.grey,
                        ),
                        onPressed: (){
                          _getTimeFromUser(isStartTime: true);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12,),
                  Expanded(
                    child: MyInputField(
                      title: 'End Time',
                      hint: _endTime,
                      widget: IconButton(
                        icon: const Icon(
                          Icons.access_time_rounded,
                          color: Colors.grey,
                        ),
                        onPressed: (){
                          _getTimeFromUser(isStartTime: false);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              MyInputField(title: 'Remind', hint: "$_selectedRemind minutes early",
                widget: DropdownButton(
                  underline: Container(height: 0,),
                  onChanged: (String? newValue){
                    setState(() {
                      _selectedRemind = int.parse(newValue!); //convert new value string to int
                    });
                  },
                  icon: const Icon(Icons.keyboard_arrow_down , color: Colors.grey,),
                  iconSize: 32,
                  elevation: 4,
                  style: subTitleStyle,
                  //return a String. Value saved in our list is int
                  items: remindList.map<DropdownMenuItem<String>>((int value){
                    return DropdownMenuItem<String>(
                      value: value.toString(),
                      child: Text(value.toString()),
                    );
                  }).toList(),
                ),
              ),
              MyInputField(title: 'Repeat', hint: "$_selectedRepeat",
                widget: DropdownButton(
                  underline: Container(height: 0,),
                  onChanged: (String? newValue){
                    setState(() {
                      _selectedRepeat = newValue!;
                    });
                  },
                  icon: const Icon(Icons.keyboard_arrow_down , color: Colors.grey,),
                  iconSize: 32,
                  elevation: 4,
                  style: subTitleStyle,
                  //return a String. Value saved in our list is int
                  items: repeatList.map<DropdownMenuItem<String>>((String value){
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(color: Colors.grey),),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _colorPallete(),
                  MyButton(label: "Create Task", onTap: ()=>_validateData()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }




  _appBar(){
    return AppBar(
      backgroundColor: context.theme.backgroundColor,
      elevation: 0,
      leading: GestureDetector(
        onTap: (){
          Get.back();
        },
        child: Icon( Icons.arrow_back_ios_new,
          size: 25,
          color: Get.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      actions: [
        const CircleAvatar(
          backgroundImage: AssetImage(
              "assets/images/profile.png"
          ),
        ),
        const SizedBox(width: 20,)
      ],
    );
  }

  // date picker
  _getDateFromUser() async {
    DateTime? _pickerDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015),
        lastDate: DateTime(2121)
    );

    // save pickerDate to selected date
    if(_pickerDate!=null){
      setState(() {
        _selectedDate=_pickerDate;
      });
    }else{
      print("Something is wrong");
    }

  }

  //time picker
  _getTimeFromUser({required bool isStartTime}) async {
    //isStartTime signifying the start time

    // await cause _showTimePicker() function returns a Future
    var pickedTime = await _showTimePicker();
    String _formatedTime = pickedTime.format(context);

    if(pickedTime==null){
      print("Time cancelled");
    }else if(isStartTime==true){
      setState(() {
        _startTime = _formatedTime;
      });
    }else if(isStartTime==false){
      setState(() {
        _endTime = _formatedTime;
      });
    }

  }
  _showTimePicker(){
    return showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
        context: context,
        initialTime: TimeOfDay(
            hour: int.parse(_startTime.split(":")[0]),
            minute: int.parse(_startTime.split(":")[1].split(" ")[0])
        )
    );
  }

  _colorPallete(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Color",
          style:titleStyle,
        ),
        const SizedBox(height: 8,),
        Wrap(
          children: List<Widget>.generate(
              3,
                  (int index){
                return GestureDetector(
                  onTap: (){
                    setState(() {
                      _selectedColor=index;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CircleAvatar(
                      radius: 14,
                      //determine color based on index
                      backgroundColor: index==0?primaryClr:index==1?pinkClr:yellowClr,
                      // show icon based on selected index
                      child: _selectedColor==index?const Icon(Icons.done, color: Colors.white, size: 16,):Container(),
                    ),
                  ),
                );
              }
          ),
        )
      ],
    );
  }

  //form validation
  _validateData(){
    if(_titleController.text.isNotEmpty&&_noteController.text.isNotEmpty){
      //add to database
      _addTaskToDb();
      Get.back();
    }else if(_titleController.text.isEmpty||_noteController.text.isEmpty){
      Get.snackbar("Required", "All fields are required !",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: pinkClr,
        icon: const Icon(
            Icons.warning_amber_rounded,
          color: Colors.red,
        ),
      );
    }
  }

  _addTaskToDb() async {
    //value is id of inserted item which is passed from insert method (DBHelper)
    int value = await _taskController.addTask(
        task: Task(
          note: _noteController.text,
          title: _titleController.text,
          date: DateFormat.yMd().format(_selectedDate),
          startTime: _startTime,
          endTime: _endTime,
          remind: _selectedRemind,
          repeat: _selectedRepeat,
          color: _selectedColor,
          isCompleted: 0,
        )
    );
    print("My id is " + "$value");
  }


}