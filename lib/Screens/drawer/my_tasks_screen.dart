import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sales_manager_app/Blocs/AllTasksBloc.dart';
import 'package:sales_manager_app/CustomLibraries/CustomLoader/LinearLoader.dart';
import 'package:sales_manager_app/CustomLibraries/CustomLoader/dot_type.dart';
import 'package:sales_manager_app/Elements/CommonApiErrorWidget.dart';
import 'package:sales_manager_app/Elements/CommonApiLoader.dart';
import 'package:sales_manager_app/Elements/CommonApiResultsEmptyWidget.dart';
import 'package:sales_manager_app/Elements/CommonAppBar.dart';
import 'package:sales_manager_app/Interfaces/LoadMoreListener.dart';
import 'package:sales_manager_app/ServiceManager/ApiResponse.dart';
import 'package:sales_manager_app/widgets/task_list_item.dart';

import '../../Models/AllTaskResponse.dart';
import '../../Models/DummyModels/1.dart';
import '../task_details_screen.dart';

class MyTasksScreen extends StatefulWidget {

  String taskStatusToList;
  String pageHeading;
  
  MyTasksScreen({this.taskStatusToList, this.pageHeading});

  @override
  _MyTasksScreenState createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> with LoadMoreListener {
  bool isLoadingMore = false;
  AllTasksBloc _allTasksBloc;
  ScrollController _tasksController;

  @override
  void initState() {
    super.initState();
    _tasksController = ScrollController();
    _tasksController.addListener(_scrollListener);
    _allTasksBloc = AllTasksBloc(this);
    _allTasksBloc.getAllTasksList(false, widget.taskStatusToList, null);
  }

  @override
  void dispose() {
    _tasksController.dispose();
    _allTasksBloc.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_tasksController.offset >= _tasksController.position.maxScrollExtent &&
        !_tasksController.position.outOfRange) {
      print("reach the bottom");
      if (_allTasksBloc.hasNextPage) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          _allTasksBloc.getAllTasksList(true, widget.taskStatusToList, null);
        });
      }
    }
    if (_tasksController.offset <= _tasksController.position.minScrollExtent &&
        !_tasksController.position.outOfRange) {
      print("reach the top");
    }
  }

  void _errorWidgetFunction() {
    if (_allTasksBloc != null) {
      _allTasksBloc.getAllTasksList(false, widget.taskStatusToList, null);
    }
  }

  void _backPressFunction() {
    print("clicked");
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0), // here the desired height
          child: CommonAppBar(
            text: "My Tasks",
            buttonHandler: _backPressFunction,
          ),
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          alignment: FractionalOffset.topCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: Colors.white,
                  backgroundColor: Colors.cyan,
                  onRefresh: () {
                    return _allTasksBloc.getAllTasksList(false, widget.taskStatusToList, null);
                  },
                  child: StreamBuilder<ApiResponse<AllTaskResponse>>(
                      stream: _allTasksBloc.tasksStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          switch (snapshot.data.status) {
                            case Status.LOADING:
                              return CommonApiLoader();
                              break;
                            case Status.COMPLETED:
                              AllTaskResponse response = snapshot.data.data;
                              print("resp=>$response");
                              return _buildUserWidget(_allTasksBloc.tasksList,
                                  response.pagination?.totalItem);
                              break;
                            case Status.ERROR:
                              return CommonApiErrorWidget(
                                  snapshot.data.message,
                                  _errorWidgetFunction);
                              break;
                          }
                        }
                        return Container(
                          child: Center(
                            child: Text(""),
                          ),
                        );
                      }),
                ),
                flex: 1,
              ),
              Visibility(
                child: Opacity(
                  opacity: 1.0,
                  child: Container(
                    color: Colors.transparent,
                    alignment: FractionalOffset.center,
                    height: 50,
                    child: LinearLoader(
                      dotOneColor: Colors.red,
                      dotTwoColor: Colors.orange,
                      dotThreeColor: Colors.green,
                      dotType: DotType.circle,
                      dotIcon: Icon(Icons.adjust),
                      duration: Duration(seconds: 1),
                    ),
                  ),
                ),
                visible: isLoadingMore ? true : false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  refresh(bool isLoading) {
    if (mounted) {
      setState(() {
        isLoadingMore = isLoading;
      });
      print(isLoadingMore);
    }
  }

  Widget _buildUserWidget(List<Todaytask> tasksList, int totalItemsCount) {
    if (tasksList != null) {
      if (tasksList.length > 0) {
        return ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(10, 15, 10, 50),
            itemCount: tasksList.length,
            controller: _tasksController,
            itemBuilder: (context, index) {
              Todaytask taskItemToPass = tasksList[index];
              return TaskListItem(
                taskItem: taskItemToPass,
                onTap: ()  {
                  viewTaskDetail(taskItemToPass);
                },
              );
            });
      } else {
        return SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(0, 100, 0, 0),
          child: CommonApiResultsEmptyWidget("Results Empty",
              textColorReceived: Colors.black),
        );
      }
    } else {
      return CommonApiErrorWidget("No results found", _errorWidgetFunction,
          textColorReceived: Colors.black);
    }
  }

  void viewTaskDetail(Todaytask taskItemToPass) async{
    Map<String, dynamic> data = await Get.to(() =>
        TaskDetailsScreen(taskId: taskItemToPass.taskid));
    if (data != null && mounted) {
      if (data.containsKey("refreshList")) {
        if (data["refreshList"]) {
          if (_allTasksBloc != null) {
            _allTasksBloc.getAllTasksList(false, widget.taskStatusToList, null);
          }
        }
      }
    }
  }
}
