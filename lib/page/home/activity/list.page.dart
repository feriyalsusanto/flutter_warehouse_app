import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:pina_warehouse/entity/activity_entity.dart';
import 'package:pina_warehouse/service/firebase_firestore_service.dart';

import 'detail.page.dart';

class ActivityListPage extends StatefulWidget {
  @override
  _ActivityListPageState createState() {
    return _ActivityListPageState();
  }
}

class _ActivityListPageState extends State<ActivityListPage>
    with SingleTickerProviderStateMixin {
  GlobalKey<ScaffoldState> key = GlobalKey();
  List<Activity> activities;
  List<Activity> filterActivity;

  FirebaseFirestoreService db = new FirebaseFirestoreService();

  StreamSubscription<QuerySnapshot> activitySub;

  DateTime _minDate;
  DateTime _maxDate;

  @override
  void initState() {
    activities = new List();
    filterActivity = new List();

    activitySub?.cancel();
    activitySub = db.getActivityList().listen((QuerySnapshot snapshot) {
      final List<Activity> activities = snapshot.documents
          .map((documentSnapshot) => Activity.fromMap(
              documentSnapshot.data, documentSnapshot.documentID))
          .toList();

      setState(() {
        this.activities = activities;
        filterActivity = activities;
      });
    });

    DateTime currentDate = DateTime.now();
    _minDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day, 0, 0);
    _maxDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day, 0, 0);

    super.initState();
  }

  @override
  void dispose() {
    activitySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: <Widget>[
                Text('Pilih Tanggal: '),
                FlatButton(
                  onPressed: () {
                    showDatePickerDialog(0);
                  },
                  child: Text(parseDateTime(_minDate)),
                ),
                Container(
                  height: 1.0,
                  width: 10.0,
                  color: Colors.black,
                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                ),
                FlatButton(
                  onPressed: () {
                    showDatePickerDialog(1);
                  },
                  child: Text(parseDateTime(_maxDate)),
                )
              ],
            ),
          ),
          Container(
              padding: EdgeInsets.all(8.0),
              child: ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return showActivity(filterActivity[index]);
                  },
                  itemCount: filterActivity.length))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ActivityDetailPage();
          }));

          setState(() {});
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget showActivity(Activity activity) {
    var item = InkWell(
      child: new Card(
        child: new Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(
                  parseDateTime(DateTime.parse(activity.date), time: true),
                  style: new TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
                new Text(
                  activity.supplierName,
                  style: new TextStyle(
                      fontSize: 16.0, color: Colors.lightBlueAccent),
                ),
                new Text(
                  '${activity.product.length} Produk',
                  style: new TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0)),
      ),
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ActivityDetailPage(
            activity: activity,
          );
        }));

        setState(() {});
      },
    );

    return item;
  }

  showDatePickerDialog(int type) {
    DatePicker.showDatePicker(context,
        showTitleActions: true, currentTime: type == 0 ? _minDate : _maxDate,
        onConfirm: (DateTime date) {
      DateTime tempDate = type == 0 ? _minDate : _maxDate;
      if (type == 0)
        _minDate = date;
      else
        _maxDate = date;

      if (_minDate.isBefore(_maxDate) || _minDate.isAtSameMomentAs(_maxDate)) {
        setState(() {});
      } else {
        type == 0 ? _minDate = tempDate : _maxDate = tempDate;
        showMessage('Filter tanggal tidak valid');
      }
    });
  }

  String parseDateTime(DateTime dateTime, {bool time = false}) {
    String day = dateTime.day.toString();
    if (dateTime.day < 10) day = '0${dateTime.day}';

    String month = dateTime.month.toString();
    if (dateTime.month < 10) month = '0${dateTime.month}';

    String hour = dateTime.hour.toString();
    if (dateTime.hour < 10) hour = '0${dateTime.hour}';

    String minute = dateTime.minute.toString();
    if (dateTime.minute < 10) minute = '0${dateTime.minute}';

    if (time) {
      return '$day-$month-${dateTime.year} $hour:$minute';
    }
    return '$day-$month-${dateTime.year}';
  }

  void showMessage(String message, [Color messageColors = Colors.blue]) {
    key.currentState.showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: messageColors,
    ));
  }

  void showLoading() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            child: Container(
              height: 64.0,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text("Update Data. . ."),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
