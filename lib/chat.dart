import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<dynamic> _messages = [];
  int? _chatId;
  int? _userId;
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _timer; // مؤقت التحديث التلقائي

  @override
  void initState() {
    super.initState();
    _initializeChat();
    Future.delayed(Duration(milliseconds: 300), () {
      FocusScope.of(context).requestFocus(_focusNode); // فتح الكيبورد تلقائيًا
    });

    // تحديث الرسائل كل 10 ثوانٍ
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _loadMessages();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    _timer?.cancel(); // إيقاف التحديث عند مغادرة الصفحة
    super.dispose();
  }

  Future<void> _initializeChat() async {
    final prefs = await SharedPreferences.getInstance();
    _chatId = prefs.getInt('chat_id');
    final userJson = prefs.getString('user');
    if (userJson != null) {
      _userId = jsonDecode(userJson)['id'];
    }

    await _loadMessages();
  }

  Future<void> _refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    if (refreshToken == null) return;

    final response = await http.post(
      Uri.parse(
        'https://smart-analysis-of-health-condition.onrender.com/api/token/refresh/',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      prefs.setString('access_token', data['access']);
    }
  }

  bool _isLoading = false; // قفل لمنع التكرار

  Future<void> _loadMessages() async {
    if (_chatId == null || _isLoading) return;

    _isLoading = true;

    try {
      await _refreshAccessToken();
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      final response = await http.get(
        Uri.parse(
          'https://smart-analysis-of-health-condition.onrender.com/api/chats/$_chatId/messages/',
        ),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _messages = data.reversed.toList();
        });
      }
    } catch (e) {
      print("Error loading messages: $e");
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _chatId == null) return;

    // setState(() {
    //   _messages.insert(0, {'content': content, 'sender': _userId});
    // });

    _messageController.clear();
    await _refreshAccessToken();

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    final response = await http.post(
      Uri.parse(
        'https://smart-analysis-of-health-condition.onrender.com/api/chats/$_chatId/messages/send/',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'chat': _chatId, 'content': content}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      await _loadMessages();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل في إرسال الرسالة')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الدردشة'),
        backgroundColor: Color(0xFFFFDDDD),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMine = message['sender'] == _userId;
                return Align(
                  alignment:
                      isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    margin: EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isMine ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message['content'],
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالتك...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: Text('إرسال'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFAAAA),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
