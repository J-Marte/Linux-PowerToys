import 'package:flutter/material.dart';

const double narrowScreenWidthThreshold = 450;
const double mediumWidthBreakpoint = 950;
const double largeWidthBreakpoint = 1300;

const double transitionLength = 500;

const baseColor = Colors.blue;

enum ScreenSelected {
  general(0),
  fancyzones(1),
  awake(2),
  colorpicker(3),
  run(4);

  const ScreenSelected(this.value);
  final int value;
}

const List<NavigationDestination> appBarDestinations = [
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.home_outlined),
    label: 'General',
    selectedIcon: Icon(Icons.home),
  ),
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.width_wide_outlined),
    label: 'Fancy Zones',
    selectedIcon: Icon(Icons.width_wide),
  ),
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.coffee_outlined),
    label: 'Awake',
    selectedIcon: Icon(Icons.coffee_sharp),
  ),
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.colorize_sharp),
    label: 'Color Picker',
    selectedIcon: Icon(Icons.colorize_sharp),
  ),
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.double_arrow_sharp),
    label: 'Run',
    selectedIcon: Icon(Icons.double_arrow_sharp),
  ),
];
