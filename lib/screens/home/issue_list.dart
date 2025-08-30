import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:issue_log/services/api_service.dart';
import 'package:issue_log/screens/auth/login.dart';
import 'package:issue_log/screens/home/issue_details.dart';

class IssueListScreen extends StatefulWidget {
  @override
  _IssueListScreenState createState() => _IssueListScreenState();
}

class _IssueListScreenState extends State<IssueListScreen> {
  List<dynamic> issues = [];
  bool loading = true;

  int totalCount = 0;
  int pendingCount = 0;
  int solvedCount = 0;

  @override
  void initState() {
    super.initState();
    fetchIssues();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  Future<void> fetchIssues() async {
    setState(() => loading = true);
    try {
      final data = await ApiService.fetchIssues();
      int total = data.length;
      int pending = 0;
      int solved = 0;

      for (var issue in data) {
        if (issue["gms_status"] == "Done" && issue["logic_status"] == "Done") {
          solved++;
        } else {
          pending++;
        }
      }

      setState(() {
        issues = data;
        totalCount = total;
        pendingCount = pending;
        solvedCount = solved;
        loading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => loading = false);
    }
  }

  Widget _buildStatusChip(String? gms, String? logic) {
    String status = "Pending";
    Color color = Colors.orange;

    if (gms == "Done" && logic == "Done") {
      status = "Completed";
      color = Colors.green;
    } else {
      status = "Pending";
      color = Colors.redAccent;
    }

    return Chip(
      label: Text(status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: color,
    );
  }

  Widget _buildSummaryCard(String title, int count, Color color) {
    return Expanded(
      child: Card(
        color: color,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: [
              Text(count.toString(),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 6),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  String _shortTitle(String? text) {
    if (text == null) return "";
    return text.length > 40 ? text.substring(0, 40) + "..." : text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pending Issues"),
        backgroundColor: const Color.fromARGB(255, 56, 75, 112),
        actions: [
          IconButton(icon: Icon(Icons.logout, color: Colors.white), onPressed: _logout),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 56, 75, 112),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add');
          if (result == true) fetchIssues();
        },
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchIssues,
              child: issues.isEmpty
                  ? const Center(child: Text("No issues found"))
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              _buildSummaryCard("Total", totalCount, Colors.blue),
                              const SizedBox(width: 8),
                              _buildSummaryCard("Pending", pendingCount, Colors.redAccent),
                              const SizedBox(width: 8),
                              _buildSummaryCard("Completed", solvedCount, Colors.green),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: ListView.builder(
                            itemCount: issues.length,
                            itemBuilder: (context, index) {
                              final issue = issues[index];
                              return Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () async {
                                    final updatedIssue = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => IssueDetailsScreen(issue: issue)),
                                    );
                                    if (updatedIssue != null) {
                                      // Refresh list automatically
                                      fetchIssues();
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(_shortTitle(issue["issue_details"]),
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF384B70))),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Raised By: ${issue["raised_by"] ?? "N/A"}",
                                                style: const TextStyle(fontSize: 14)),
                                            Text("Raised: ${issue["issue_raise_date"] ?? "-"}",
                                                style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                            Text("Deadline: ${issue["deadline"] ?? "-"}",
                                                style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: _buildStatusChip(issue["gms_status"], issue["logic_status"]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
    );
  }
}
