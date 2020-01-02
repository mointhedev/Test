import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:try_courier_app/components/drawer.dart';
import 'package:try_courier_app/entry.dart';
import 'package:try_courier_app/screens/login_screen.dart';
import 'package:try_courier_app/screens/showrecord_screen.dart';

import '../business.dart';
import '../utils.dart';

class DataEntryScreen extends StatefulWidget {
  final String userName;

  DataEntryScreen({this.userName});

  @override
  _DataEntryScreenState createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends State<DataEntryScreen> {
  Business _currentSelectedBusiness;
  String _currentSelectedCity;
  String _companyValue;
  String _mobileValue;
  String _emailValue;

  List<String> _cities;
  List<Business> _companies;

  bool _isLoading = false;
  bool _isInit = false;
  bool dataFetchedSuccessfully = false;
  bool _isInitDataLoading;
  bool _isLogoutLoading = false;
  bool _isAdmin = false;

  @override
  void initState() {
    // TODO: implement initState

    //Utils.signup('hassaan@tsn.com', 'Hassaan678');
    _isInit = true;
    _cities = ['Islamabad', 'Rawalpindi', 'Lahore', 'Peshawar'];
    _currentSelectedCity = _cities.first;
    _isInitDataLoading = false;
    _isAdmin = false;
    _isLogoutLoading = false;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (_isInit) {
      print('User Email Data Entry : ' + widget.userName);
      if (widget.userName == 'hassaan@tsn.com') _isAdmin = true;

      _isInitDataLoading = true;
      Utils.fetchBusiness().then((_) {
        setState(() {
          _companies = Utils.loadBusiness();
          _currentSelectedBusiness = _companies.first;
          print(_companies);
          _isInitDataLoading = false;
          dataFetchedSuccessfully = true;
        });
      }).catchError((error) {
        setState(() {
          _isInitDataLoading = false;
          dataFetchedSuccessfully = false;
        });
        showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('Error'),
                content: Text(error.toString()),
              );
            });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  final _formKey = GlobalKey<FormState>();
  final mobileFocusNode = FocusNode();
  final emailFocusNode = FocusNode();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextStyle heading =
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black);

  double padding = 30;

  void _changeBusiness(value) {
    setState(() {
      _currentSelectedBusiness = value;
    });
  }

  void _changeCity(value) {
    setState(() {
      _currentSelectedCity = value;
    });
  }

  showMessage(String message) {
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(content: new Text(message), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: MyDrawer(isAdmin: _isAdmin),
      appBar: AppBar(
        actions: <Widget>[
          _isLogoutLoading
              ? Center(child: Container( height: 20, width: 20, margin: EdgeInsets.symmetric(horizontal: 20,),child: FittedBox(child: CircularProgressIndicator(backgroundColor: Colors.white,))))

              : FlatButton(
                  child: Text('Log out', style: TextStyle(color: Colors.white, fontSize: 16), ),
                  onPressed: () async {
                    print('Log out Button Tapped');
                    setState(() {
                      _isLogoutLoading = true;
                    });
                    try {
                      await Utils.logout();
                    }catch(error)
                    {
                      setState(() {
                        _isLogoutLoading = false;
                      });
                      showDialog(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog(
                              title: Text('Error'),
                              content: Text(error.toString()),
                            );
                          });
                    }
                      Navigator.of(context)
                          .pushReplacement(MaterialPageRoute(builder: (_) {
                        return LoginScreen();
                      }));
                      setState(() {
                        _isLogoutLoading = false;
                      });

                  },
                )
        ],
        title: Text(
          "Try Services Network",
        ),
      ),
      body: _isInitDataLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        "Business :  ",
                        style: heading,
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)),
                        child: dataFetchedSuccessfully
                            ? DropdownButton<Business>(
                                items: _companies.map((Business current) {
                                  return DropdownMenuItem<Business>(
                                    value: current,
                                    child: Text(current.title),
                                  );
                                }).toList(),
                                onChanged: (value) => _changeBusiness(value),
                                value: _currentSelectedBusiness,
                                isDense: true,
                              )
                            : Text(
                                'Couldn\'t Fetch Data :(',
                                style: TextStyle(color: Colors.red),
                              ),
                      ),
                      SizedBox(
                        height: padding,
                      ),
                      Text(
                        "Location :  ",
                        style: heading,
                      ),
                      Container(
                          margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)),
                          child: DropdownButton<String>(
                            items: _cities.map((String current) {
                              return DropdownMenuItem<String>(
                                value: current,
                                child: Text(current),
                              );
                            }).toList(),
                            onChanged: (value) => _changeCity(value),
                            value: _currentSelectedCity,
                            isDense: true,
                          )),
                      SizedBox(
                        height: padding,
                      ),
                      Container(
                          width: 200,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Enter Company Name',
                            ),
                            validator: (value) {
                              if (value.isEmpty)
                                return "Please enter a company name";
                            },
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(mobileFocusNode);
                            },
                            onSaved: (value) {
                              _companyValue = value;
                            },
                          )),
                      SizedBox(
                        height: padding,
                      ),
                      Container(
                          width: 200,
                          child: TextFormField(
                              focusNode: mobileFocusNode,
                              decoration: InputDecoration(
                                labelText: 'Enter Mobile Number',
                              ),
                              validator: (value) {
                                if (!Utils.getRegExpression().hasMatch(value) ||
                                    value.isEmpty)
                                  return 'Please enter a valid number';
                              },
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(emailFocusNode);
                              },
                              keyboardType: TextInputType.number,
                              onSaved: (value) {
                                _mobileValue = value;
                              })),
                      SizedBox(
                        height: padding,
                      ),
                      Container(
                          width: 200,
                          child: TextFormField(
                            focusNode: emailFocusNode,
                            decoration: InputDecoration(
                              labelText: 'Enter E-mail Address',
                            ),
                            validator: (value) {
                              if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(value) ||
                                  value.isEmpty)
                                return 'Please enter a valid email';
                            },
                            onFieldSubmitted: (_) {
                              _formKey.currentState.validate();
                            },
                            onSaved: (value) {
                              _emailValue = value;
                            },
                            keyboardType: TextInputType.emailAddress,
                          )),
                      SizedBox(
                        height: padding + 10,
                      ),
                      _isLoading
                          ? CircularProgressIndicator()
                          : RaisedButton(
                              color: Colors.red,
                              textColor: Colors.white,
                              child: Text('   Submit   '),
                              onPressed: () {
                                print('Submit Button pressed');

                                if (_formKey.currentState.validate()) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  _formKey.currentState.save();
                                  print('Util function ran');

                                  Utils.addEntry(Entry(
                                          business:
                                              _currentSelectedBusiness.title,
                                          location: _currentSelectedCity,
                                          company: _companyValue,
                                          mobile: _mobileValue,
                                          email: _emailValue,
                                          user: widget.userName,
                                          dateTime: DateFormat.yMd()
                                              .add_jm()
                                              .format(DateTime.now())))
                                      .then((_) {
                                    _formKey.currentState.reset();
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    showMessage("Entry saved !");
                                  }).catchError((error) {
                                    {
                                      setState(() {
                                        _isLoading = false;
                                      });

                                      showDialog(
                                          context: context,
                                          builder: (ctx) {
                                            return AlertDialog(
                                              title: Text('Error'),
                                              content: Text(error.toString()),
                                            );
                                          });
                                    }
                                  });
                                }
                              }),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
