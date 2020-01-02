import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:try_courier_app/screens/dataentry_screen.dart';
import 'package:try_courier_app/screens/login_screen.dart';

import 'utils.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.red),
        home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String userEmail;
  bool _isLoading = false;
  bool _somethingWentWrong = false;
  bool _isInit = true;


  @override
  void initState() {
    // TODO: implement initState
    _isInit = true;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if(_isInit)
    {
      setState(() {

        _isLoading = true;
      });
      print('User Email Before = $userEmail') ;
      Utils.autoAuthenticate().then((_){

        print('Utils.email within main : ' + Utils.email);
        setState(() {
          userEmail = Utils.email;
          _isLoading = false;
        });
      }).catchError((error){
        print('Something went wrong');

        setState(() {
          _somethingWentWrong = true;
          _isLoading = false;

        });
      });

      print('User Email After = $userEmail') ;
    }

    setState(() {
      _isInit = false;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ?
    Scaffold(appBar: AppBar(),
        body: Center(child: CircularProgressIndicator(),))
        : _somethingWentWrong ? Scaffold(appBar: AppBar(), body: Center(child: Text('Something Went Wrong! Try again later'),),)
        : userEmail == null ? LoginScreen() : DataEntryScreen(userName: userEmail,);
  }
}
