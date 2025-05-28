import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  final String? hint;
  final String label;
  final TextEditingController? name;
  final IconData? icon;
  final void Function(String?)? saved;
  final String? Function(String?)? checked, changed;
  final TextInputType? type;
  final double? width, height;

  const Input({
    super.key,
    this.hint,
    required this.label,
    this.name,
    this.icon,
    this.saved,
    this.checked,
    this.changed,
    this.type,
    this.width = 300,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        width: width,
        height: height,
        child: TextFormField(
          controller: name,
          onSaved: saved,
          validator: checked,
          keyboardType: type,
          maxLines: null,
          onChanged: changed,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.blue),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            hintText: hint,
            label: Text(
              label,
              style: const TextStyle(color: Colors.blueAccent, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
