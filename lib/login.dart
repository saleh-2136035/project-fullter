
import 'package:flutter/material.dart';

import 'sign up.dart';
import 'home_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';  // استيراد الحزمة

void main() {
  runApp(MaterialApp(home: HomeScreen()));
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // تعريف مفتاح الفورم للتحقق من الحقول
  final _formKey = GlobalKey<FormState>();

  // دالة لإرسال الريكويست
  Future<void> sendRequest(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final String url = 'https://smart-analysis-of-health-condition.onrender.com/api/custom_login/';

      // البيانات التي سترسلها من الحقول
      final Map<String, dynamic> data = {
        "username": _usernameController.text,
        "password": _passwordController.text,
      };

      try {
        // إرسال الطلب
        final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(data),
        );

        // التعامل مع الاستجابة
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          print('Login successful: $responseData');


          //يبغاله تعديل
          // تخزين التوكن في shared_preferences
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('access_token', responseData['access']);  // تخزين التوكن
          prefs.setString('refresh_token', responseData['refresh']);
          prefs.setString('user', jsonEncode(responseData['user']));
          prefs.setString('patient', jsonEncode(responseData['patient']));



          // الانتقال إلى الصفحة الرئيسية بعد تسجيل الدخول بنجاح
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen1()),
          );
        } else {
          print('Error: ${response.statusCode}');
          print('Message: ${response.body}');
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Login Failed'),
              content: Text('Invalid username or password.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        print('Exception: $e');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while trying to log in.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Color(0xFFFFDDDD),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => sendRequest(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFDDDD),
                  ),
                  child: Text('Log in', style: TextStyle(color: Color(0xFF7B0000))),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                      },
                      child: Text(
                        'Sign up',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
