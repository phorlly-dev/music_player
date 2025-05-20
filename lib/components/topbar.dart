import 'package:flutter/material.dart';

class Topbar extends StatefulWidget {
  final String title;
  final Widget content;
  final Widget? button;
  final bool backIcon;

  const Topbar({
    super.key,
    this.title = "Sample App",
    required this.content,
    this.button,
    this.backIcon = true,
  });

  @override
  State<Topbar> createState() => _TopbarState();
}

class _TopbarState extends State<Topbar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        automaticallyImplyLeading: widget.backIcon,
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Container(padding: const EdgeInsets.all(12), child: widget.content),
      floatingActionButton: widget.button,
    );
  }
}
