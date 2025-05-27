import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Topbar extends StatelessWidget {
  final String title;
  final Widget content;
  final Widget? button;
  final bool backIcon;
  final VoidCallback? pressed;

  const Topbar({
    super.key,
    this.title = "Sample App",
    required this.content,
    this.button,
    this.backIcon = true,
    this.pressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        automaticallyImplyLeading: backIcon,
        leading: backIcon
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded),
                onPressed: () {
                  Get.back();
                  pressed?.call();
                },
              ),
        centerTitle: true,
        title: Text(title),
      ),
      body: Container(padding: const EdgeInsets.all(12), child: content),
      floatingActionButton: button,
    );
  }
}
