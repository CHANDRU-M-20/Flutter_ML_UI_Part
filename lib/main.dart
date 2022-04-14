import 'package:flutter/material.dart';
import 'package:newui/page/home_page.dart';
void main(){
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  static final String title = 'Pick Image and Video';

  @override
  Widget build(BuildContext context) => MaterialApp(
    title:title,
    theme:ThemeData(primarySwatch:Colors.deepOrange),
    home:HomePage(),
  );

}