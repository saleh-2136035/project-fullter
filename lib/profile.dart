import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfileScreen extends StatefulWidget {
  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  Map<String, dynamic> _profileData = {};
  bool _isEditing = false;

  TextEditingController usernameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController healthDataController = TextEditingController();

  Future<void> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');

    if (refreshToken == null) return;

    final url = 'https://smart-analysis-of-health-condition.onrender.com/api/token/refresh/';
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refresh": refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      prefs.setString('access_token', data['access']);
    }
  }

  Future<void> fetchProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await refreshAccessToken();

    final accessToken = prefs.getString('access_token');
    final patient = prefs.getString('patient');
    final user = prefs.getString('user');

    if (accessToken == null || patient == null || user == null) return;

    final patientId = jsonDecode(patient)['id'];
    final userId = jsonDecode(user)['id'];

    final url = 'https://smart-analysis-of-health-condition.onrender.com/api/get_patinet/$patientId/';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        _profileData = data;

        // تعبئة البيانات في الحقول
        usernameController.text = data['user']['username'] ?? '';
        firstNameController.text = data['user']['first_name'] ?? '';
        lastNameController.text = data['user']['last_name'] ?? '';
        emailController.text = data['user']['email'] ?? '';
        ageController.text = data['patinet']['age']?.toString() ?? '';
        genderController.text = data['patinet']['gender'] ?? '';
        healthDataController.text = data['patinet']['healthdataa'] ?? '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: Color(0xFFFFDDDD),
      ),
      body: _profileData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        buildTextField('Username', usernameController),
                        buildTextField('First Name', firstNameController),
                        buildTextField('Last Name', lastNameController),
                        buildTextField('Email', emailController),
                        buildTextField('Age', ageController, keyboardType: TextInputType.number),
                        buildTextField('Gender', genderController),
                        buildTextField('Health Condition', healthDataController),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _isEditing = !_isEditing);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFDDDD),
                          ),
                          child: Text(
                            _isEditing ? 'Cancel' : 'Edit',
                            style: TextStyle(color: Color(0xFF7B0000)),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isEditing ? saveProfileData : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFDDDD),
                          ),
                          child: Text(
                            'Save',
                            style: TextStyle(color: Color(0xFF7B0000)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        enabled: _isEditing,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Future<void> saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await refreshAccessToken();

    final accessToken = prefs.getString('access_token');
    final patientData = prefs.getString('patient');
    final userData = prefs.getString('user');

    if (accessToken == null || patientData == null || userData == null) return;

    final patientId = jsonDecode(patientData)['id'];
    final userId = jsonDecode(userData)['id'];

    final userUrl = 'https://smart-analysis-of-health-condition.onrender.com/api/update_user_data/$userId/';
    final patientUrl = 'https://smart-analysis-of-health-condition.onrender.com/api/update_patient_data/$patientId/';

    try {
      final userRes = await http.patch(
        Uri.parse(userUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': usernameController.text,
          'first_name': firstNameController.text,
          'last_name': lastNameController.text,
          'email': emailController.text,
        }),
      );

      final patientRes = await http.patch(
        Uri.parse(patientUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'age': int.tryParse(ageController.text),
          'gender': genderController.text,
          'healthdataa': healthDataController.text,
        }),
      );

      if (userRes.statusCode == 200 && patientRes.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Profile updated successfully"),
          backgroundColor: Colors.teal,
        ));
        setState(() => _isEditing = false);
        fetchProfileData(); // إعادة تحميل البيانات
      } else {
        throw Exception('Failed to update');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error updating profile"),
        backgroundColor: Colors.red,
      ));
    }
  }
}
