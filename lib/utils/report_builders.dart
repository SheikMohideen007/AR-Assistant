import 'dart:ui';

import 'package:ar_assistant/mock_data.dart';
import 'package:ar_assistant/widgets/report_modal.dart';
import 'package:flutter/material.dart';

class ReportBuilders {
  static Widget buildQuickReportsHeader(
    BuildContext context,
    void Function(String reportText)? onReportSelected,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(height: 16),
          Icon(
            Icons.bolt,
            size: 48,
            color: theme.colorScheme.onSurface.withAlpha(179),
          ),
          const SizedBox(height: 30),
          Text(
            "Quick Reports",
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                _buildQuickChip("AR Report Client Wise", () {
                  onReportSelected?.call("AR Report Client Wise");
                  // showReport(
                  //   context,
                  //   "Client Wise Report",
                  //   ReportData.clientWise,
                  // );
                }, context),
                _buildQuickChip("AR Report Bucketwise", () {
                  onReportSelected?.call("AR Report Bucketwise");
                  // showReport(
                  //   context,
                  //   "Bucket Wise Report",
                  //   ReportData.bucketWise,
                  // );
                }, context),
                _buildQuickChip("AR Report Age Wise", () {
                  onReportSelected?.call("AR Report Age Wise");
                  // showReport(context, "Age Wise Report", ReportData.ageWise);
                }, context),
                _buildQuickChip("Collection Projection", () {
                  onReportSelected?.call("Collection Projection");
                  // showReport(
                  //   context,
                  //   "Collection Projection",
                  //   ReportData.collectionProjection,
                  // );
                }, context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildQuickChip(
    String label,
    VoidCallback onTap,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 16)),
        onPressed: onTap,
        backgroundColor: theme.colorScheme.secondary,
        side: BorderSide.none,
      ),
    );
  }

  static void showReport(
    BuildContext context,
    String title,
    List<ReportItem> data,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportModal(title: title, data: data),
    );
  }

  static Widget buildQuickChipsRow(
    BuildContext context,
    void Function(String reportText)? onReportSelected,
  ) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            Row(
              children: [
                _buildQuickChipBottom("AR Report Client Wise", () {
                  onReportSelected?.call("AR Report Client Wise");
                  // showReport(
                  //   context,
                  //   "Client Wise Report",
                  //   ReportData.clientWise,
                  // );
                }, context),
                _buildQuickChipBottom("AR Report Bucketwise", () {
                  onReportSelected?.call("AR Report Bucketwise");
                  // showReport(
                  //   context,
                  //   "Bucket Wise Report",
                  //   ReportData.bucketWise,
                  // );
                }, context),
              ],
            ),
            Row(
              children: [
                _buildQuickChipBottom("AR Report Age Wise", () {
                  onReportSelected?.call("AR Report Age Wise");
                  // showReport(context, "Age Wise Report", ReportData.ageWise);
                }, context),
                _buildQuickChipBottom("Collection Projection", () {
                  onReportSelected?.call("Collection Projection");
                  // showReport(
                  //   context,
                  //   "Collection Projection",
                  //   ReportData.collectionProjection,
                  // );
                }, context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildQuickChipBottom(
    String label,
    VoidCallback onTap,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8, left: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 14)),
        onPressed: onTap,
        backgroundColor: theme.colorScheme.secondary,
        side: BorderSide.none,
      ),
    );
  }
}
