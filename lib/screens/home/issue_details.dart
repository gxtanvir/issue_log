import 'package:flutter/material.dart';

class IssueDetailScreen extends StatelessWidget {
  final Map<String, dynamic> issue;

  const IssueDetailScreen({super.key, required this.issue});

  Widget _buildRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF384B70),
            ),
          ),
          Expanded(
            child: Text(value ?? "-", style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Issue Details"),
        backgroundColor: const Color.fromARGB(255, 56, 75, 112),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    issue["company_name"] ?? "Unknown Company",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF384B70),
                    ),
                  ),
                ),
                const Divider(height: 30, thickness: 1),
                _buildRow("Issue Raise Date", issue["issue_raise_date"]),
                _buildRow("Inserted By", issue["raised_by"]),
                _buildRow("Priority", issue["priority"]?.toString()),
                _buildRow("Repetitive", issue["repetitive"]?.toString()),
                _buildRow("Repeat Count", issue["repeat_count"]?.toString()),
                _buildRow("Module", issue["module"]),
                _buildRow("Page/Topic", issue["page_topic"]),
                _buildRow("Via", issue["via"]),
                _buildRow("Responsible Party", issue["responsible_party"]),
                _buildRow("Responsible Person", issue["responsible_person"]),
                _buildRow("GMS Status", issue["gms_status"]),
                _buildRow("Logic Status", issue["logic_status"]),
                _buildRow("Deadline", issue["deadline"]),
                _buildRow("Complete Date", issue["complete_date"]),
                const SizedBox(height: 12),
                const Text(
                  "Issue Details:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF384B70),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  issue["issue_details"] ?? "-",
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Comments:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF384B70),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  issue["comments"] ?? "-",
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
