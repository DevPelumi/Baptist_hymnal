import 'package:flutter/material.dart';

class ComingSoonWidget extends StatelessWidget {
  const ComingSoonWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0,100,0,0),
      child: Column(
        children: [
          Center(
            child: Container(
              height: 200.0,
              width: 200.0,
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.pink.shade100,
              ),
              child: const Align(
                alignment: Alignment.center,
                child: Icon(Icons.auto_stories,
                  size: 70,
                  color: const Color(0xFFF06292) ,
                ),
              ),
            ),
          ),
          SizedBox(height: 40),
          Text('Coming Soon!',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Alata',
          fontSize:22,)
            ,)
        ],
      ),
    );
  }
}
