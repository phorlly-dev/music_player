import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageFile extends StatelessWidget {
  final String image;
  final double w, h;

  const ImageFile({
    super.key,
    required this.image,
    required this.h,
    required this.w,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Card(
        child: image.isNotEmpty && File(image).existsSync()
            ? Image.file(File(image), width: w, height: h, fit: BoxFit.cover)
            : Container(
                width: w,
                height: h,
                color: Colors.grey[300],
                child: const Icon(Icons.image),
              ),
      ),
    );
  }
}

class Button extends StatelessWidget {
  final String label;
  final IconData? icon;
  final void Function() click;
  final Color? color;
  final double? width, height;

  const Button({
    super.key,
    required this.label,
    this.icon = Icons.add,
    required this.click,
    this.color = Colors.blue,
    this.width,
    this.height = 70,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 12),
      child: FloatingActionButton.extended(
        backgroundColor: color,
        foregroundColor: Colors.white,
        onPressed: click,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  final VoidCallback pressedOnEdit, pressedOnDelete;
  const ActionButtons({
    super.key,
    required this.pressedOnEdit,
    required this.pressedOnDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit),
          color: Colors.green,
          onPressed: pressedOnEdit,
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          color: Colors.redAccent,
          onPressed: pressedOnDelete,
        ),
      ],
    );
  }
}

class ImageAsset extends StatelessWidget {
  final String path;
  final double widthFraction; // Fraction of screen width
  final double heightFraction; // Fraction of screen height

  const ImageAsset({
    super.key,
    required this.path,
    this.widthFraction = 0.12, // Default to 16% of screen width
    this.heightFraction = 0.1, // Default to 10% of screen height
  });

  @override
  Widget build(BuildContext context) {
    // Get screen size using MediaQuery
    final screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width * widthFraction;
    final double height = screenSize.height * heightFraction;

    return path.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image(
              width: width,
              height: height,
              fit: BoxFit.cover,
              image: AssetImage(path),
              errorBuilder: (_, __, ___) => const Icon(Icons.music_note),
            ),
          )
        : const Icon(Icons.music_note, size: 100);
  }
}

class ImageAssetAvatr extends StatelessWidget {
  final String path;
  final double widthFraction;
  const ImageAssetAvatr({
    super.key,
    required this.path,
    this.widthFraction = .12,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width * widthFraction;

    return path.isNotEmpty
        ? CircleAvatar(
            radius: width / 2,
            backgroundImage: AssetImage(path),
            onBackgroundImageError: (__, ___) => const Icon(Icons.music_note),
          )
        : Icon(Icons.music_note, size: width);
  }
}

class TimerSelector extends StatelessWidget {
  final String label;
  final int count, selected;
  final ValueChanged<int> onChanged;

  const TimerSelector({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 100,
          width: 80,
          child: CupertinoPicker(
            scrollController: FixedExtentScrollController(
              initialItem: selected,
            ),
            itemExtent: 32,
            onSelectedItemChanged: onChanged,
            children: List.generate(count, (i) => Center(child: Text('$i'))),
          ),
        ),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(label)),
      ],
    );
  }
}

class ImgAsset extends StatelessWidget {
  final String path;
  final double? widthFraction;
  final double? heightFraction;

  const ImgAsset({
    super.key,
    required this.path,
    this.widthFraction = .12,
    this.heightFraction = .1,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = widthFraction != null
        ? screenSize.width * widthFraction!
        : null;
    final height = heightFraction != null
        ? screenSize.height * heightFraction!
        : null;

    if (path.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.music_note, size: 50, color: Colors.grey),
        ),
      );
    }

    if (path.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          path,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image),
        ),
      );
    }

    if (path.startsWith('/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(path),
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        path,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      ),
    );
  }
}
