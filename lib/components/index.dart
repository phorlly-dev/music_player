import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_player/core/functions/index.dart';

class Common {
  static Widget text(
    String title, {
    double size = 14,
    Color color = Colors.black,
    TextAlign textAlign = TextAlign.center,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return Text(
      title,
      style: TextStyle(fontSize: size, fontWeight: fontWeight, color: color),
      textAlign: textAlign,
    );
  }

  static Widget elevated({
    required VoidCallback pressed,
    String text = "Add New",
    Color? color,
    Color? textColor,
    double width = 100,
    double height = 50,
    double border = 10.0,
  }) {
    return ElevatedButton(
      onPressed: pressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size(width, height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(border),
        ),
      ),
      child: Text(text, style: TextStyle(color: textColor)),
    );
  }

  static Widget outlined({
    required VoidCallback pressed,
    String text = "Add New",
    Color? color,
    Color? textColor,
    double width = 100,
    double height = 50,
    double border = 10.0,
  }) {
    return OutlinedButton(
      onPressed: pressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size(width, height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(border),
        ),
      ),
      child: Text(text, style: TextStyle(color: textColor)),
    );
  }

  static Widget btnText({
    required VoidCallback pressed,
    String text = "Add New",
    Color? color,
    Color? textColor,
    double width = 100,
    double height = 50,
    double border = 10.0,
  }) {
    return TextButton(
      onPressed: pressed,
      style: TextButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size(width, height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(border),
        ),
      ),
      child: Text(text, style: TextStyle(color: textColor)),
    );
  }

  static Widget icon({
    required VoidCallback pressed,
    IconData icon = Icons.add,
    Color color = Colors.black,
    double width = 50,
    // double border = 10.0,
  }) {
    return IconButton(
      onPressed: pressed,
      icon: Icon(icon),
      color: color,
      iconSize: width,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          const Color.fromARGB(255, 218, 217, 217),
        ),
      ),
      // padding: EdgeInsets.all(2),
    );
  }

  static Widget floating({
    required VoidCallback pressed,
    required Icon icon,
    Color? color,
    double width = 100,
    double height = 50,
    double border = 10.0,
  }) {
    return FloatingActionButton(
      onPressed: pressed,
      backgroundColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(border),
      ),
      child: icon,
    );
  }
}

class Controls {
  static form(
    BuildContext context, {
    required String title,
    model,
    required List<Widget> children,
    VoidCallback? onDelete,
    VoidCallback? onSave,
    VoidCallback? onUpdate,
  }) {
    return AlertDialog(
      title: Text(
        model == null ? 'Add New $title' : 'Edit The $title',
        textAlign: TextAlign.center,
      ),
      content: Form(
        key: Funcs.formKey,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Common.text('Cancel'),
        ),

        if (model != null && onDelete != null)
          TextButton(
            onPressed: () {
              if (model.id.isNotEmpty) {
                onDelete.call();
              }
            },
            child: Common.text('Delete', color: Colors.red),
          ),

        TextButton(
          onPressed: () {
            if (Funcs.formKey.currentState!.validate()) {
              model == null ? onSave?.call() : onUpdate?.call();
            }
          },
          child: Common.text(
            model == null ? 'Save' : 'Update',
            color: model == null ? Colors.blue : Colors.green,
          ),
        ),
      ],
    );
  }

  static Widget input({
    required TextEditingController field,
    required String label,
    TextInputType type = TextInputType.text,
    double? height = 50,
    double? width = 200,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return SizedBox(
      height: height,
      width: width,
      child: TextField(
        controller: field,
        keyboardType: type,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          labelText: label,
        ),
      ),
    );
  }

  static Widget switcher({
    required void Function(int) onTap,
    int langth = 2,
    int value = 0,
    dynamic listIcons,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(langth, (index) {
        return InkWell(
          onTap: () => onTap(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: value == index ? Colors.blue : Colors.grey[300],
              ),
              padding: const EdgeInsets.all(12.0),
              child: Icon(
                listIcons[index],
                color: value == index ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      }),
    );
  }
}
