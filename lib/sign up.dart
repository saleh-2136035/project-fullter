import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/login.dart';
import 'login.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '',
      home: SignUpScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

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
  final TextEditingController _genderController = TextEditingController();

  bool _isLoading = false;

  bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegExp.hasMatch(email);
  }

  Future<void> createUser(BuildContext context) async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _genderController.text.isEmpty) {
      showMessage(context, "جميع الحقول مطلوبة");
      return;
    }

    if (!isValidEmail(_emailController.text)) {
      showMessage(context, "يرجى إدخال بريد إلكتروني صالح");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      showMessage(context, "كلمات المرور غير متطابقة");
      return;
    }

    final String url = 'https://smart-analysis-of-health-condition.onrender.com/api/create_user/';

    final Map<String, dynamic> userData = {
      "first_name": _firstNameController.text,
      "last_name": _lastNameController.text,
      "username": _usernameController.text,
      "age": _ageController.text,
      "gender": _genderController.text,
      "email": _emailController.text,
      "password1": _passwordController.text,
      "password2": _confirmPasswordController.text,
      "role": "patient",
    };

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        showMessage(context, responseData['message']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else if (response.statusCode == 400) {
        showMessage(context, responseData['message']);
      } else {
        showMessage(context, 'حدث خطأ أثناء إنشاء الحساب');
      }
    } catch (e) {
      showMessage(context, "تعذر الاتصال بالخادم");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.teal,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('إنشاء حساب'),
          backgroundColor: const Color(0xFFFFDDDD),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'تسجيل حساب جديد',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'الاسم الأول', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'اسم العائلة', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'اسم المستخدم', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: 'العمر', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _genderController,
                  decoration: const InputDecoration(labelText: 'الجنس', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'البريد الإلكتروني', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'كلمة المرور', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => createUser(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFDDDD),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('تسجيل', style: TextStyle(color: Color(0xFF7B0000), fontSize: 18)),
                        ),
                      ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  child: const Text(
                    'لديك حساب؟ تسجيل الدخول',
                    style: TextStyle(fontSize: 16, color: Colors.teal),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
