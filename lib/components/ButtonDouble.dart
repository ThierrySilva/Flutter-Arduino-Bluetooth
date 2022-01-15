import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ButtonDoubleComponent extends StatefulWidget {
  final String? buttonName;
  final String? comandOn;
  final String? comandOff;
  final BluetoothConnection? connection;
  final int clientID;
  const ButtonDoubleComponent(
      {Key? key,
      this.buttonName,
      this.comandOn,
      this.comandOff,
      this.connection,
      required this.clientID})
      : super(key: key);
  _ButtonState createState() => _ButtonState();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ButtonState extends State<ButtonDoubleComponent> {
  bool buttonClicado = false;
  final TextEditingController textEditingController = TextEditingController();
  List<_Message> messages = <_Message>[];

  _changeButtonColor() {
    setState(() {
      buttonClicado = !buttonClicado;
    });
  }

  Widget build(BuildContext context) {
    return (Container(
        height: 60,
        width: 90,
        child: FlatButton(
          onPressed: () {
            _sendMessage(buttonClicado ? widget.comandOn! : widget.comandOff!);
            _changeButtonColor();
          },
          child: Text(
            widget.buttonName!,
            style: TextStyle(color: Colors.white),
          ),
          color: buttonClicado
              ? Color.fromRGBO(237, 46, 39, 1)
              : Color.fromRGBO(0, 0, 0, 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        )));
  }

  _sendMessage(text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        widget.connection!.output
            .add(Uint8List.fromList(utf8.encode(text + "\r\n")));
        await widget.connection!.output.allSent;

        setState(() {
          messages.add(_Message(widget.clientID, text));
        });
      } catch (e) {
        setState(() {});
      }
    }
  }
}
