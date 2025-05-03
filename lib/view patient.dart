import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ViewPatientScreen extends StatefulWidget {
  @override
  _ViewPatientScreenState createState() => _ViewPatientScreenState();
}

class _ViewPatientScreenState extends State<ViewPatientScreen> {
  List<dynamic> appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final doctor = prefs.getString('doctor');
      final refreshToken = prefs.getString('refresh_token');
      if (doctor == null || refreshToken == null) return;

      final doctorID = jsonDecode(doctor)['id'];

      final refreshRes = await http.post(
        Uri.parse('https://smart-analysis-of-health-condition.onrender.com/api/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (refreshRes.statusCode == 200) {
        final newAccess = jsonDecode(refreshRes.body)['access'];
        prefs.setString('access_token', newAccess);

        final res = await http.get(
          Uri.parse('https://smart-analysis-of-health-condition.onrender.com/api/doctor_appintments/$doctorID/'),
          headers: {'Authorization': 'Bearer $newAccess'},
        );

        if (res.statusCode == 200) {
          final data = jsonDecode(utf8.decode(res.bodyBytes));
          setState(() {
            appointments = data['appointments'];
            isLoading = false;
          });
        } else {
          print('Failed to fetch appointments');
        }
      } else {
        print('Failed to refresh token');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'available' ? Colors.green : Colors.red;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('صفحة مواعيد الدكتور'),
        backgroundColor: Color(0xFFFFDDDD),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : appointments.isEmpty
              ? Center(child: Text('لا توجد مواعيد حالياً.'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'هذه صفحة المواعيد الخاصة بك، يمكنك الإطلاع على جميع المواعيد القادمة والتفاعل معها.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: appointments.length,
                        itemBuilder: (context, index) {
                          final appointment = appointments[index];
                          final patient = appointment['patientID'];
                          final user = patient != null ? patient['userID'] : null;
                          final status = appointment['status'];

                          return Card(
                            margin: EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            color: Color(0xFFFFEEEE),
                            child: ListTile(
                              title: Text(
                                'Date: ${appointment['date']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text('Time: ${appointment['time']}'),
                                  SizedBox(height: 4),
                                  _buildStatusBadge(status),
                                  if (user != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text('Patient: ${user['first_name']} ${user['last_name']}'),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.info, color: Colors.blue),
                                    onPressed: () {
                                      _showDetailsDialog(context, appointment);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.chat, color: Colors.black54),
                                    onPressed: () {
                                      // لاحقًا: الانتقال إلى صفحة الشات
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> appointment) {
    final patient = appointment['patientID'];
    final user = patient != null ? patient['userID'] : null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Appointment Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Date:', appointment['date']),
              _buildDetailRow('Time:', appointment['time']),
              _buildDetailRow('Status:', appointment['status']),
              if (user != null) ...[
                Divider(),
                _buildDetailRow('Name:', '${user['first_name']} ${user['last_name']}'),
                _buildDetailRow('Email:', user['email']),
                _buildDetailRow('Gender:', patient['gender']),
                _buildDetailRow('Age:', patient['age'].toString()),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(child: Text(value, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
