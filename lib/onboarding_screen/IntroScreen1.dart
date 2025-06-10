import 'package:flutter/material.dart';

class IntrosScreen1 extends StatelessWidget {
  const IntrosScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Center(
              child: Image.asset("assets/images/first.png"),
            ),
          ),
          SizedBox(height: 12,),

          const Text("find friends",style: TextStyle(fontSize: 24,fontWeight: FontWeight.w800),),
          SizedBox(height: 10,),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              "Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit.",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),),
          )
        ],
      ),
    );
  }
}