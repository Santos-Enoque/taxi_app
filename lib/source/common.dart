import 'package:flutter/material.dart';
changeScreen(BuildContext context,Widget widget){
  Navigator.push(context, MaterialPageRoute(builder: (_)=> widget));
}