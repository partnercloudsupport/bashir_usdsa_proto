

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:usdsa_proto/UserSingleton.dart';
//import 'package:qrcode_reader/QRCodeReader.dart';
//import 'package:qr_mobile_vision/qr_mobile_vision.dart';
import 'package:qr_reader/qr_reader.dart';
import 'package:usdsa_proto/q_r_code_icons_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MeetingItem{
  const MeetingItem({
    this.title,
    this.date,
    this.description,
    this.aUsers,
    this.attended,
    this.meetingID,
    this.committeeName,
    this.time,
    this.jUsersCommittee,
  });

  final String title;
  final List<String> aUsers;
  final String date;
  final String description;
  final bool attended;
  final String meetingID;
  final String committeeName;
  final String time;
  final List<String> jUsersCommittee;
}


class MeetingPage extends StatefulWidget{
  MeetingPage({@required this.meetingItem});
  final MeetingItem meetingItem;

  @override
  _meetingPageState createState() => new _meetingPageState();

}

class _meetingPageState extends State<MeetingPage> {
  UserSingleton userSing = new UserSingleton();
  bool dAttended;
  //String mID = "default";
  @override
  void initState() {
    super.initState();
    dAttended = widget.meetingItem.attended;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle = theme.textTheme.headline.copyWith(color: Colors.black);
    final TextStyle subStyle = theme.textTheme.body1.copyWith(fontSize: 22.0);
    return new Scaffold(
        appBar: new AppBar(
        title: Text(widget.meetingItem.title), 
        actions: userSing.userPriority == '2' ? <Widget>[
          new IconButton(icon: Icon(QRCodeIcons.qrcode), onPressed: () => showQRDialog()),
          new IconButton(icon: Icon(Icons.delete), onPressed: () => deleteMeeting())
        ] : null,
        ),
        body: new SafeArea(
          top: false,
          bottom: false,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            children :<Widget>[
              Container(
              padding: EdgeInsets.all(16.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: new Text("Description", style: titleStyle,),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: new Text(widget.meetingItem.description),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0),
                    decoration: BoxDecoration(
                      border: new Border.all(color: Colors.black54, width: 2.0),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(bottom: 4.0),
                          child: Row(children: <Widget>[
                            new Text("Date & Time", style: titleStyle,),
                          ],
                          ),
                        ),
                        Container(
                          child: new Text(widget.meetingItem.date + ' ' + widget.meetingItem.time),
                          padding: EdgeInsets.only(bottom: 8.0),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16.0),
                    decoration: BoxDecoration(
                      border: new Border.all(color: Colors.black54, width: 2.0),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    padding: EdgeInsets.only(top: 16.0, bottom: 16.0, left: 8.0, right: 8.0),
                    child: dAttended ?
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text("Meeting Attended", style: titleStyle,),
                        new Icon(Icons.check)
                      ],
                    ):
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text("Attend Meeting", style: titleStyle,),
                        new IconButton(
                            icon: Icon(QRCodeIcons.qr_scan, size: 52.0,),
                            onPressed: (){
                              attendMeeting();
                            },
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
              Container(
                padding: EdgeInsets.only(left: 16.0, bottom: 4.0),
                child: new Text("Attendees", style: titleStyle,),
              ),
            new StreamBuilder(
                stream: Firestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: new CircularProgressIndicator());
                  List<DocumentSnapshot> filtered = snapshot.data.documents;
                  filtered.removeWhere((ds){
                    return !widget.meetingItem.jUsersCommittee.contains(ds.documentID);
                  });
                  return Expanded(
                    child: Scrollbar(
                      child: ListView.builder(
                        itemCount: filtered.length,
                          itemExtent: 40.0,
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          itemBuilder: (context, index) {
                            bool uAttended = widget.meetingItem.aUsers.contains(filtered.elementAt(index).documentID);
                            return ListTile(
                              leading: uAttended ? Icon(Icons.check_box, color: theme.primaryColor,) : Icon(Icons.check_box_outline_blank, color: theme.primaryColor,),
                              title: new Text(filtered.elementAt(index)['fname'] + ' ' + filtered.elementAt(index)['lname']),
                            );
                          }
                      ),
                    ),
                  );
                }
            ),

            ]
          ),
        ),
    );
  }

  deleteMeeting(){
    final ios = Theme.of(context).platform == TargetPlatform.iOS;
    showDialog(context: context, builder: (BuildContext context){
      if(!ios){
        return new AlertDialog(
          title: new Text("Delete Meeting"),
          content: new Text("Are you sure you would like to delete this meeting?"),
          actions: <Widget>[
            new FlatButton(onPressed: (){
              Navigator.of(context).pop();
            },
                child: new Text("Cancel")
            ),
            new FlatButton(onPressed: ()async {
              showDialog(context: context,
                  barrierDismissible: false,
                  builder: (context){
                    return Center(
                      child: Container(child: new CircularProgressIndicator()
                      ),
                    );
                  }
              );
              await Firestore.instance
                  .collection('committees')
                  .document(widget.meetingItem.committeeName)
                  .collection('meetings')
                  .document(widget.meetingItem.meetingID)
                  .delete();
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            },
              child: new Text("Delete"),
              textColor: Colors.red,
            ),
          ],
        );
      }else{
        return new CupertinoAlertDialog(
          title: new Text("Delete Meeting"),
          content: new Text("Are you sure you would like to delete this meeting?"),
          actions: <Widget>[
            new CupertinoDialogAction(
              child: new Text("Cancel"),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
            new CupertinoDialogAction(
              child: new Text("Delete"),
              isDestructiveAction: true,
              onPressed: ()async {
                showDialog(context: context,
                    barrierDismissible: false,
                    builder: (context){
                      return Center(
                        child: Container(child: new CircularProgressIndicator()
                        ),
                      );
                    }
                );
                await Firestore.instance
                    .collection('committees')
                    .document(widget.meetingItem.committeeName)
                    .collection('meetings')
                    .document(widget.meetingItem.meetingID)
                    .delete();
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              },
            )
          ],
        );
      }
    }).whenComplete((){

    });

  }

  showQRDialog(){
    showDialog(context: context,
        barrierDismissible: true,
        builder: (context){
          return Center(
            child: Container(
              width: 210.0,
              height: 210.0,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: new QrImage(
                data: widget.meetingItem.meetingID,
                size: 200.0,
              ),
            ),
          );
        }
    );
  }
  attendMeeting()async {
      //String futureString = await new QRCodeReader().scan();
    String futureString = await QRCodeReader().scan();
    print(futureString);
    if(futureString == widget.meetingItem.meetingID){
      Map<String, dynamic> dataMap = new Map<String, dynamic>();
      widget.meetingItem.aUsers.add(userSing.userID);
      dataMap['aUsers'] = widget.meetingItem.aUsers;

      await Firestore.instance
          .collection('committees')
          .document(widget.meetingItem.committeeName)
          .collection('meetings')
          .document(widget.meetingItem.meetingID)
          .setData(dataMap, merge: true);
      setState(() {
        dAttended = true;
        //mID = futureString;
      });
    }

  }
}