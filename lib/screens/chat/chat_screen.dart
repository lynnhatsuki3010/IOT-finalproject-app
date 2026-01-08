import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(text: "Hi Bobo! 🤖", isUser: true, time: "09:41"),
    ChatMessage(
      text: "Hello there! 👋 How can I assist you today?",
      isUser: false,
      time: "09:41",
    ),
    ChatMessage(
      text: "I just set up my Smartify account. What cool things can I do with it?",
      isUser: true,
      time: "09:41",
    ),
    ChatMessage(
      text: "Awesome! 🎉 With Smartify, you can control devices, set up automation, manage energy, and more! What are you interested in exploring first?",
      isUser: false,
      time: "09:41",
    ),
    ChatMessage(
      text: "Hmm, tell me about automation. How can I set it up?",
      isUser: true,
      time: "09:41",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1A20),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chat with Bobo',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: message.isUser ? _buildUserMessage(message) : _buildBotMessage(message),
    );
  }

  Widget _buildUserMessage(ChatMessage message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF5B7CFF),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            message.text,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          message.time,
          style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildBotMessage(ChatMessage message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF5B7CFF),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF2A2930),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Text(
                  message.text,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message.time,
                style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1A20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ask me anything ...',
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: const Color(0xFF2A2930),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF5B7CFF),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 22),
                onPressed: () {
                  // Send message logic
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String time;

  ChatMessage({required this.text, required this.isUser, required this.time});
}