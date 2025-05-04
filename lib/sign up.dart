import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/login.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      home: SignUpScreen(),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _gendrController = TextEditingController();

  // دالة للتحقق من صحة البريد الإلكتروني
  bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegExp.hasMatch(email);
  }

  // دالة لإرسال البيانات إلى API
  Future<void> createUser(BuildContext context) async {
    final String url = 'https://smart-analysis-of-health-condition.onrender.com/api/create_user/';

    final Map<String, dynamic> userData = {
      "first_name": _firstNameController.text,
      "last_name": _lastNameController.text,
      "username": _usernameController.text,
      "age":_ageController.text,
      "gender":_gendrController.text,
      "email": _emailController.text,
      "password1": _passwordController.text,
      "password2": _confirmPasswordController.text,
      "role": "patient", // ثابت "مريض"
    };

    // تحقق من البيانات المدخلة
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty || _usernameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty ||_ageController.text.isEmpty||_gendrController.text.isEmpty) {
      showMessage(context, "All fields are required.");
      return;
    }

    if (!isValidEmail(_emailController.text)) {
      showMessage(context, "Please enter a valid email.");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      showMessage(context, "Passwords do not match.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(userData),
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        showMessage(context, responseData['message']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),  // تأكد من أنك استوردت صفحة LoginScreen
        );
      } else if (response.statusCode == 400) {
        showMessage(context, responseData['message']);
      } else {
        showMessage(context, 'An error occurred while creating the user.');
      }
    } catch (e) {
      showMessage(context, "An error occurred while connecting to the server.");
    }
  }

  // عرض الرسالة للمستخدم
  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 18)),
        backgroundColor: Colors.teal,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Color(0xFFFFDDDD),
      ),
      body: SafeArea(
        child: SingleChildScrollView(  // إضافة ScrollView لتمرير الصفحة
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Sign up',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _gendrController,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () {
                    createUser(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFDDDD),
                  ),
                  child: Text('Sign up', style: TextStyle(color: Color(0xFF7B0000))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
