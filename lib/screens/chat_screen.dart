import 'package:flutter/material.dart';
import 'package:flutter_chat_app/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance.collection('massege');

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String currentuser = '';
  final texteditingcontroller = TextEditingController();
  late String massegetext;
  final _auth = FirebaseAuth.instance;
  late User logginginuser;
  @override
  void initState() {
    super.initState();
    getloging();
  }

  void getloging() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        logginginuser = user;
        print('logging user email= ${logginginuser.email}');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
                stream: _firestore.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.hasError) {
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.lightBlueAccent,
                      ),
                    );
                  }
                  List<Widget> newwidget = [];
                  snapshot.data!.docs.reversed.map((DocumentSnapshot document) {
                    var data = document.data()! as Map<String, dynamic>;
                    currentuser = logginginuser.email.toString();
                    newwidget.add(massegebubble(
                      sender: data['sender'],
                      textmassege: data['text'],
                      isMe: currentuser == data['sender'],
                    ));
                  }).toList();
                  newwidget = newwidget.reversed.toList();
                  return Expanded(
                    child: ListView(
                      reverse: true,
                      children: newwidget,
                    ),
                  );
                }),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: texteditingcontroller,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      onChanged: (value) {
                        massegetext = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      texteditingcontroller.clear();
                      _firestore.add({
                        'sender': logginginuser.email,
                        'text': massegetext,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class massegebubble extends StatelessWidget {
  massegebubble(
      {required this.sender, required this.textmassege, required this.isMe});
  String sender;
  String textmassege;
  bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          Material(
            elevation: 5,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
              topLeft: isMe ? Radius.circular(30) : Radius.zero,
              topRight: isMe ? Radius.zero : Radius.circular(30),
            ),
            color: isMe ? Colors.blueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Text(
                textmassege,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
