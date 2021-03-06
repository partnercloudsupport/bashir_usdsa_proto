import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdsa_proto/pages/AddEventPage.dart';
import 'package:usdsa_proto/pages/AddNewCommitteePage.dart';
import 'package:usdsa_proto/pages/SettingsPage.dart';
import '../theme.dart';
import 'NewsStream.dart';
import 'ActivityCalendar.dart';
import 'GroupsList.dart';
import 'AddNewsItem.dart';
import 'LoginScreen.dart';
import '../group_options_icons_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:usdsa_proto/UserSingleton.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: "USDSA",
        home: new loginScreen(),
        theme: mainTheme,
    );
  }
}

class usdsaApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new usdsaAppState();
}

class usdsaAppState extends State<usdsaApp>{

  int _currentIndex = 0;
  UserSingleton userSing = new UserSingleton();
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  DateTime timeNOW = DateTime.now();

  @override
  void initState() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((token){
      print("token");
      print(token);
    });
    _firebaseMessaging.subscribeToTopic("/topics/announcements");
    SharedPreferences.getInstance().then((prefs){
      var list = prefs.getStringList('topics');
      userSing.userCommittees.forEach((comm){
        _firebaseMessaging.subscribeToTopic("/topics/"+comm.replaceAll(' ', ''));
        list.add("/topics/"+comm.replaceAll(' ', ''));
      });
      prefs.setStringList('topics', list);
      print(list);
    });

  }


  @override
  Widget build(BuildContext context) {
    return scaffoldCreator();
  }


  Scaffold scaffoldCreator(){

    return new Scaffold(
      appBar: new AppBar(
        centerTitle: false,
        title: titleChoser(),
        actions: actionsBuilder(),
      ),
      body: screenChoser(),
      bottomNavigationBar: new BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(icon: new Icon(GroupOptionsIcons.newspaper), title: new Text("News")),
          new BottomNavigationBarItem(icon: new Icon(Icons.calendar_today), title: new Text("Calendar")),
          new BottomNavigationBarItem(icon: new Icon(GroupOptionsIcons.group), title: new Text("Committees")),
          new BottomNavigationBarItem(icon: new Icon(Icons.settings), title: new Text("Settings")),
        ],
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (int index){
          setState(() {
            _currentIndex = index;
          });
        },

      ),

    );
  }

  List<Widget> actionsBuilder(){
    switch(_currentIndex){
      case 0:{
        if (userSing.userPriority == '2') {
          return <Widget>[
            new IconButton(icon: Icon(Icons.add), onPressed: (){
              Navigator.push(
                context,
                new MaterialPageRoute(builder: (context) => new AddNewsItemPage()),
              );
            }),
          ];
        }
        else{
          return <Widget>[];
        }
      }
      break;
      case 1:{
        if (userSing.userPriority == '2') {
          return <Widget>[
            new IconButton(icon: Icon(Icons.add), onPressed: (){
              Navigator.push(
                context,
                new MaterialPageRoute(builder: (context) => new AddEventPage()),
              ).then((val){
                setState(() {
                  timeNOW = DateTime.now();
                });
              });
            }),
          ];
        }
        else{
          return <Widget>[];
        }
      }
      break;
      case 2:{
        return <Widget>[
          new IconButton(icon: Icon(Icons.edit), onPressed: (){
            Navigator.push(
              context,
              new MaterialPageRoute(builder: (context) => new AddNewCommitteePage()),
            );
          }),
        ];
      }
      break;
      case 3:{
        return <Widget>[
          new IconButton(icon: Icon(Icons.exit_to_app), onPressed: (){
            SharedPreferences.getInstance().then((prefs){
              var list = prefs.getStringList('topics');
              print(list);
              list.forEach((topic){
                _firebaseMessaging.unsubscribeFromTopic(topic);
              });
              list.clear();
              prefs.setStringList('topics', list);
              prefs.setBool('authed', null);
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                new MaterialPageRoute(builder: (context) => new loginScreen()),
              );
            });

          }),
        ];
      }
      break;
      default: {
        return [];
      }
      break;
    }
  }

  Text titleChoser(){
    switch(_currentIndex){
      case 0:{
        return Text('Announcements');
      }
      break;
      case 1: {
        return Text('Events Calendar');
      }
      break;
      case 2: {
        return Text("My Committees");
      }
      break;
      case 3: {
        return Text("Settings");
      }
      break;
      default: {
        return new Text("default error");
      }
      break;
    }
  }

  Widget screenChoser(){
    switch(_currentIndex){
      case 0:{
        return new newsStreamBuilder();
      }
      break;
      case 1: {
        print(timeNOW);
        return new activityCalendarBuilder(now: timeNOW,);
      }
      break;
      case 2: {
        return new groupsListBuilder();
      }
      break;
      case 3: {
        return new SettingPage();
      }
      break;
      default: {
        return new Text("default error");
      }
      break;
    }
  }


}





