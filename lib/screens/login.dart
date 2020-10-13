import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:txapita/helpers/screen_navigation.dart';
import 'package:txapita/helpers/style.dart';
import 'package:txapita/providers/user.dart';
import 'package:txapita/screens/registration.dart';
import 'package:txapita/widgets/custom_text.dart';
import 'package:txapita/widgets/loading.dart';

import 'home.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      key: _key,
      backgroundColor: Colors.deepOrange,
      body: authProvider.status == Status.Authenticating? Loading() : SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              color: white,
              height: 100,
            ),

            Container(
              color: white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset("images/lg.png", width: 230, height: 230,),
                ],
              ),
            ),

            Container(
              height: 60,
              color: white,
            ),
           SizedBox(
             height: 20,
           ),
           Padding(
             padding: const EdgeInsets.all(12),
             child: Container(
               decoration: BoxDecoration(
                 border: Border.all(color: white),
                 borderRadius: BorderRadius.circular(5)
               ),
               child: Padding(padding: EdgeInsets.only(left: 10),
               child: TextFormField(
                 controller: authProvider.email,
                 decoration: InputDecoration(
                   hintStyle: TextStyle(color: white),
                     border: InputBorder.none,
                     hintText: "Email",
                     icon: Icon(Icons.email, color: white,)
                 ),
               ),),
             ),
           ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: white),
                    borderRadius: BorderRadius.circular(5)
                ),
                child: Padding(padding: EdgeInsets.only(left: 10),
                  child: TextFormField(
                    controller: authProvider.password,
                    decoration: InputDecoration(
                        hintStyle: TextStyle(color: white),
                        border: InputBorder.none,
                        hintText: "Password",
                        icon: Icon(Icons.lock, color: white,)
                    ),
                  ),),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: GestureDetector(
                onTap: ()async{
                  if(!await authProvider.signIn()){
                    _key.currentState.showSnackBar(
                      SnackBar(content: Text("Login failed!"))
                    );
                    return;
                  }
                  authProvider.clearController();
                  changeScreenReplacement(context, MyHomePage());
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: black,
                      borderRadius: BorderRadius.circular(5)
                  ),
                  child: Padding(padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CustomText(text: "Login", color: white, size: 22,)
                      ],
                    ),),
                ),
              ),
            ),

            GestureDetector(
              onTap: (){
                changeScreen(context, RegistrationScreen());
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CustomText(text: "Register here", size: 20,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
