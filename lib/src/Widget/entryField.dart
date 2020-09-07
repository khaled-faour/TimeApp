import 'package:flutter/material.dart';

Widget entryField(String title, BuildContext context,
    {bool isPassword = false,
    String hintText,
    TextEditingController controller}) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Theme.of(context).textTheme.bodyText1.color),
        ),
        SizedBox(
          height: 10,
        ),
        TextField(
          style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color),
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
                color:
                    MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? Colors.black
                        : Colors.grey),
            border: InputBorder.none,
            fillColor:
                MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? Colors.grey[800]
                    : Color(0xfff3f3f4),
            filled: true,
          ),
        )
      ],
    ),
  );
}
