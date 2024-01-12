import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SettingsBottomNavBarIcon extends StatelessWidget {
  const SettingsBottomNavBarIcon({super.key, required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fitHeight,
      child: Column(
        children: [
          Icon(
            Icons.settings_rounded,
            color: selected
                ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
                : Theme.of(context)
                    .bottomNavigationBarTheme
                    .unselectedItemColor,
          ),
          Text(
            "Settings",
            style: TextStyle(fontSize: 13.sp),
          ),
        ],
      ),
    );
  }
}
