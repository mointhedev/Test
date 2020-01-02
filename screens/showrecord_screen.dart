import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:try_courier_app/components/drawer.dart';
import 'package:pdf/pdf.dart';

import '../entry.dart';
import '../utils.dart';

class ShowRecordScreen extends StatefulWidget {
  @override
  _ShowRecordScreenState createState() => _ShowRecordScreenState();
}

class _ShowRecordScreenState extends State<ShowRecordScreen> {
  bool _isInit = false;
  bool _isLoading = false;
  bool _dataFetchedSuccessfully = false;
  bool _filterVisible = false;

  List<Entry> _entries;
  List<String> _business;
  List<String> _cities;
  List<Entry> _fullEntries;

  List<int> _timeFilter;

  String currentSelectedBusiness;
  String currentSelectedCity;
  int currentSelectedDays;
  TextEditingController companyController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();



  @override
  void initState() {
    // TODO: implement initState
    _isInit = true;
    _entries = [];
    _fullEntries = [];
    _business = ['All'];
    _dataFetchedSuccessfully = false;
    _filterVisible = false;
    _cities = ['All', 'Islamabad', 'Rawalpindi', 'Lahore', 'Peshawar'];
    currentSelectedCity = _cities.first;
    _timeFilter = [0, 7, 30, 180];
    currentSelectedDays = _timeFilter.first;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies

    if (_isInit) {
      _isLoading = true;

      Utils.fetchEntries().then((_) {
        Utils.fetchBusiness().then((_) {
          setState(() {
            _business = _business + [...Utils.loadBusiness().map((business){return business.title;})];
            print(_business);
            currentSelectedBusiness = _business.first;
            print(_business.first);
            _fullEntries = Utils.loadEntries().reversed.toList();
            _entries = _fullEntries;
            _isLoading = false;
            _dataFetchedSuccessfully = true;
          });
        }).catchError((error) {
          setState(() {
            _dataFetchedSuccessfully = false;
            _isLoading = false;
          });
        });
      }).catchError((error) {
        setState(() {
          _dataFetchedSuccessfully = false;
          _isLoading = false;
        });

        showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('Error while fetching data'),
                content: Text(error.toString()),
              );
            });
      });
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  String getStringForDays(int days) {
    switch (days) {
      case 0:
        return 'All';
        break;
      case 7:
        return '7 Days';
        break;
      case 30:
        return '1 Month';
        break;
      case 180:
        return '6 Months';
        break;
      default:
        return 'Error';
        break;
    }
  }

  void applyFilter() {
    setState(() {
      _entries = _fullEntries;
    });
    if (currentSelectedBusiness != 'All') {
      print("Current business filer");
      setState(() {
        _entries = _entries.where((entry) {
          return entry.business == currentSelectedBusiness;
        }).toList();
      });
    }
    if (currentSelectedCity != 'All') {
      setState(() {
        _entries = _entries.where((entry) {
          return entry.location == currentSelectedCity;
        }).toList();
      });
    }
    if (companyController.text.trim().isNotEmpty) {
      setState(() {
        _entries = _entries.where((entry) {
          return entry.company.contains(companyController.text.trim());
        }).toList();
      });
    }
    if (mobileController.text.trim().isNotEmpty) {
      setState(() {
        _entries = _entries.where((entry) {
          return entry.mobile.contains(mobileController.text.trim());
        }).toList();
      });
    }
    if (emailController.text.trim().isNotEmpty) {
      setState(() {
        _entries = _entries.where((entry) {
          return entry.email.contains(emailController.text.trim());
        }).toList();
      });
    }

    if (currentSelectedDays != 0) {
      _entries = _entries.where((entry) {
        var date = entry.dateTime.split(' ')[0].split('/');
        DateTime entryDate = new DateTime(
            int.parse(date[2]), int.parse(date[0]), int.parse(date[1]));

        var toDate = DateFormat.yMd().format(DateTime.now()).split('/');

        DateTime today = new DateTime(
            int.parse(toDate[2]), int.parse(toDate[0]), int.parse(toDate[1]));

        print('Todate : $toDate');

        return entryDate
            .isAfter(today.subtract(Duration(days: currentSelectedDays)));
      }).toList();
    }
  }

  DataCell buildDataCell(String text, String id) {
    return DataCell(
        Text(text),
        onTap: () {

          showDialog(context: context, builder: (BuildContext ctx){
            return AlertDialog(
              title: Text('Are you sure you want to delete this entry?'),
              actions: <Widget>[

                FlatButton(
                  child: Text('Yes', style: TextStyle(fontSize: 18),),
                  onPressed: (){
                    setState(() {
                      _isLoading = true;
                    });
                    Utils.deleteRow(id).then((_){
                      Utils.fetchEntries().then((_){
                        setState(() {
                          _business = _business + [...Utils.loadBusiness().map((business){return business.title;})];
                          print(_business);
                          currentSelectedBusiness = _business.first;
                          print(_business.first);
                          _fullEntries = Utils.loadEntries().reversed.toList();
                          _entries = _fullEntries;
                          _isLoading = false;
                          _dataFetchedSuccessfully = true;
                        });
                      });

                    }).catchError((error){
                      setState(() {
                        _isLoading = false;
                        _dataFetchedSuccessfully = false;
                      });
                      showDialog(context: context, builder: (ctx)
                      {
                        return AlertDialog(title: Text('Error'), content: Text(error.toString()),);
                      });
                    }).catchError((error){
                      showDialog(context: context, builder: (ctx)
                      {
                        return AlertDialog(title: Text('There was some problem with deleting Entry'), content: Text(error.toString()),);
                      });
                    });
                    Navigator.of(ctx).pop();

                  },
                ),
                FlatButton(
                  child: Text('No', style: TextStyle(fontSize: 18)),
                  onPressed: (){
                    Navigator.of(ctx).pop();
                  },
                ),

              ],
            );
          });


    }
    );
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(

        drawer: MyDrawer(),
        appBar: AppBar(

          title: Text('Entries List'),
          actions: <Widget>[
            FlatButton(
              child: Text('Export PDF', style: TextStyle(fontSize: 18, color: Colors.white),),
              onPressed: (){
                showDialog(context: context, builder: (ctx){
                  return Dialog(
                    child: Wrap(
                      direction: Axis.horizontal,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                              child: Text('Export Table'),
                              onPressed: (){},
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                              child: Text('Export Numbers'),
                              onPressed: (){},

                            ),
                          ),

                        ],
                      ),

                  );
                });
              },
            )
          ],
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : !_dataFetchedSuccessfully
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text("Failed to load data"),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(children: <Widget>[
                      Card(
                          elevation: 5,
                          child: ListTile(
                            onTap: () => {
                              setState(() {
                                _filterVisible = !_filterVisible;
                              })
                            },
                            leading: Icon(Icons.filter_list),
                            title: Text("Add Filter"),
                            trailing: Icon(Icons.arrow_drop_down),
                          )),
                      Visibility(
                        visible: _filterVisible,
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 10, top: 5),
                          margin: EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black54, width: 2)),
                          child: Form(
                            child: Container(
                              margin: const EdgeInsets.only(
                                  top: 2, left: 15, right: 50),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text("Business :    "),
                                      Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          padding: EdgeInsets.only(
                                              left: 10, right: 10, bottom: 0),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey)),
                                          child: DropdownButton<String>(
                                            isDense: true,
                                            hint: Text('Business'),
                                            items: _business
                                                .map((String business) {
                                              return DropdownMenuItem<String>(
                                                value: business,
                                                child: Text(business),
                                              );
                                            }).toList(),
                                            value: currentSelectedBusiness,
                                            onChanged: (value) {
                                              setState(() {
                                                currentSelectedBusiness = value;
                                              });
                                              applyFilter();
                                            },
                                          )),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Text("City :              "),
                                      Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          padding: EdgeInsets.only(
                                              left: 10, right: 10, bottom: 0),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey)),
                                          child: DropdownButton<String>(
                                            isDense: true,
                                            hint: Text('Business'),
                                            items:
                                                _cities.map((String business) {
                                              return DropdownMenuItem<String>(
                                                value: business,
                                                child: Text(business),
                                              );
                                            }).toList(),
                                            value: currentSelectedCity,
                                            onChanged: (value) {
                                              setState(() {
                                                currentSelectedCity = value;
                                              });
                                              applyFilter();
                                            },
                                          )),
                                    ],
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 5),
                                    padding: EdgeInsets.only(
                                        left: 10, right: 10, bottom: 5),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey)),
                                    child: TextFormField(
                                      onChanged: (_) {
                                        applyFilter();
                                      },
                                      controller: companyController,
                                      decoration:
                                          InputDecoration(hintText: 'Company'),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 5),
                                    padding: EdgeInsets.only(
                                        left: 10, right: 10, bottom: 5),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey)),
                                    child: TextFormField(
                                      onChanged: (_) {
                                        applyFilter();
                                      },
                                      controller: mobileController,
                                      decoration:
                                          InputDecoration(hintText: 'Mobile'),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 5),
                                    padding: EdgeInsets.only(
                                        left: 10, right: 10, bottom: 5),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey)),
                                    child: TextFormField(
                                      onChanged: (_) {
                                        applyFilter();
                                      },
                                      controller: emailController,
                                      decoration:
                                          InputDecoration(hintText: 'E-mail'),
                                    ),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Text("From Last :   "),
                                      Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          padding: EdgeInsets.only(
                                              left: 10, right: 10, bottom: 0),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey)),
                                          child: DropdownButton<int>(
                                            isDense: true,
                                            hint: Text('Business'),
                                            items:
                                                _timeFilter.map((int current) {
                                              return DropdownMenuItem<int>(
                                                value: current,
                                                child: Text(
                                                    getStringForDays(current)),
                                              );
                                            }).toList(),
                                            value: currentSelectedDays,
                                            onChanged: (value) {
                                              setState(() {
                                                currentSelectedDays = value;
                                                applyFilter();
                                              });
                                            },
                                          )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: <DataColumn>[
                            DataColumn(
                              label: Text(
                                'Business',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                                label: Text(
                              'Location',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                            DataColumn(
                                label: Text(
                              'Company',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                            DataColumn(
                                label: Text(
                              'Mobile',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                            DataColumn(
                                label: Text(
                              'E-mail',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                            DataColumn(
                                onSort: (_, _g) {
                                  setState(() {
                                    _entries = _entries.reversed.toList();
                                  });
                                },
                                label: Text(
                                  'Date/Time',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                            DataColumn(
                                label: Text(
                              'User',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                          ],
                          rows: _entries.map((entry) {
                            return DataRow(cells: <DataCell>[
                              buildDataCell(entry.business, entry.id),
                              buildDataCell(entry.location, entry.id),
                              buildDataCell(entry.company, entry.id),
                              buildDataCell(entry.mobile, entry.id),
                              buildDataCell(entry.email, entry.id),
                              buildDataCell(entry.dateTime, entry.id),
                              buildDataCell(entry.user, entry.id),
                            ]);
                          }).toList(),
                        ),
                      )
                    ]),
                  ));
  }
}
