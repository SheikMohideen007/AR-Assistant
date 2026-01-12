class ChartData {
  final List<double> pieValues; // For Pie Chart (e.g., [30, 40, 30])
  final List<String> pieLabels; // e.g. ["Paid", "Pending", "Overdue"]
  final List<double> graphValues; // For Line Chart (History)
  final List<String> graphLabels; // Time labels for X-axis

  ChartData({
    required this.pieValues,
    required this.pieLabels,
    required this.graphValues,
    required this.graphLabels,
  });
}

class ReportItem {
  final String title;
  final String subtitle;
  final String value;
  final String description;
  final Map<String, String> details;
  final ChartData? chartData; // Added chart data

  ReportItem({
    required this.title,
    required this.subtitle,
    required this.value,
    this.description = '',
    this.details = const {},
    this.chartData,
  });
}

class ReportData {
  static final List<ReportItem> clientWise = [
    ReportItem(
      title: "Acme Corp",
      subtitle: "Client ID: 1001",
      value: "\$15,000",
      description: "Outstanding balance overdue by 15 days.",
      details: {"Contact": "John Doe", "Region": "North America"},
      chartData: ChartData(
        pieValues: [40, 30, 30],
        pieLabels: ["Current", "Overdue", "Disputed"],
        graphValues: [10, 15, 12, 18, 15, 20],
        graphLabels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun"],
      ),
    ),
    ReportItem(
      title: "Globex Inc",
      subtitle: "Client ID: 1002",
      value: "\$8,450",
      description: "Payment expected next Monday.",
      details: {"Contact": "Jane Smith", "Region": "Europe"},
      chartData: ChartData(
        pieValues: [80, 20],
        pieLabels: ["Clear", "Pending"],
        graphValues: [5, 6, 8, 8, 9, 8],
        graphLabels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun"],
      ),
    ),
    ReportItem(
      title: "Soylent Corp",
      subtitle: "Client ID: 1003",
      value: "\$22,100",
      description: "Legal action pending.",
      details: {"Contact": "Director K", "Region": "Asia"},
      chartData: ChartData(
        pieValues: [10, 90],
        pieLabels: ["Paid", "Bad Debt"],
        graphValues: [22, 22, 21, 22, 22, 22],
        graphLabels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun"],
      ),
    ),
  ];

  static final List<ReportItem> bucketWise = [
    ReportItem(
      title: "0-30 Days",
      subtitle: "Current",
      value: "\$45,000",
      description: "Healthy receivables.",
      chartData: ChartData(
        pieValues: [100],
        pieLabels: ["Current"],
        graphValues: [40, 42, 45, 43, 48, 45],
        graphLabels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun"],
      ),
    ),
    ReportItem(
      title: "31-60 Days",
      subtitle: "Overdue",
      value: "\$12,000",
      description: "Follow-up emails sent.",
      chartData: ChartData(
        pieValues: [60, 40],
        pieLabels: ["Promised", "No Response"],
        graphValues: [10, 12, 15, 12, 10, 12],
        graphLabels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun"],
      ),
    ),
    ReportItem(
      title: "61-90 Days",
      subtitle: "Critical",
      value: "\$5,500",
      description: "Requires manager intervention.",
      chartData: ChartData(
        pieValues: [30, 70],
        pieLabels: ["Recoverable", "Risk"],
        graphValues: [5, 5, 4, 6, 5, 5],
        graphLabels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun"],
      ),
    ),
    ReportItem(
      title: "90+ Days",
      subtitle: "Bad Debt",
      value: "\$2,000",
      description: "Written off likely.",
      chartData: ChartData(
        pieValues: [10, 90],
        pieLabels: ["Legal", "Write-off"],
        graphValues: [2, 3, 2, 2, 2, 2],
        graphLabels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun"],
      ),
    ),
  ];

  static final List<ReportItem> ageWise = [
    ReportItem(
      title: "Invoice #INV-2023-001",
      subtitle: "Issued: Jan 10, 2023",
      value: "45 Days Old",
      description: "Waitlisted for processing.",
      chartData: ChartData(
        pieValues: [50, 50],
        pieLabels: ["Paid", "Pending"],
        graphValues: [100, 100, 50, 50, 50, 50], // Value history
        graphLabels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun"],
      ),
    ),
    ReportItem(
      title: "Invoice #INV-2023-045",
      subtitle: "Issued: Feb 12, 2023",
      value: "12 Days Old",
      description: "Within payment terms.",
      chartData: ChartData(
        pieValues: [100],
        pieLabels: ["Pending"],
        graphValues: [120, 120, 120, 120, 120, 120],
        graphLabels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun"],
      ),
    ),
  ];

  static final List<ReportItem> collectionProjection = [
    ReportItem(
      title: "Week 1",
      subtitle: "Mar 1 - Mar 7",
      value: "\$50,000",
      description: "Projected inflow based on promises to pay.",
      chartData: ChartData(
        pieValues: [70, 30],
        pieLabels: ["Confident", "Likely"],
        graphValues: [10, 20, 30, 40, 50, 50], // Cumulative projection
        graphLabels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
      ),
    ),
    ReportItem(
      title: "Week 2",
      subtitle: "Mar 8 - Mar 14",
      value: "\$35,000",
      description: "Conservative estimate.",
      chartData: ChartData(
        pieValues: [40, 60],
        pieLabels: ["Confident", "Likely"],
        graphValues: [5, 10, 15, 20, 25, 35],
        graphLabels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
      ),
    ),
  ];
}
