import 'package:flutter/material.dart';

class Introscreen2 extends StatelessWidget {
  const Introscreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 110),
            child: Center(
              child: Image.asset("assets/images/second.png"),

            ),
          ),
          SizedBox(height: 12,),

          const Text("Make connection",style: TextStyle(fontWeight: FontWeight.w800,fontSize: 24),),
          SizedBox(height: 10,),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Text("Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit.",
              style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),),
          )
        ],
      ),
    );
  }
}