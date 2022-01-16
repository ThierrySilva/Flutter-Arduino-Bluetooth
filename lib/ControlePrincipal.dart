// ignore_for_file: file_names
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:layout/components/ButtonDouble.dart';
import 'package:layout/components/ButtonSingle.dart';

import 'components/VoiceButtonPage.dart';

class ControlePrincipalPage extends StatefulWidget {
  final BluetoothDevice? server;
  const ControlePrincipalPage({this.server});

  @override
  _ControlePrincipalPage createState() => _ControlePrincipalPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ControlePrincipalPage extends State<ControlePrincipalPage> {
  static const clientID = 0;
  BluetoothConnection? connection;
  String? language;

  // ignore: deprecated_member_use
  List<_Message> messages = <_Message>[];
  String _messageBuffer = '';

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();

  bool isConnecting = true;
  bool get isConnected => connection != null && connection!.isConnected;

  bool isDisconnecting = false;
  bool buttonClicado = false;

  List<String> _languages = ['en_US', 'es_ES', 'pt_BR'];

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server!.address).then((_connection) {
      print('Connected to device');
      connection = _connection;
      setState(() {
        
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnected localy!');
        } else {
          print('Disconnected remote!');
        }
        if (mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Failed to connect, something is wrong!');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection!.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    messages.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
                (text) {
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(_message.text.trim()),
                style: const TextStyle(color: Colors.white)),
            padding: const EdgeInsets.all(12.0),
            margin: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color:
                    _message.whom == clientID ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        mainAxisAlignment: _message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
      );
    }).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(children: [
                          Container(
                              height: 60, width: 90, child: SizedBox.shrink())
                        ]),
                        const SizedBox(width: 30),
                        Column(children: [
                          Container(
                            height: 60,
                            width: 90,
                            child: VoiceButtonComponent(
                                connection: connection,
                                clientID: clientID,
                                languageSelected: language),
                          ),
                        ]),
                        const SizedBox(width: 30),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                child: DropdownButton<String>(
                                  value: language == null ? 'pt_BR' : language,
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  items: _languages.map((String items) {
                                    return DropdownMenuItem(
                                      value: items,
                                      child: Text(items),
                                    );
                                  }).toList(),
                                  // After selecting the desired option,it will
                                  // change button value to selected value
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      language = newValue!;
                                    });
                                  },
                                ),
                              )
                            ]),
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(children: [
                          ButtonDoubleComponent(
                            buttonName: "A/B",
                            comandOn: 'a',
                            comandOff: 'b',
                            clientID: clientID,
                            connection: connection,
                          ),
                        ]),
                        const SizedBox(width: 30),
                        Column(children: [
                          ButtonDoubleComponent(
                            buttonName: "C/D",
                            comandOn: 'c',
                            comandOff: 'd',
                            clientID: clientID,
                            connection: connection,
                          ),
                        ]),
                        const SizedBox(width: 30),
                        Column(children: [
                          ButtonDoubleComponent(
                            buttonName: "E/F",
                            comandOn: 'e',
                            comandOff: 'f',
                            clientID: clientID,
                            connection: connection,
                          ),
                        ]),
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(children: [
                          ButtonDoubleComponent(
                            buttonName: "G/H",
                            comandOn: 'g',
                            comandOff: 'h',
                            clientID: clientID,
                            connection: connection,
                          ),
                        ]),
                        const SizedBox(width: 30),
                        Column(children: [
                          ButtonDoubleComponent(
                            buttonName: "I/J",
                            comandOn: 'i',
                            comandOff: 'j',
                            clientID: clientID,
                            connection: connection,
                          ),
                        ]),
                        const SizedBox(width: 30),
                        Column(children: [
                          ButtonDoubleComponent(
                            buttonName: "K/L",
                            comandOn: 'k',
                            comandOff: 'l',
                            clientID: clientID,
                            connection: connection,
                          ),
                        ]),
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(children: [
                          ButtonDoubleComponent(
                            buttonName: "M/N",
                            comandOn: 'm',
                            comandOff: 'n',
                            clientID: clientID,
                            connection: connection,
                          ),
                        ]),
                        const SizedBox(width: 30),
                        Column(children: [
                          ButtonDoubleComponent(
                            buttonName: "O/P",
                            comandOn: 'o',
                            comandOff: 'p',
                            clientID: clientID,
                            connection: connection,
                          ),
                        ]),
                        const SizedBox(width: 30),
                        Column(children: [
                          ButtonDoubleComponent(
                            buttonName: "Q/R",
                            comandOn: 'q',
                            comandOff: 'r',
                            clientID: clientID,
                            connection: connection,
                          ),
                        ]),
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(children: [
                          ButtonDoubleComponent(
                            buttonName: "S/T",
                            comandOn: 's',
                            comandOff: 't',
                            clientID: clientID,
                            connection: connection,
                          ),
                        ]),
                        const SizedBox(width: 30),
                        Column(children: [
                          ButtonDoubleComponent(
                            buttonName: "U/V",
                            comandOn: 'u',
                            comandOff: 'v',
                            clientID: clientID,
                            connection: connection,
                          ),
                        ]),
                        const SizedBox(width: 30),
                        Column(children: [
                          ButtonDoubleComponent(
                            buttonName: "W/X",
                            comandOn: 'w',
                            comandOff: 'x',
                            clientID: clientID,
                            connection: connection,
                          ),
                        ]),
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(children: [
                          ButtonDoubleComponent(
                            buttonName: "Y/Z",
                            comandOn: 'y',
                            comandOff: 'z',
                            clientID: clientID,
                            connection: connection,
                          ),
                        ]),
                        const SizedBox(width: 30),
                        Column(children: [
                          ButtonDoubleComponent(
                            buttonName: "0/1",
                            comandOn: '0',
                            comandOff: '1',
                            clientID: clientID,
                            connection: connection,
                          ),
                        ]),
                        const SizedBox(width: 30),
                        Column(children: [
                          ButtonDoubleComponent(
                            buttonName: "2/3",
                            comandOn: '2',
                            comandOff: '3',
                            clientID: clientID,
                            connection: connection,
                          ),
                        ]),
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(children: [
                          ButtonDoubleComponent(
                            buttonName: "4/5",
                            comandOn: '4',
                            comandOff: '5',
                            clientID: clientID,
                            connection: connection,
                          ),
                        ]),
                        const SizedBox(width: 30),
                        Column(children: [
                          ButtonDoubleComponent(
                            buttonName: "6/7",
                            comandOn: '6',
                            comandOff: '7',
                            clientID: clientID,
                            connection: connection,
                          ),
                        ]),
                        const SizedBox(width: 30),
                        Column(children: [
                          ButtonDoubleComponent(
                            buttonName: "8/9",
                            comandOn: '8',
                            comandOff: '9',
                            clientID: clientID,
                            connection: connection,
                          ),
                        ]),
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(children: [
                          ButtonSingleComponent(
                            buttonName: "+",
                            comandOn: '+',
                            colorButton: Color.fromRGBO(238, 57, 61, 1),
                            clientID: clientID,
                            connection: connection,
                          ),
                        ]),
                        const SizedBox(width: 10),
                        Column(children: [
                          ButtonSingleComponent(
                            buttonName: "-",
                            comandOn: '-',
                            colorButton: Color.fromRGBO(8, 164, 113, 1),
                            clientID: clientID,
                            connection: connection,
                          ),
                        ]),
                        const SizedBox(width: 10),
                        Column(children: [
                          ButtonSingleComponent(
                            buttonName: "*",
                            comandOn: '*',
                            colorButton: Color.fromRGBO(239, 206, 45, 1),
                            clientID: clientID,
                            connection: connection,
                          ),
                        ]),
                        const SizedBox(width: 10),
                        Column(children: [
                          ButtonSingleComponent(
                            buttonName: "/",
                            comandOn: '/',
                            colorButton: Color.fromRGBO(49, 86, 188, 1),
                            clientID: clientID,
                            connection: connection,
                          ),
                        ]),
                      ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    for (var byte in data) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    }
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }
}
