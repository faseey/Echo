import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ButtonContainer extends StatefulWidget {
 final  String title;
 final IconData icon;
 final  VoidCallback onTab;
   ButtonContainer({super.key,required this.title,required this.icon, required this.onTab});

  @override
  State<ButtonContainer> createState() => _ButtonContainerState();
}

class _ButtonContainerState extends State<ButtonContainer> {
 bool isSelected = true;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: widget.onTab,
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
            color: isSelected ? Colors.blueGrey: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(


                blurRadius: 4
            )]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(widget.icon,color: isSelected? Colors.white : Colors.black,),
            Text(widget.title,style: TextStyle(fontSize: 8,color: isSelected?Colors.white:Colors.black,)
            ) ],),
      ),
    );
  }
}
