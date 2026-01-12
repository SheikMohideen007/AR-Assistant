import 'package:ar_assistant/main.dart';
import 'package:ar_assistant/mock_data.dart' show ReportData;
import 'package:ar_assistant/utils/report_builders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

Widget floatinButton(ThemeData theme, BuildContext context) => Padding(
  padding: EdgeInsets.only(bottom: 60),
  child: SpeedDial(
    icon: Icons.bolt_rounded,
    activeIcon: Icons.close_rounded,
    backgroundColor: theme.colorScheme.primary,
    foregroundColor: Colors.white,
    activeBackgroundColor: theme.colorScheme.primary.withOpacity(0.9),
    direction: SpeedDialDirection.up,
    curve: Curves.easeInOutCubic,
    children: [
      SpeedDialChild(
        child: const Icon(Icons.business),
        backgroundColor: themeController.currentTheme == ThemeMode.dark
            ? theme.colorScheme.surface
            : Colors.grey.shade600,
        foregroundColor: Colors.white,
        label: 'Client Wise',
        labelStyle: const TextStyle(fontSize: 14),
        onTap: () => ReportBuilders.showReport(
          context,
          "Client Wise Report",
          ReportData.clientWise,
        ),
      ),
      SpeedDialChild(
        child: const Icon(Icons.category),
        backgroundColor: themeController.currentTheme == ThemeMode.dark
            ? theme.colorScheme.surface
            : Colors.grey.shade600,
        foregroundColor: Colors.white,
        label: 'Bucketwise',
        onTap: () => ReportBuilders.showReport(
          context,
          "Bucket Wise Report",
          ReportData.bucketWise,
        ),
      ),
      SpeedDialChild(
        child: const Icon(Icons.calendar_today),
        backgroundColor: themeController.currentTheme == ThemeMode.dark
            ? theme.colorScheme.surface
            : Colors.grey.shade600,
        foregroundColor: Colors.white,
        label: 'Age Wise',
        onTap: () => ReportBuilders.showReport(
          context,
          "Age Wise Report",
          ReportData.ageWise,
        ),
      ),
      SpeedDialChild(
        child: const Icon(Icons.trending_up),
        backgroundColor: themeController.currentTheme == ThemeMode.dark
            ? theme.colorScheme.surface
            : Colors.grey.shade600,
        foregroundColor: Colors.white,
        label: 'Collection Projection',
        onTap: () => ReportBuilders.showReport(
          context,
          "Collection Projection",
          ReportData.collectionProjection,
        ),
      ),
    ],
  ),
);
