import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:usdsa_proto/GroupItem.dart';
import 'package:usdsa_proto/pages/GroupInfoPage.dart';
import 'package:usdsa_proto/pages/MeetingsListPage.dart';
import 'GroupsList.dart';
import 'CustomNewsStream.dart';
import '../group_options_icons_icons.dart';

class GroupOption{
  const GroupOption({
    this.optionIcon,
    this.optionName,
    this.description,
  });

  final IconData optionIcon;
  final String optionName;
  final String description;

  bool get isValid => optionIcon != null && optionName != null && description != null;
}

class GroupOptionItemCard extends StatelessWidget{
  GroupOptionItemCard({ Key key, @required this.groupOption, @required this.groupItem })
      : assert(groupOption != null && groupOption.isValid && groupItem != null),
        super(key: key);

  final GroupOption groupOption;
  final GroupItem groupItem;

  static const double height = 110.0;
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle = theme.textTheme.headline.copyWith(color: Colors.black);
    final TextStyle descriptionStyle = theme.textTheme.subhead;
    return new Container(
      height: height,
      child: GestureDetector(
        onTap: (){
          if(groupOption == groupsOptionsList[0]){
            Navigator.push(
              context,
              new MaterialPageRoute(builder: (context) => new customNewsStreamBuilder(
                  committeeName: groupItem.groupName
              )),
            );
          }else if (groupOption == groupsOptionsList[1]){
            Navigator.push(
              context,
              new MaterialPageRoute(builder: (context) => new meetingsList(
                  committeeName: groupItem.groupName, jUsers: groupItem.jUsers
              )),
            );
          }
          else if (groupOption == groupsOptionsList[2]){
            Navigator.push(
              context,
              new MaterialPageRoute(builder: (context) => new groupInfo(
                committeeName: groupItem.groupName,
                jUsers: groupItem.jUsers,
                headEmail: groupItem.headEmail,
                headName: groupItem.headName,
              )),
            );
          }
          else{

          }
        },
        child: new Card(
          child: new Row(
            children: <Widget>[
              new Container(
                padding: const EdgeInsets.only(left: 8.0, right: 32.0, top: 4.0 ,bottom: 4.0),
                child: new Icon(groupOption.optionIcon, size: 85.0,),
              ),
              new Expanded(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: new Text(
                        groupOption.optionName,
                        style: titleStyle,
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(bottom: 4.0, top: 4.0),
                      child: new Text(
                        groupOption.description, //MAX 51 Chars
                        style: descriptionStyle,
                      ),
                    ),
                  ],
                ),
              ),
              new Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

}



class _groupOptionsBuilder extends StatelessWidget{
  _groupOptionsBuilder({ Key key, @required this.groupItem})
      : assert(groupItem != null),
        super(key: key);


  final GroupItem groupItem;
  @override
  Widget build(BuildContext context) {
    return new Scrollbar(
      child: new ListView(
        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        children: _getItems(),
      ),
    );
  }

  List <Widget> _getItems(){
    return groupsOptionsList.map((GroupOption groupOption) {
      return new Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: new GroupOptionItemCard(
          groupOption: groupOption,
          groupItem: groupItem,
        ),
      );
    }).toList();

  }

}


class GroupPage extends StatefulWidget {

  GroupPage({@required this.groupItem});
  final GroupItem groupItem;

  @override
  _GroupPageState createState() => new _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(

        title: new Row(
          children: <Widget>[
//            new LayoutBuilder(
//              builder: (BuildContext context, BoxConstraints constraints) {
//                return new Container(
//                  padding: const EdgeInsets.all(4.0),
//                  width: constraints.maxHeight,
//                  height: constraints.maxHeight,
//                  child: new Container(
//                    decoration: new BoxDecoration(
//                        shape: BoxShape.circle,
//                        image: new DecorationImage(
//                            fit: BoxFit.fill,
//                            image: new NetworkImage(widget.groupItem.groupIconURL)
//                        )
//                    ),
//                  ),
//
//                );
//              },
//
//            ),
            new Text(widget.groupItem.groupName),
          ],
        ),

      ),
      body: new _groupOptionsBuilder(groupItem: widget.groupItem,),
    );
  }
}

final List<GroupOption> groupsOptionsList = <GroupOption>[
  const GroupOption(
    optionIcon: GroupOptionsIcons.newspaper,
    optionName: 'Announcements',
    description: "View all announcements from this committee",
  ),
  const GroupOption(
    optionIcon: IconData(0xe800, fontFamily: 'GroupOptionsIcons'),
    optionName: 'Meetings',
    description: "View all meetings held by this committee",
  ),
  const GroupOption(
    optionIcon: Icons.info,
    optionName: 'Committee Info',
    description: "View information about this committee",
  ),
];