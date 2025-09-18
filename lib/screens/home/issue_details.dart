import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:issue_log/screens/home/issue_update.dart';

class IssueDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> issue;

  const IssueDetailsScreen({super.key, required this.issue});

  @override
  State<IssueDetailsScreen> createState() => _IssueDetailsScreenState();
}

class _IssueDetailsScreenState extends State<IssueDetailsScreen> {
  late Map<String, dynamic> issue;

  @override
  void initState() {
    super.initState();
    issue = widget.issue;
  }

  final dateFormatter = DateFormat("yyyy-MM-dd");

  String fmtDate(dynamic d) {
    if (d == null) return "-";
    try {
      return dateFormatter.format(DateTime.parse(d.toString()));
    } catch (_) {
      return d.toString();
    }
  }

  Widget row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(flex: 5, child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Issue Details"),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 56, 75, 112),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            row("Issue Raise Date", fmtDate(issue['issue_raise_date'])),
            row("Company Name", issue['company_name'] ?? "-"),
            row("Priority", issue['priority'] ?? "-"),
            row("Module", issue['module'] ?? "-"),
            row("Raised By", issue['raised_by'] ?? "-"),
            row("Via", issue['via'] ?? "-"),
            row("Issue Details", issue['issue_details'] ?? "-"),
            row("Responsible Party", issue['responsible_party'] ?? "-"),
            row("Responsible Person", issue['responsible_person'] ?? "-"),
            row("Deadline", fmtDate(issue['deadline'])),
            row("Completed Date", fmtDate(issue['complete_date'])),
            row("CRM", issue['crm'] ?? "-"),
            row("Comment", issue['comments'] ?? "-"),
            const SizedBox(height: 30),
            if (issue['gms_status'] == "Pending")
              ElevatedButton(
                onPressed: () async {
                  final updatedIssue = await Navigator.of(
                    context,
                  ).push<Map<String, dynamic>>(
                    MaterialPageRoute(
                      builder:
                          (_) => IssueUpdateScreen(
                            issue: issue,
                            issueId: issue['issue_id'],
                          ),
                    ),
                  );

                  if (updatedIssue != null) {
                    setState(() {
                      issue = updatedIssue; // Refresh UI with updated issue
                    });

                    // Pass updated issue back to IssueListScreen if needed
                    Navigator.of(context).pop(issue);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 56, 75, 112),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                ),
                child: const Text(
                  "Update Issue",
                  style: TextStyle(fontSize: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
