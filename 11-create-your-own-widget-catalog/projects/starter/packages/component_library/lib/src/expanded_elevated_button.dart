import 'package:flutter/material.dart';

class ExpandedElevatedButton extends StatelessWidget {
  static const double _elevatedButtonHeight = 48;

  const ExpandedElevatedButton({
    required this.label,
    this.onTap,
    this.icon,
    Key? key,
  }) : super(key: key);

  ExpandedElevatedButton.inProgress({
    required String label,
    Key? key,
  }) : this(
          label: label,
          icon: Transform.scale(
            scale: 0.5,
            child: const CircularProgressIndicator(),
          ),
          key: key,
        );

  final VoidCallback? onTap;
  final String label;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    return SizedBox(
      height: _elevatedButtonHeight,
      width: double.infinity,
      // Completed: replace child with button with icon
      //* 1. Checks that icon is not null.
      child: icon != null
          //* 2. Returns ElevatedButton.icon if that icon isn’t null, which takes icon as an attribute.
          ? ElevatedButton.icon(
              onPressed: onTap,
              label: Text(label),
              icon: icon,
            )
          // * 3. If icon wasn’t provided to the widget as an attribute, it returns
          //* ElevatedButton without icon .
          : ElevatedButton(
              onPressed: onTap,
              child: Text(label),
            ),
    );
  }
}
