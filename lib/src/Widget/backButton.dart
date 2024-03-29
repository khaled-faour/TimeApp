import 'package:flutter/material.dart';

Widget backButton(BuildContext context) {
  return InkWell(
    onTap: () {
      Navigator.pop(context);
    },
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
            child: Icon(Icons.keyboard_arrow_left,
                color:
                    MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black),
          ),
          Text('Back',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.dark
                      ? Colors.white70
                      : Colors.black))
        ],
      ),
    ),
  );
}
