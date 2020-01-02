import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as prefix0;
import 'package:try_courier_app/components/drawer.dart';

import '../business.dart';
import '../utils.dart';

class EditFormScreen extends StatefulWidget {
  @override
  _EditFormScreenState createState() => _EditFormScreenState();
}

class _EditFormScreenState extends State<EditFormScreen> {
  bool _isLoading;
  bool _isInit;
  bool _dataFetched;
  List<Business> _business;
  List<Business> _changedBusiness = [];
  TextEditingController addBusinessController = new TextEditingController();
  List<TextEditingController> textControllers = [];

  List<String> _id = [];

  @override
  void initState() {
    // TODO: implement initState
    _isLoading = false;
    _dataFetched = false;
    _isInit = true;
    _business = [];
    _changedBusiness = [];
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Utils.fetchBusiness().then((_) {
        setState(() {
          _business = Utils.loadBusiness();
        });
        for (Business business in _business) {
          textControllers.add(TextEditingController(text: business.title));
        }

        setState(() {
          _isLoading = false;
          _dataFetched = true;
        });
      }).catchError((error) {
        setState(() {
          _isLoading = false;
          _dataFetched = false;
        });

        showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('An error occured'),
                content: Text(error.toString()),
              );
            });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    //int i = -1;
    return Scaffold(
        appBar: AppBar(
          title: Text('Edit Form'),
          actions: <Widget>[
            _dataFetched
                ? GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (ctx) {
                            return Container(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              child: Form(
                                child: Column(
                                  children: <Widget>[
                                    TextFormField(
                                      controller: addBusinessController,
                                      decoration: InputDecoration(
                                        hintText: 'Enter New Field',
                                      ),
                                    ),
                                    RaisedButton(
                                      color: Colors.amber,
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        addBusinessController.text.trim() == ''
                                            ? setState((){_isLoading = false;})
                                            : Utils.addBusiness(
                                                    addBusinessController.text
                                                        .trim())
                                                .then((_) {
                                                Utils.fetchBusiness().then((_) {
                                                  setState(() {
                                                    _business =
                                                        Utils.loadBusiness();
                                                    _changedBusiness = [];
                                                    textControllers = [];
                                                    addBusinessController.text = '';
                                                    for (Business business
                                                        in _business) {
                                                      textControllers.add(
                                                          TextEditingController(
                                                              text: business
                                                                  .title));
                                                    }
                                                    _isLoading = false;
                                                    _dataFetched = true;
                                                  });
                                                }).catchError((error) {
                                                  setState(() {
                                                    _isLoading = false;
                                                    _dataFetched = false;
                                                  });
                                                  showDialog(
                                                      context: context,
                                                      builder: (ctx) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              'An error occured, try again later'),
                                                          content: Text(
                                                              error.toString()),
                                                        );
                                                      });
                                                });
                                              }).catchError((error) {
                                                setState(() {
                                                  _isLoading = false;
                                                  _dataFetched = false;
                                                });
                                                showDialog(
                                                    context: context,
                                                    builder: (ctx) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            'An error occured, try again later'),
                                                        content: Text(
                                                            error.toString()),
                                                      );
                                                    });
                                              });

                                      },
                                      child: Text('Save'),
                                    )
                                  ],
                                ),
                              ),
                            );
                          });
                    },
                    child: Container(
                        alignment: Alignment.bottomLeft,
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.add),
                            Text(
                              'Add New Field',
                              style: TextStyle(
                                  fontSize: Theme.of(context)
                                          .textTheme
                                          .title
                                          .fontSize -
                                      5,
                                  color: Colors.white),
                            ),
                          ],
                        )),
                  )
                : Container()
          ],
        ),
        drawer: MyDrawer(),
        body: _isLoading
            ? Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : !_dataFetched
                ? Container(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.error_outline,
                            size: 40,
                          ),
                          Text('Failed to load data')
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            ..._business.map((business) {
                              int i = _business.indexOf(business);
                              return TextFormField(
                                //You cannot use controller and initial value at the same time
                                //initialValue: textControllers[_business.indexOf(business)].text,
                                controller: textControllers[i],
                                onChanged: (value) {
                                  print('Inside On Changed');

                                  _changedBusiness.map((business) {
                                    return business.id;
                                  }).contains(business.id)
                                      ? null
                                      : _changedBusiness.add(Business(
                                          id: business.id,
                                          title: i.toString()));

                                  print(
                                      'Changed Business Added OnChanged : $_changedBusiness');
                                },
                              );
                            }).toList(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RaisedButton(
                                onPressed: () {
                                  setState(() {
                                    _isLoading = true;
                                    print('Entering Update Business');
                                    print(
                                        'Changed Business value : $_changedBusiness');
                                  });

                                  _changedBusiness.isNotEmpty ? _changedBusiness =
                                      _changedBusiness.map((business) {
                                    return Business(
                                        id: business.id,
                                        title: textControllers[
                                                int.parse(business.title)]
                                            .text
                                            .trim());
                                  }).toList() : _changedBusiness = [];
                                  if( _changedBusiness.isNotEmpty )
                                      {Utils.updateBusiness(_changedBusiness)
                                          .then((_) {
                                            print('Delection Successful');

                                            setState(() {
                                              _changedBusiness = [];
                                            });
                                            new Future.delayed(const Duration(seconds: 2)).then((_){
                                              Utils.fetchBusiness().then((_) {
                                                setState(() {
                                                  //_changedBusiness = [];
                                                  _business = Utils.loadBusiness();
                                                  textControllers = [];
                                                  for (Business business
                                                  in _business) {
                                                    textControllers.add(
                                                        TextEditingController(
                                                            text: business.title));
                                                  }
                                                  _isLoading = false;
                                                  _dataFetched = true;
                                                });
                                              }).catchError((error) {
                                                setState(() {
                                                  _isLoading = false;
                                                  _dataFetched = false;
                                                });
                                                showDialog(
                                                    context: context,
                                                    builder: (ctx) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            'An error occured, try again later'),
                                                        content:
                                                        Text(error.toString()),
                                                      );
                                                    });
                                              });
                                            });
                                        }).catchError((error) {
                                          setState(() {
                                            _isLoading = false;
                                            _dataFetched = false;
                                          });
                                          showDialog(
                                              context: context,
                                              builder: (ctx) {
                                                return AlertDialog(
                                                  title: Text(
                                                      'An error occured, try again later'),
                                                  content:
                                                      Text(error.toString()),
                                                );
                                              });
                                        });}
                                      else setState((){_isLoading = false;});
                                },
                                color: Colors.amber,
                                child: Text('Save'),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ));
  }
}
