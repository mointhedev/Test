import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'business.dart';
import 'entry.dart';
import 'http_exception.dart';

class Utils {

  static const USERS_URL = 'https://try-app.firebaseio.com/users.json';
  static RegExp regExp = new RegExp(r'\+?[\d- ]{9,}');
  static String userToken;
  static String email;

  static RegExp getRegExpression()
  {
    return regExp;
  }

  static Future<void> addEntry(Entry entry)
  {
    print('POST http request started');
    final url = 'https://try-app.firebaseio.com/entries.json?auth=$userToken';
    return http.post(url, body: json.encode(
      {
        'business' : entry.business,
        'location' : entry.location,
        'company' : entry.company,
        'mobile' : entry.mobile,
        'email' : entry.email,
        'user' : entry.user,
        'dateTime' : entry.dateTime
      }
    ));
  }

  static Future<void> addBusiness(String business)
  {
    print('POST http request started');
    final url = 'https://try-app.firebaseio.com/businesses.json?auth=$userToken';
    return http.post(url, body: json.encode(
        {
          'title' : business
        }
    ));
  }

  static Future<void> _authenticate(
      String uemail, String password, String urlSegment) async {
    try{
    final url =
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/$urlSegment?key=AIzaSyDyDOJtKK';
    final response = await http.post(
      url,
      body: json.encode(
        {
          'email': uemail,
          'password': password,
          'returnSecureToken': true,
        },
      ),
    );

    final responseData = json.decode(response.body);
    if(responseData.toString().contains('idToken')) {
      userToken = responseData['idToken'].toString();
      email = responseData['email'].toString();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', userToken);
      prefs.setString('email', email);
      print('_authenticate: Email = ${responseData['email']}');
      print('User token Saved in Preferences');
    }
    print(responseData);
    if (responseData['error'] != null) {
      throw HttpException(responseData['error']['message']);
    }
    }catch (error) {
    throw error;
    }
  }

  static Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signupNewUser');
  }

  static Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'verifyPassword');
  }

  static Future<void> updateBusiness(List<Business> businesses)
  async
  {
    print('Inside Update Business Function');
    print('Businesses : ${businesses.map((buss){return '${buss.id} : ${buss.title}';})}' );
    //Map<String, String> updateMap = {};
    businesses.forEach((business) async {
      print('Inside Business ForEach');
      //updateMap.putIfAbsent('${business.id}/title', () => business.title);
      final url = 'https://try-app.firebaseio.com/businesses/${business.id}.json?auth=$userToken';
      print(business.title);
      if(business.title.trim() == '')
      {
        print('Inside empty businsess check');
        final response = await http.delete('https://try-app.firebaseio.com/businesses/${business.id}.json?auth=$userToken');
      }
      else{
      final response = await http.put(
      url, body: json.encode({'title': business.title}));
      }
    });
    //print('Update Map : $updateMap');
  }



  static List<Business> _business = [];
  static List<Entry> _entries = [];

  static Future<void> fetchBusiness() async
  {
    final url = 'https://try-app.firebaseio.com/businesses.json?auth=$userToken';
    final response = await http.get(url);
    print(response.body.toString());
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    final business = new List<Business>();
    extractedData.forEach((id, data){
      business.add(Business(id: id,title: data['title'].toString()));
    });

    _business = business;

  }

  static List<Business> loadBusiness()
  {
    return _business;
  }


  static List<Entry> loadEntries()
  {
    return _entries;
  }


  static Future<void> fetchEntries()
  async {
    final url = 'https://try-app.firebaseio.com/entries.json?auth=$userToken';
    final response = await http.get(url);
    //print(response.body.toString());
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    final entries = new List<Entry>();
    extractedData.forEach((id, data){
      entries.add(Entry(
        id : id,
        business: data['business'],
        location: data['location'],
        company: data['company'],
        mobile: data['mobile'],
        email: data['email'],
        user: data['user'],
        dateTime: data['dateTime'],

      ));
    });

    _entries = entries;

  }

  static Future<void> deleteRow(String id)
  async
  {
    await http.delete('https://try-app.firebaseio.com/entries/$id.json?auth=$userToken');
  }

  static Future<void> autoAuthenticate()
  async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getString('token') != null)
      {
        userToken = prefs.getString('token');
        email = prefs.getString('email');
      }
    print('AutoAuthenticate - User Token : $userToken, Email : $email');
  }

  static Future<void> logout()
  async {
    email = null;
    userToken = null;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('email');
    print('Logout - User Token : $userToken, Email : $email');
    print('Logout - Prefs : ${prefs.getString('email')}');

  }

}