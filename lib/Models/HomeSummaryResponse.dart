import 'TaskItem.dart';

class HomeSummaryResponse {
  int status;
  String message;
  bool success;
  String date;
  CountsInfo countsInfo;
  List<TaskItem> todaysTask;
  int todaysCount;

  HomeSummaryResponse(
      {this.status,
        this.message,
        this.success,
        this.date,
        this.countsInfo,
        this.todaysTask,
        this.todaysCount});

  HomeSummaryResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    success = json['success'];
    date = json['date'];
    countsInfo = json['data'] != null
        ? new CountsInfo.fromJson(json['data'])
        : null;
    if (json['todaytask'] != null) {
      todaysTask = [];
      json['todaytask'].forEach((v) {
        todaysTask.add(new TaskItem.fromJson(v));
      });
    }
    todaysCount = json['todaysCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['success'] = this.success;
    data['date'] = this.date;
    if (this.countsInfo != null) {
      data['data'] = this.countsInfo.toJson();
    }
    if (this.todaysTask != null) {
      data['todaytask'] = this.todaysTask.map((v) => v.toJson()).toList();
    }
    data['todaysCount'] = this.todaysCount;
    return data;
  }
}

class CountsInfo {
  int completed;
  int pending;
  int rejected;
  int resheduled;

  CountsInfo({this.completed, this.pending, this.rejected, this.resheduled});

  CountsInfo.fromJson(Map<String, dynamic> json) {
    completed = json['completed'] ?? 0;
    pending = json['Pending'] ?? 0;
    rejected = json['Rejected'] ?? 0;
    resheduled = json['Reshedules'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['completed'] = this.completed;
    data['Pending'] = this.pending;
    data['Rejected'] = this.rejected;
    data['Reshedules'] = this.resheduled;
    return data;
  }
}

