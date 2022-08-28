// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import 'dart:ui';

class ThreeDayTile extends StatelessWidget {
  ThreeDayTile({
    Key? key,
    required this.day,
    required this.weatherMain,
    required this.icon,
    required this.temp,
  }) : super(key: key);
  final String day;
  final String weatherMain;
  final String icon;
  final String temp;
  String displayIcon = './images/sunny.png';

  @override
  Widget build(BuildContext context) {
    if (icon == 'Thunderstorm') {
      displayIcon = './images/thunderstorm.png';
    } else if (icon == 'Drizzle' || icon == 'Rain') {
      displayIcon = './images/rainy_cloud.png';
    } else if (icon == 'Clear') {
      displayIcon = './images/sunny.png';
    } else if (icon == 'Clouds') {
      displayIcon = './images/cloud.png';
    }
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(padding: EdgeInsets.all(3)),
            SizedBox(
              height: 50,
              width: 50,
              child: Image.asset(
                displayIcon,
                height: 22,
                width: 32,
              ),
            ),
            Text(
              "$day - $weatherMain",
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const Spacer(),
            Text(
              '$temp \u00b0   ',
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            const Padding(padding: EdgeInsets.all(3)),
          ],
        ),
      ),
    );
  }
}
