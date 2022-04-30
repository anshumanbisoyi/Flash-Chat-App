import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flast_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
late User loggedInUser;

class ChatScreen extends StatefulWidget {
  static String id = '/Chat';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messaggeTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  late String message;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Firebase.initializeApp().whenComplete(() {
    //   print("completed");
    //   setState(() {});
    // });
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  void messagesStream() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        print(message.metadata);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                messagesStream();
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text(
          'FlashChat',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.yellow.shade700,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messaggeTextController,
                      onChanged: (value) {
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messaggeTextController.clear();
                      _firestore.collection('messages').add({
                        'text': message,
                        'sender': loggedInUser.email,
                        'time': FieldValue.serverTimestamp() //added
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

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('messages')
          .orderBy('time', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(backgroundColor: Colors.yellow),
          );
        }
        final messages = snapshot.data?.docs.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages!) {
          final messageText = (message.data() as Map<String, dynamic>)['text'];
          final messageSender =
              (message.data() as Map<String, dynamic>)['sender'];
          final messageTime =
              (message.data() as Map<String, dynamic>)['time']; //added this

          final currentUser = loggedInUser.email;

          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: currentUser == messageSender,
            time: messageTime,
          );
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
              reverse: true, //sticky towrds to bottom
              padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
              children: messageBubbles),
        );

        return const SizedBox();
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({
    this.sender = '',
    this.text = '',
    this.isMe = false,
    Timestamp? time,
  }); //Timestamp? time

  late final String sender;
  late final String text;
  late final bool isMe;
  late final Timestamp time;

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
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(27.0),
                    bottomLeft: Radius.circular(27.0),
                    bottomRight: Radius.circular(27.0))
                : BorderRadius.only(
                    topRight: Radius.circular(27.0),
                    bottomLeft: Radius.circular(27.0),
                    bottomRight: Radius.circular(27.0)),
            elevation: 5.0,
            color: isMe ? Colors.yellow.shade700 : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 11.0, vertical: 11.0),
              child: Text(
                '$text',
                style: TextStyle(
                    color: isMe ? Colors.white : Colors.black, fontSize: 18.0),
              ),
            ),
          ),
          // Text(
          //   '${DateTime.fromMillisecondsSinceEpoch(time.seconds * 1000).toString()}', // add this only if you want to show the time along with the email. If you dont want this then don't add this DateTime thing
          //   style: TextStyle(color: Colors.black54, fontSize: 10.0),
          // ),
        ],
      ),
    );
  }
}
