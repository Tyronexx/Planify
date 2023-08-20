import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:planify/services/notification_services.dart';
import 'package:planify/ui/add_task_page.dart';
import 'package:planify/ui/theme.dart';
import 'package:planify/ui/widgets/button.dart';
import 'package:planify/ui/widgets/task_tile.dart';

import '../controllers/task_controller.dart';
import '../models/task.dart';
import '../services/theme_services.dart';

// Get.isDarkMode tracks the current saved theme we're on

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //get access to task controller
  final TaskController _taskController = Get.put(TaskController());

  var notifyHelper;
  //Selected Date
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    notifyHelper=NotifyHelper();
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      backgroundColor: context.theme.backgroundColor,
      body: Column(
        children: [
          _addTaskBar(),
          _addDateBar(),
          SizedBox(height: 10,),
          _showTasks(),
        ],
      ),
    );
  }

  _addDateBar(){
    return Container(
      margin: EdgeInsets.only(top: 20, left: 20),
      child: DatePicker(
        DateTime.now(),
        height: 100,
        width: 80,
        initialSelectedDate: DateTime.now(),
        selectionColor: primaryClr,
        selectedTextColor: Colors.white,
        dateTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey
          ),
        ),
        dayTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey
          ),
        ),
        monthTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey
          ),
        ),
        onDateChange: (date){
          //
          setState(() {
            _selectedDate = date;
          });
          print(date);
        },
      ),
    );
  }

  _addTaskBar(){
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.yMMMMd().format(DateTime.now()),
                  style: subHeadingStyle,
                ),
                Text(
                  "Today",
                  style: headingStyle,
                )
              ],
            ),
          ),
          MyButton(
            label: "+ Add Task",
            onTap: () async {
            await Get.to(AddTaskPage());
            //refresh list after coming to new page
              _taskController.getTasks();
            },
          )
        ],
      ),
    );
  }

  _appBar(){
    return AppBar(
      backgroundColor: context.theme.backgroundColor,
      elevation: 0,
      leading: GestureDetector(
        onTap: (){
            ThemeServices().switchTheme();
            notifyHelper.displayNotification(
              title: "Theme Changed",
              body: Get.isDarkMode?"Activated Light Theme":"Activated Dark Theme"
            );

            // notifyHelper.scheduledNotification();
        },
        child: Icon( Get.isDarkMode? Icons.wb_sunny_outlined : Icons.nightlight_round,
          size: 25,
          color: Get.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      actions: [
        CircleAvatar(
          backgroundImage: AssetImage(
            "assets/images/profile.png"
          ),
        ),
        SizedBox(width: 20,)
      ],
    );
  }

  //todo
  _showTasks(){
    return Expanded(
        //observable list (so we use 'OBX')
        child: Obx(() {
          return ListView.builder(
            itemCount: _taskController.taskList.length,
              itemBuilder: (_, index){
                //Individual task instance
                Task task = _taskController.taskList[index];
                // print(task.toJson());

                //We want to show task list items based on 'date' and 'repeat' fields
                if(task.repeat=='Daily'){
                ///  Show notification based on start time
                  //Format startTime to date object(i.e remove AM/PM)

                  //todo
                  // DateTime date = DateFormat.jm().parse(task.startTime.toString());
                  // var myTime = DateFormat("HH:mm").format(date);  //returns time without AM/PM (11:00)
                  // print(myTime);

                  //notifyHelper.scheduledNotification(
                    // split the time into hour and minutes then convert to integer
                    //int.parse(myTime.toString().split(":")[0]),  //hour
                    //int.parse(myTime.toString().split(":")[1]), //minutes
                    //task
                  //);

                /// If repeat is 'daily', show task everyday
                  return AnimationConfiguration.staggeredList(
                      position: index,
                      child: SlideAnimation(
                        child: FadeInAnimation(
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: (){
                                  print("Tapped");
                                  _showBottomSheet(context, task);
                                },
                                child: TaskTile(task),
                              ),
                            ],
                          ),
                        ),
                      )
                  );
                }
                ///show task list based on date selected (i.e date assigned to task equals selected date)
                if(task.date==DateFormat.yMd().format(_selectedDate)){
                  return AnimationConfiguration.staggeredList(
                      position: index,
                      child: SlideAnimation(
                        child: FadeInAnimation(
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: (){
                                  print("Tapped");
                                  _showBottomSheet(context, task);
                                },
                                child: TaskTile(task),
                              ),
                            ],
                          ),
                        ),
                      )
                  );
                }else{
                  return Container();
                }

                return AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: (){
                                print("Tapped");
                                _showBottomSheet(context, task);
                              },
                              child: TaskTile(task),
                            ),
                          ],
                        ),
                      ),
                    )
                );
          });
        }),
    );
  }

  _showBottomSheet(BuildContext context, Task task){
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(top: 4),
        // height of bottom sheet is determinde by isCompleted boolean. If task is completed, we want a shorter bottom sheet else we want a longer one
        height: task.isCompleted==1?
        MediaQuery.of(context).size.height*0.24:
        MediaQuery.of(context).size.height*0.32,
        color: Get.isDarkMode?darkGreyClr:Colors.white,
        child: Column(
          children: [
            Container(
              height: 6,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Get.isDarkMode?Colors.grey[600]:Colors.grey[300]
              ),
            ),
            Spacer(),
            //show first button based on if isCompleted is true or not
            task.isCompleted==1
            ?Container()
            : _bottomSheetButton(
            label: 'Task Completed',
            onTap: (){
              _taskController.markTaskCompleted(task.id!);
              Get.back();
            },
            clr: primaryClr,
            context: context
            ),

            _bottomSheetButton(
                label: 'Delete Task',
                onTap: (){
                  _taskController.delete(task);
                  // refresh to get new list state
                  // _taskController.getTasks();
                  Get.back();
                },
                clr: Colors.red[300]!,
                context: context
            ),
            SizedBox(height: 20,),
            _bottomSheetButton(
                label: 'Close',
                onTap: (){
                  Get.back();
                },
                clr: Colors.red[300]!,
                isClose: true,
                context: context,
            ),
            SizedBox(height: 15,)
          ],
        ),
      ),
    );
  }

  _bottomSheetButton({required String label, required Function()? onTap, required Color clr, bool isClose=false, required BuildContext context}){
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        height: 55,
        width: MediaQuery.of(context).size.width*0.9,
        decoration: BoxDecoration(
          color: isClose==true?Colors.transparent:clr,
          border: Border.all(
            width: 2,
            color: isClose==true?Get.isDarkMode?Colors.grey[600]!:Colors.grey[300]!:clr
          ),
          borderRadius: BorderRadius.circular(20)
        ),
        child: Center(
            child: Text(
                label,
              style: isClose?titleStyle:titleStyle.copyWith(color: Colors.white),
            ),
        ),
      ),
    );
  }

}
