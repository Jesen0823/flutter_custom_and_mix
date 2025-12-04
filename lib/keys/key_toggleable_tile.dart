import 'package:flutter/material.dart';

/// 带状态的列表项
class KeyToggleableTile extends StatefulWidget {
  final String title;
  const KeyToggleableTile(this.title,{super.key});

  @override
  State<KeyToggleableTile> createState() => _KeyToggleableTileState();

  @override
  StatefulElement createElement() {
    debugPrint("KeyToggleableTile,key=$key,content=$title, createElement.");
    return super.createElement();
  }
}

class _KeyToggleableTileState extends State<KeyToggleableTile> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.title),
      titleTextStyle: TextStyle(fontSize: _isSelected?26:22,color: _isSelected?Colors.blue:Colors.black),
      selected: _isSelected,
      onTap: ()=> setState(() {
        _isSelected = !_isSelected;
      }),
    );
  }
}
