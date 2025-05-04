import 'package:flutter/material.dart';
import 'sign up.dart';
import 'home_page.dart';
import 'view patient.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> sendRequest(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final String url = 'https://smart-analysis-of-health-condition.onrender.com/api/custom_login/';
      final Map<String, dynamic> data = {
        "username": _usernameController.text,
        "password": _passwordController.text,
      };

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final prefs = await SharedPreferences.getInstance();

          await prefs.setString('access_token', responseData['access']);
          await prefs.setString('refresh_token', responseData['refresh']);
          await prefs.setString('user', jsonEncode(responseData['user']));

          if (responseData.containsKey('patient')) {
            await prefs.setString('patient', jsonEncode(responseData['patient']));
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen1()));
          } else if (responseData.containsKey('doctor')) {
            await prefs.setString('doctor', jsonEncode(responseData['doctor']));
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ViewPatientScreen()));
          }
        } else {
          _showErrorDialog('فشل تسجيل الدخول. تأكد من صحة البيانات.');
        }
      } catch (e) {
        _showErrorDialog('حدث خطأ أثناء الاتصال بالخادم.');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('موافق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality( // دعم اللغة العربية
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(''),
          backgroundColor: Color(0xFFFFDDDD),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  SizedBox(height: 50),
                  Text(
                    'تسجيل الدخول',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'اسم المستخدم',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'الرجاء إدخال اسم المستخدم' : null,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'الرجاء إدخال كلمة المرور' : null,
                  ),
                  SizedBox(height: 10),
                  SizedBox(height: 20),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: () => sendRequest(context),
                          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFDDDD)),
                          child: Text('دخول', style: TextStyle(color: Color(0xFF7B0000))),
                        ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('ليس لديك حساب؟ '),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen())),
                        child: Text('سجل الآن'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
