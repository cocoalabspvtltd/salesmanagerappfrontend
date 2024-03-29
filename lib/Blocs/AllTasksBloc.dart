import 'dart:async';

import 'package:sales_manager_app/Constants/CommonMethods.dart';
import 'package:sales_manager_app/Interfaces/LoadMoreListener.dart';
import 'package:sales_manager_app/Models/AllTaskResponse.dart';
import 'package:sales_manager_app/Repositories/TaskRepository.dart';
import 'package:sales_manager_app/ServiceManager/ApiResponse.dart';

import '../Models/DummyModels/1.dart';

class AllTasksBloc {
  bool hasNextPage = false;
  int pageNumber = -1;
  int perPage = 20;

  TaskRepository tasksRepository;

  StreamController _tasksController;

  StreamSink<ApiResponse<AllTaskResponse>> get employeeListSink =>
      _tasksController.sink;

  Stream<ApiResponse<AllTaskResponse>> get tasksStream =>
      _tasksController.stream;

  List<Todaytask> tasksList = [];

  LoadMoreListener _listener;

  AllTasksBloc(this._listener) {
    tasksRepository = TaskRepository();
    _tasksController = StreamController<ApiResponse<AllTaskResponse>>();
  }

  getAllTasksList(bool isPagination, String status, int salesPerson) async {
    if (isPagination) {
      _listener.refresh(true);
    } else {
      pageNumber = -1;
      employeeListSink.add(ApiResponse.loading('Fetching reports'));
    }
    try {
      AllTaskResponse tasksResponse =
          await tasksRepository.getAllTasksList(
            status,
              pageNumber,
              perPage, salesPerson);
      if (tasksResponse.pagination != null) {
        if (tasksResponse.pagination.hasNextPage != null) {
          hasNextPage = tasksResponse.pagination.hasNextPage;
        }
        if (tasksResponse.pagination.page != null) {
          pageNumber = tasksResponse.pagination.page;
        }
      }
      if (isPagination) {
        if (tasksList.length == 0) {
          tasksList = tasksResponse.data;
          print("object->$tasksList");
        } else {
          tasksList.addAll(tasksResponse.data);
        }
      } else {
        tasksList = tasksResponse.data.cast<Todaytask>();
      }
      employeeListSink.add(ApiResponse.completed(tasksResponse));
      if (isPagination) {
        _listener.refresh(false);
      }
    } catch (error) {
      print("1******");
      print(error.toString());
      print("2******");
      if (isPagination) {
        _listener.refresh(false);
      } else {
        employeeListSink
            .add(ApiResponse.error(CommonMethods().getNetworkError(error)));
      }
    }
  }
  //
  // Future getTreatmentReport() async {
  //   print("dowload");
  //   try {
  //     final treatmentReport = await tasksRepository.get();
  //
  //     return treatmentReport;
  //   } catch (e, s) {
  //     Completer().completeError(e, s);
  //   }
  //   return null;
  // }


  dispose() {
    employeeListSink?.close();
    _tasksController?.close();
  }
}
