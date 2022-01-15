import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_speech/flutter_speech.dart';


class VoiceButtonComponent extends StatefulWidget {
  final BluetoothConnection? connection;
  final int clientID;
  final String? languageSelected;
  const VoiceButtonComponent({
    Key? key,
    this.connection,
    this.languageSelected,
    required this.clientID,
  }) : super(key: key);
  _VoiceButtonState createState() => _VoiceButtonState();  
}

class Language {
  final String name;
  final String code;

  const Language(this.name, this.code);
}

const languages = const [
  const Language('English', 'en_US'),
  const Language('Español', 'es_ES'),
  const Language('Portugues', 'pt_BR'),
];

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}


class _VoiceButtonState extends State<VoiceButtonComponent> {
  bool buttonClicado = false;
  final TextEditingController textEditingController = TextEditingController();
  List<_Message> messages = <_Message>[];
  
  late SpeechRecognition _speech;
  bool _speechRecognitionAvailable = false;
  bool _isListening = false;

  @override
  initState() {
    super.initState();
    activateSpeechRecognizer();
  }

  void activateSpeechRecognizer() {
    print('_MyAppState.activateSpeechRecognizer... ');
    _speech = SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    _speech.setErrorHandler(errorHandler);
    _speech.activate(languages.firstWhere((l) => l.code == (widget.languageSelected == null ? 'pt_BR' : widget.languageSelected!)).code).then((res) {
      setState(() => _speechRecognitionAvailable = res);
    });
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


  void start() => _speech.activate(
    languages.firstWhere((l) => l.code == (widget.languageSelected == null ? 'pt_BR' : widget.languageSelected!)).code).then((_) {
        return _speech.listen().then((result) {
          print('_MyAppState.start => result $result');
          setState(() {
            _isListening = result;
          });
        });
      });

  void cancel() =>
      _speech.cancel().then((_) => setState(() => _isListening = false));

  void stop() => _speech.stop().then((_) {
        setState(() => _isListening = false);
      });

  void onSpeechAvailability(bool result) =>
      setState(() => _speechRecognitionAvailable = result);


  void onRecognitionStarted() {
    setState(() => _isListening = true);
  }

  void onRecognitionResult(String text) {
    print('_MyAppState.onRecognitionResult... $text');
    _sendMessage(text);
  }

  void onRecognitionComplete(String text) {
    print('_MyAppState.onRecognitionComplete... $text');
    setState(() => _isListening = false);
  }

  void errorHandler() => activateSpeechRecognizer();

  Widget build(BuildContext context) {
  return (ElevatedButton(          
          onPressed:  _speechRecognitionAvailable && !_isListening
                        ? () => start()
                        : null,                        
          child: Icon(
            _isListening
                        ? Icons.settings_voice
                        : Icons.settings_voice_outlined,                        
          ),
          style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),                          
                          primary: _isListening
                              ? Color.fromRGBO(255, 255, 0, 1)
                              : Colors.black),
          
        ));
  }

  

}