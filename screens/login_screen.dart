import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:try_courier_app/screens/dataentry_screen.dart';
import '../http_exception.dart';
import '../utils.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  double padding = 20;
  final passfocusNode = FocusNode();
  final _formkey = GlobalKey<FormState>();
  bool _isLoading = false;

  TextEditingController usernameController = TextEditingController();
  TextEditingController passController = TextEditingController();

  void _login () async {
      if (_formkey.currentState
          .validate()) {
        print('Login Form Vaildated');
        setState(() {
          _isLoading = true;
        });

        try {
          print('Going to login');
          await Utils.login(
              usernameController.text,
              passController.text);
          Future.delayed(const Duration(
              seconds: 7))
              .then((_) {
            print('Inside Delayed');
            Navigator.of(context)
                .pushReplacement(
                MaterialPageRoute(
                    builder: (_) {
                      return DataEntryScreen(
                        userName: Utils.email,
                      );
                    }));

            setState(() {
              _isLoading = false;
            });
          });
        } on HttpException catch (error) {
          print('Inside HTTP Exp');
          var errorMessage =
              'Authentication failed';
          if (error
              .toString()
              .contains('EMAIL_EXISTS')) {
            errorMessage =
            'This email address is already in use.';
          } else if (error
              .toString()
              .contains('INVALID_EMAIL')) {
            errorMessage =
            'This is not a valid email address';
          } else if (error
              .toString()
              .contains('WEAK_PASSWORD')) {
            errorMessage =
            'This password is too weak.';
          } else if (error
              .toString()
              .contains(
              'EMAIL_NOT_FOUND')) {
            errorMessage =
            'Could not find a user with that email.';
          } else if (error
              .toString()
              .contains(
              'INVALID_PASSWORD')) {
            errorMessage =
            'Invalid password.';
          }
          setState(() {
            _isLoading = false;
          });
          _showErrorDialog(errorMessage);
          print(errorMessage);
        } catch (error) {
          const errorMessage =
              'Could not authenticate you. Please try again later.';
          _showErrorDialog(errorMessage);
          setState(() {
            _isLoading = false;
          });
        }
      }

  }

  void _showErrorDialog(String message) {
    print('ShowError Called');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appbar = AppBar(title: Text('Sign in'));

    final screenHeight = MediaQuery.of(context).size.height -
        appbar.preferredSize.height -
        MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.of(context).size.width;
    final containerHeight = screenHeight * 0.42;

    return Scaffold(
        backgroundColor: Colors.red,
        appBar: appbar,
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            height: screenHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                //SizedBox(),
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  color: Colors.white,
                  height: 100,
                  width: 200,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset('images/logo.png'),
                  ),
                ),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  color: Colors.white,
                  height: containerHeight,
                  child: LayoutBuilder(
                    builder: (ctx, constraints) {
                      final containerHeight = constraints.maxHeight;

                      return Center(
                        child: Form(
                          key: _formkey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: padding, vertical: 20),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                      hintText: 'Username',
                                      contentPadding: EdgeInsets.all(10)),
                                  validator: (value) {
                                    if (value.isEmpty || !value.contains('@')) {
                                      return 'Please enter a valid email';
                                    }
                                    //return '';
                                  },
                                  keyboardType: TextInputType.emailAddress,
                                  controller: usernameController,
                                  onChanged: (_) {
                                    if (usernameController.text.isEmpty)
                                      _formkey.currentState.validate();
                                  },
                                  onFieldSubmitted: (_) {
                                    //_formkey.currentState.validate();
                                    FocusScope.of(context)
                                        .requestFocus(passfocusNode);
                                  },
                                ),
                              ),
                              Container(
                                margin:
                                    EdgeInsets.symmetric(horizontal: padding),
                                child: TextFormField(
                                  controller: passController,
                                  focusNode: passfocusNode,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                      hintText: 'Password',
                                      contentPadding: EdgeInsets.all(10)),
                                  onChanged: (_) {
                                    if (usernameController.text.isEmpty)
                                      _formkey.currentState.validate();

                                    if (passController.text.isNotEmpty)
                                      _formkey.currentState.validate();
                                  },
                                  validator: (value) {
                                    if (value.isEmpty || value.length < 6)
                                      return 'Please enter a valid password';

                                    //return '';
                                  },
                                  onFieldSubmitted: (_) {
                                    _formkey.currentState.validate();
                                  },
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    bottom: containerHeight * 0.08, top: 10),
                                child: _isLoading
                                    ? CircularProgressIndicator()
                                    : RaisedButton(
                                        color: Colors.red,
                                        onPressed: _login,
                                        child: Text(
                                          'Sign in',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(),
              ],
            ),
          ),
        ));
  }
}
