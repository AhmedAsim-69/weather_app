// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class DailyForecast extends StatelessWidget {
  DailyForecast({
    Key? key,
    required this.icon,
    required this.day,
    required this.date,
    required this.temp,
  }) : super(key: key);

  final String icon;
  final String day;
  final String date;
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
    return Container(
      child: Column(
        children: [
          Text(
            day,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          Text(
            ' $date ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
            ),
          ),
          Image.asset(
            displayIcon,
            height: 50,
            width: 50,
          ),
          Text(
            "$temp\u2103",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
