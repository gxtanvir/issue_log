import 'package:flutter/material.dart';

class IssueDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> issue; // will receive issue data

  const IssueDetailsScreen({Key? key, required this.issue}) : super(key: key);

  Widget _buildDetailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value ?? "-", style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Issue Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildDetailRow("Issue ID", issue["issue_id"]?.toString()),
                _buildDetailRow("Raised By", issue["raised_by"]),
                _buildDetailRow("Responsible Party", issue["responsible_party"]),
                _buildDetailRow("Responsible Person", issue["responsible_person"]),
                _buildDetailRow("Module", issue["module"]),
                _buildDetailRow("Deadline", issue["deadline"]),
                _buildDetailRow("Complete Date", issue["complete_date"]),
                _buildDetailRow("Comments", issue["comments"]),
                _buildDetailRow("Comment Date", issue["comment_date"]),
                _buildDetailRow("Inserted By", issue["inserted_by_name"]),
                _buildDetailRow("Created At", issue["created_at"]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
