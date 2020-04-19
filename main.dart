//     <uses-permission android:name="android.permission.INTERNET"/>

//     <application
//         android:name="io.flutter.app.FlutterApplication"
//         android:label="socketflutter"
//         android:icon="@mipmap/ic_launcher"
//         android:usesCleartextTraffic="true">

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';

void main() => runApp(
  MaterialApp(
    home: ChatPage(),
  )
);

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  SocketIO socketIO;
  List messages;
  double height, width;
  TextEditingController textController;
  ScrollController scrollController;

  @override
  void initState() {
    messages = List();
    textController = TextEditingController();
    scrollController = ScrollController();

    socketIO = SocketIOManager().createSocketIO(
      'http://:3000',
      '/',
    )
      ..init()
      ..subscribe('receive_message', (jsonData) async{
          await Future.microtask(() async{
            return await json.decode(jsonData);
          }).then((data){
            this.setState(() => messages.add(data));
            return;
          }).then((_){
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 600),
              curve: Curves.ease,
            );
            return;
          });
      })
      ..connect();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: height * 0.1),
            Container(
              height: height * 0.8,
              width: width,
              child: ListView.builder(
                controller: scrollController,
                itemCount: messages.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    alignment: messages[index]['name'] == "James"
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      margin: const EdgeInsets.only(bottom: 20.0, left: 20.0),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        messages[index]['message'],
                        style: TextStyle(color: Colors.white, fontSize: 15.0),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              height: height * 0.1,
              width: width,
              child: Row(
                children: <Widget>[
                  Container(
                    width: width * 0.7,
                    padding: const EdgeInsets.all(2.0),
                    margin: const EdgeInsets.only(left: 40.0),
                    child: TextField(
                      decoration: InputDecoration.collapsed(
                        hintText: 'Send a message...',
                      ),
                      controller: textController,
                    ),
                  ),
                  FloatingActionButton(
                    backgroundColor: Colors.deepPurple,
                    onPressed: () async{
                      if (textController.text.isNotEmpty) {
                        //Send the message as JSON data to send_message event
                        await Future.microtask((){
                          socketIO.sendMessage(
                              'send_message', json.encode(
                              {
                                "message": textController.text,
                                "name" :"James"
                              }
                          ));
                          return;
                        }).then((_){
                          this.setState((){});
                          textController.text = '';
                          return;
                        }).then((_){
                          scrollController.animateTo(
                            scrollController.position.maxScrollExtent,
                            duration: Duration(milliseconds: 600),
                            curve: Curves.ease,
                          );
                        });
                      }
                    },
                    child: Icon(
                      Icons.send, size: 30,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
