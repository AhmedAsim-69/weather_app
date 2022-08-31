// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class HourlyForecast extends StatelessWidget {
  HourlyForecast({
    Key? key,
    required this.icon,
    required this.time,
    required this.wind,
    required this.temp,
  }) : super(key: key);

  final String icon;
  final String time;
  final String wind;
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
    return Column(
      children: [
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        Wrap(
          children: [
            Text(
              "$temp\u2103",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ],
        ),
        Image.asset(
          displayIcon,
          height: 22,
          width: 32,
        ),
        Row(
          children: [
            Image.asset(
              './images/wind.png',
              height: 15,
              width: 15,
            ),
            Text(
              '$wind km/h',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        )
      ],
    );
  }
}
