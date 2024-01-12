import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ColloscopeBottomNavBarIcon extends StatelessWidget {
  const ColloscopeBottomNavBarIcon({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fitHeight,
      child: Column(
        children: [
          Icon(
            Icons.school_rounded,
            color: selected
                ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
                : Theme.of(context)
                    .bottomNavigationBarTheme
                    .unselectedItemColor,
          ),
          Text(
            "Examens",
            style: TextStyle(fontSize: 13.sp, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
