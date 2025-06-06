import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTab;
  final bool isSelected;

  const MyListTile({
    super.key,
    required this.icon,
    required this.text,
    required this.onTab,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: GestureDetector(
        onTap: onTab,
        child: Text(
          text,
          style: TextStyle(color: isSelected? Colors.blueGrey : Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
