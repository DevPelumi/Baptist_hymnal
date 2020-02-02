import 'package:flutter/material.dart';

final longString = '''
Lorem ipsum dolor sit amet, 
consectetur adipiscing elit, 
sed do eiusmod tempor incididunt 
ut labore et dolore magna aliqua. 

Ut enim ad minim veniam, 
quis nostrud exercitation ullamco 
laboris nisi ut aliquip ex ea 
commodo consequat.
''';

class Hymn1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(
                '',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Alata',
                ),
              ),
              Text(
                'Holy, Holy, Holy, Lord God Almighty!\n'
                ' Unto everlasting days our song shall rise to Thee;\n'
                ' Holy, Holy, Holy, Merciful and Mighty!\n'
                ' God in Three Persons, blessed Trinity!\n',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Alata',
                ),
              ),
              Text(
                'Holy, Holy, Holy, Lord God Almighty!\n'
                ' Unto everlasting days our song shall rise to Thee;\n'
                ' Holy, Holy, Holy, Merciful and Mighty!\n'
                ' God in Three Persons, blessed Trinity!\n',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Alata',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
