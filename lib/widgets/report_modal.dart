import 'package:flutter/material.dart';
import '../mock_data.dart';
import 'charts_modal.dart';

class ReportModal extends StatefulWidget {
  final String title;
  final List<ReportItem> data;

  const ReportModal({super.key, required this.title, required this.data});

  @override
  State<ReportModal> createState() => _ReportModalState();
}

class _ReportModalState extends State<ReportModal> {
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.dialogBackgroundColor, // Uses theme color now
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 600, // Fixed height for the swipable area
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.data.length,
              itemBuilder: (context, index) {
                final item = widget.data[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: ARCard(
                    item: item,
                    index: index,
                    total: widget.data.length,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class ARCard extends StatelessWidget {
  final ReportItem item;
  final int index;
  final int total;

  const ARCard({
    super.key,
    required this.item,
    required this.index,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: theme.dividerColor),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(
                  '${index + 1} / $total',
                  style: TextStyle(
                    color: colorScheme.onSurface.withAlpha(179),
                    fontSize: 12,
                  ),
                ),
                backgroundColor: theme.colorScheme.secondary,
                padding: EdgeInsets.zero,
                side: BorderSide.none, // Remove chip border for cleaner look
              ),
              IconButton(
                icon: Icon(Icons.bar_chart, color: theme.primaryColor),
                onPressed: () {
                  if (item.chartData != null) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder:
                          (context) => ChartsModal(
                            title: item.title,
                            chartData: item.chartData!,
                          ),
                    );
                  }
                },
              ),
            ],
          ),
          const Spacer(),
          Text(
            item.title,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 24),
          Text(
            item.value,
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 40,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            style: TextStyle(
              color: colorScheme.onSurface.withAlpha(179),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (item.details.isNotEmpty) ...[
            const SizedBox(height: 20),
            Divider(color: theme.dividerColor),
            const SizedBox(height: 10),
            ...item.details.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: const TextStyle(color: Colors.grey)),
                    Text(
                      e.value,
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const Spacer(),
        ],
      ),
    );
  }
}
