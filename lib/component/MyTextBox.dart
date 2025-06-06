import 'package:flutter/material.dart';

class Mytextbox extends StatelessWidget {
  final String sectionName;
  final String text;
  final VoidCallback?  onPressed;
  const Mytextbox({super.key, required this.sectionName, required this.text,  this.onPressed,  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8)

      ),
      padding: EdgeInsets.symmetric(horizontal: 8),
      margin: EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // userName
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(sectionName,style: TextStyle(color: Colors.grey),),
              Padding(
                padding: const EdgeInsets.only(top: 9,right: 4),
                child: IconButton(onPressed: onPressed, icon:  Icon( Icons.settings,color: Colors.grey,),),
              )
            ],
          ),

          //user bio
          Text(text,style: TextStyle(fontSize: 20),)
        ],
      ),
    );
  }
}
