import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

final _auth=FirebaseAuth.instance;
final _firestore=FirebaseFirestore.instance;
User loggedinUser;
bool isMe=false;

class ChatScreen extends StatefulWidget {
  static const String id='chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String messageText;
  final messageController=TextEditingController();

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });
    getCurrentUser();
  }

  void getCurrentUser () async
  {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedinUser = user;
        getMessage();
      }
    }
    catch(e){
      print(e);
    }
  }

  void getMessage() async{
    final messages= await _firestore.collection('messages').get();

    for( var message in messages.docs)
    {
      print(message.data());
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
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(

                    child: TextField(
                      controller: messageController,
                      onChanged: (value) {
                        messageText=value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageController.clear();
                      if(messageText!='') {
                        _firestore.collection('messages').add({
                          'sender': loggedinUser.email,
                          'text': messageText,
                          'date': DateTime.now().toIso8601String().toString(),
                        });
                      }
                      messageText='';
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

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').orderBy('date').snapshots(),
      builder: (context,snapshot){
        if(snapshot.hasData) {
          final messages = snapshot.data.docs.reversed;
          List<MessageBubble> messageWidget = [];
          for (var message in messages) {
            final messageText = message.data()['text'];
            final messageSender = message.data()['sender'];
            if(messageSender==loggedinUser.email)
              isMe=true;
            else
              isMe=false;
            messageWidget.add(MessageBubble(text: messageText,sender: messageSender,isMe:isMe));
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(vertical: 20.0,horizontal: 10.0),
              children: messageWidget,
            ),
          );
        }
        return Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.blueAccent,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {

  MessageBubble({this.text,this.sender,this.isMe});

  final String text;
  final String sender;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe? CrossAxisAlignment.end: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(
                fontSize: 12.0,
                color: Colors.black54
            ),
          ),
          Material(
            elevation: 5.0,
            color: isMe? Colors.lightBlueAccent: Colors.white,
            borderRadius: isMe ? BorderRadius.only(topLeft: Radius.circular(30.0),bottomLeft: Radius.circular(30.0),bottomRight: Radius.circular(30.0)):
            BorderRadius.only(topRight: Radius.circular(30.0),bottomLeft: Radius.circular(30.0),bottomRight: Radius.circular(30.0)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                    color: isMe? Colors.white: Colors.black87,
                    fontSize: 15.0
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
