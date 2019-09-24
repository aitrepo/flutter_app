import 'package:flutter/material.dart';

// Used for API
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

final String VALIDATE_USER_URI =
    "http://192.168.1.105:3002/api/validateUser/validate";

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    home: App(),
  ));
}

class App extends StatelessWidget {
  static const String _title = 'User Login Form';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: UserLoginWidget(),
      ),
    );
  }
}

class UserLoginWidget extends StatefulWidget {
  UserLoginWidget({Key key}) : super(key: key);

  @override
  _UserLoginWidgetState createState() => _UserLoginWidgetState();
}

class _UserLoginWidgetState extends State<UserLoginWidget> {
  final _formKey = GlobalKey<FormState>();
  String password = "";
  String userName = "";
  String sessionKey = "";

  Future<bool> validateUser(userName, password) async {

  Map<String, String> headers = {"Content-type": "application/json"};
  String json = '{"title": "User validate request", "body":"" ,"username": "$userName" ,"password": "$password"}';
  // make POST request
  var response = await http.post(VALIDATE_USER_URI, headers: headers, body: json);

    if (response.statusCode == 200) {
      var responseJSON = jsonDecode(response.body);

      if (responseJSON["isValid"] == true)
        return true;
      else
        return false;
    } else {
      return false;
    }
  }

  void validate() {
    validateUser(userName, password).then((isValid) {
      if (isValid) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WelcomeScreen(
                    activeUser: new UserDTO(userName, password, sessionKey),
                  )),
        );
      } else {
        showAlert(context, "Invalid User details, please try again.");
      }
    });
  }

  void showAlert(BuildContext context, message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Error!"),
              content: Text("$message"),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(12.0),
        child: new ListView(
          children: [
            new Image.asset(
              "assets/logo.png",
              alignment: Alignment.center,
              width: 400.0,
              height: 200.0,
              fit: BoxFit.cover,
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: TextFormField(
                      onChanged: (text) {
                        setState(() {
                          userName = text;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'User Name',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter your Username';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: TextFormField(
                      onChanged: (text) {
                        setState(() {
                          password = text;
                        });
                      },
                      obscureText: true,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter your Password';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: RaisedButton(
                      onPressed: () {
                        // Validate will return true if the form is valid, or false if
                        // the form is invalid.
                        if (_formKey.currentState.validate()) {
                          // Process data.
                          validate();
                        }
                      },
                      child: Text('Login'),
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}

class WelcomeScreen extends StatelessWidget {
  final UserDTO activeUser;
  WelcomeScreen({Key key, @required this.activeUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome User : " + activeUser.userName),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}

class UserDTO {
  final String userName;
  final String password;
  final String sessionKey;

  UserDTO(this.userName, this.password, this.sessionKey);
}