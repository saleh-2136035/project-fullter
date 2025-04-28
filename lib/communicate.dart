import 'package:flutter/material.dart';
import 'profile.dart'; // استيراد صفحة البروفايل
import 'home_page.dart';
import 'sign up.dart';
import 'appintments.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [
    {'text': 'hello.', 'sender': 'Doctor'},
    {'text': 'Hi, My name is Turki', 'sender': 'You'},
    {'text': 'how are you Turki?', 'sender': 'Doctor'},
    {'text': 'I am fine thank you', 'sender': 'You'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('D. Ali Saleh'),
        backgroundColor: Color(0xFFFFDDDD),
        actions: [
          // أيقونة البروفايل
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyProfileScreen()),
              );
            },
          ),
          // أيقونة القائمة (Menu)
          Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  // عند الضغط على أيقونة القائمة (Menu)، سيتم فتحها من الأسفل
                  _openDrawer(context);
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Messages List
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: messages[index]['sender'] == 'Doctor'
                          ? Alignment.topLeft
                          : Alignment.topRight,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: messages[index]['sender'] == 'Doctor'
                              ? Colors.pink[100]
                              : Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          messages[index]['text']!,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Text Input and Send Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.pink),
                    onPressed: () {
                      setState(() {
                        if (_controller.text.isNotEmpty) {
                          messages.add({
                            'text': _controller.text,
                            'sender': 'You',
                          });
                          _controller.clear();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  // وظيفة لفتح Drawer من الأسفل إلى الأعلى
  void _openDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: Color(0xFFFFDDDD),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              title: Text(
                'Home',
                style: TextStyle(color: Color(0xFF7B0000), fontSize: 18),
              ),
              tileColor: Color(0xFFFFDDDD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen1()),
                );
              },
            ),
            Divider(),
            ListTile(
              title: Text(
                'My Profile',
                style: TextStyle(color: Color(0xFF7B0000), fontSize: 18),
              ),
              tileColor: Color(0xFFFFDDDD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyProfileScreen()),
                );
              },
            ),
            Divider(),
            ListTile(
              title: Text(
                'My Appointments',
                style: TextStyle(color: Color(0xFF7B0000), fontSize: 18),
              ),
              tileColor: Color(0xFFFFDDDD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyAppointments()),
                );
              },
            ),
            Divider(),
            ListTile(
              title: Text(
                'Logout',
                style: TextStyle(color: Color(0xFF7B0000), fontSize: 18),
              ),
              tileColor: Color(0xFFFFDDDD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

