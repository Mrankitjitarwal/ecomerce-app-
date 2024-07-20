import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpAndSupportPage extends StatelessWidget {
  final List<FaqItem> faqs = [
    FaqItem(
      question: 'How do I reset my password?',
      answer: 'To reset your password, go to the login page and click on the "Forgot Password" link.',
    ),
    FaqItem(
      question: 'How can I contact support?',
      answer: 'You can contact support by clicking on the "Contact Support" button below.',
    ),
    // Add more FAQs as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support'),
      ),
      body: ListView.builder(
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(faqs[index].question),
            subtitle: Text(faqs[index].answer),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          launch('mailto:jatt3335@gmail.com?subject=Help%20and%20Support');
        },
        child: Icon(Icons.email),
        tooltip: 'Contact Support',
      ),
    );
  }
}

class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});
}