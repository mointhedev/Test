import 'package:flutter/material.dart';
import 'package:try_courier_app/screens/dataentry_screen.dart';
import 'package:try_courier_app/screens/editform_screen.dart';
import 'package:try_courier_app/screens/showrecord_screen.dart';
import 'package:try_courier_app/utils.dart';

class MyDrawer extends StatefulWidget {

  final bool isAdmin;

  MyDrawer({this.isAdmin});

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Account'),
            automaticallyImplyLeading: false,
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            leading: Icon(
              Icons.account_circle,
              size: 40,
              color: Colors.black,
            ),
            title: Utils.email == null ? Text('Unknown') : Text(Utils.email),
            subtitle: !widget.isAdmin ? Text('Employee') : Text('Admin'),
          ),
          Divider(
            height: 30,
          ),
          !widget.isAdmin ? Container() : Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.redAccent)),
                //color: Colors.grey,
                child: GestureDetector(
                  onTap: ()
                  {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_){
                      return DataEntryScreen();
                    }));
                  },

                  child: ListTile(
                    leading: Icon(
                      Icons.keyboard,
                      color: Colors.red,
                    ),
                    title: Text(
                      'Data Entry',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.redAccent)),
                //color: Colors.grey,
                child: GestureDetector(
                  onTap: ()
                  {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_){
                      return ShowRecordScreen();
                    }));
                  },

                  child: ListTile(
                    leading: Icon(
                      Icons.dns,
                      color: Colors.red,
                    ),
                    title: Text(
                      'Show Record',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.redAccent)),
                //color: Colors.grey,
                child: GestureDetector(
                  onTap: ()
                  {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_){
                      return EditFormScreen();
                    }));
                  },

                  child: ListTile(
                    leading: Icon(
                      Icons.dns,
                      color: Colors.red,
                    ),
                    title: Text(
                      'Edit Form',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.redAccent)),
                child: ListTile(
                  leading: Icon(Icons.assignment_ind, color: Colors.red),
                  title: Text('Manage Accounts',
                      style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
