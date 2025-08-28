import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:issue_log/services/api_service.dart';

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

  final String baseUrl = "https://gxtanvir.pythonanywhere.com";

  @override
  void initState() {
    super.initState();
    fetchIssues();
  }

  Future<void> fetchIssues() async {
    setState(() => loading = true);

    try {
      // 1️⃣ Get saved JWT token
      final token = await ApiService.getToken();
      if (token == null) {
        debugPrint("No token found. User might need to login.");
        setState(() => loading = false);
        return;
      }

      // 2️⃣ Make GET request with Authorization header
      final uri = Uri.parse("$baseUrl/api/issues/");
      final res = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        int total = data.length;
        int pending = 0;
        int solved = 0;

        for (var issue in data) {
          if (issue["gms_status"] == "Done" &&
              issue["logic_status"] == "Done") {
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
      } else {
        debugPrint("Failed ${res.statusCode}: ${res.body}");
        setState(() => loading = false);
      }
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
      label: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
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
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pending Issues"),
        backgroundColor: const Color.fromARGB(255, 56, 75, 112),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 56, 75, 112),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add');
          if (result == true) {
            fetchIssues(); // refresh after adding
          }
        },
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: fetchIssues,
                child:
                    issues.isEmpty
                        ? const Center(child: Text("No issues found"))
                        : Column(
                          children: [
                            // 🔹 Summary Panel
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  _buildSummaryCard(
                                    "Total",
                                    totalCount,
                                    Colors.blue,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildSummaryCard(
                                    "Pending",
                                    pendingCount,
                                    Colors.redAccent,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildSummaryCard(
                                    "Solved",
                                    solvedCount,
                                    Colors.green,
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),

                            // 🔹 Issue List
                            Expanded(
                              child: ListView.builder(
                                itemCount: issues.length,
                                itemBuilder: (context, index) {
                                  final issue = issues[index];
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/details',
                                          arguments: issue,
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Top Row -> Company + Date
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  issue["company_name"] ??
                                                      "Unknown Company",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF384B70),
                                                  ),
                                                ),
                                                Text(
                                                  issue["issue_raise_date"] ??
                                                      "",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),

                                            // Raised By
                                            Text(
                                              "Inserted By: ${issue["raised_by"] ?? "N/A"}",
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 6),

                                            // Issue details preview
                                            Text(
                                              issue["issue_details"] ??
                                                  "No details",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            const SizedBox(height: 10),

                                            // Status chip
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: _buildStatusChip(
                                                issue["gms_status"],
                                                issue["logic_status"],
                                              ),
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
