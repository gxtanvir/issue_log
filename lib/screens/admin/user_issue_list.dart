import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:issue_log/services/api_service.dart';
import 'package:issue_log/screens/auth/login.dart';
import 'package:issue_log/screens/home/issue_details.dart';

class UserIssueListScreen extends StatefulWidget {
  final String userId;
  final String? userName;

  const UserIssueListScreen({super.key, required this.userId, this.userName});

  @override
  State<UserIssueListScreen> createState() => _UserIssueListScreenState();
}

class _UserIssueListScreenState extends State<UserIssueListScreen> {
  List<dynamic> issues = [];
  bool loading = true;

  int totalCount = 0;
  int pendingCount = 0;
  int solvedCount = 0;

  String selectedFilter = "Pending";

  @override
  void initState() {
    super.initState();
    _fetchIssues();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _fetchIssues() async {
    setState(() => loading = true);
    try {
      final data = await ApiService.fetchIssuesForUser(widget.userId);
      int pending = 0;
      int solved = 0;

      for (var issue in data) {
        if (issue["gms_status"] == "Done") {
          solved++;
        } else {
          pending++;
        }
      }

      setState(() {
        issues = data;
        totalCount = data.length;
        pendingCount = pending;
        solvedCount = solved;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  List<dynamic> _getFilteredIssues() {
    if (selectedFilter == "Pending") {
      return issues.where((i) => i["gms_status"] != "Done").toList();
    } else if (selectedFilter == "Completed") {
      return issues.where((i) => i["gms_status"] == "Done").toList();
    }
    return issues; // Total
  }

  String _shortTitle(String? text) {
    if (text == null) return "";
    return text.length > 40 ? text.substring(0, 40) + "..." : text;
  }

  Widget _buildStatusChip(String? gms) {
    String status = gms == "Done" ? "Completed" : "Pending";
    Color color = gms == "Done" ? Colors.green : Colors.redAccent;

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
    bool isSelected = selectedFilter == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => selectedFilter = title);
        },
        child: Card(
          color: isSelected ? color.withOpacity(0.95) : color,
          elevation: isSelected ? 8 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side:
                isSelected
                    ? BorderSide(color: Colors.black.withOpacity(0.5), width: 2)
                    : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 56, 75, 112),
        foregroundColor: Colors.white,
        title: Text("${widget.userName}'s Issue List"),
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _fetchIssues,
                child:
                    issues.isEmpty
                        ? const Center(child: Text("No issues found"))
                        : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  _buildSummaryCard(
                                    "Pending",
                                    pendingCount,
                                    Colors.redAccent,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildSummaryCard(
                                    "Completed",
                                    solvedCount,
                                    Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildSummaryCard(
                                    "Total",
                                    totalCount,
                                    Colors.blue,
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            width < 600
                                ? Expanded(
                                  child: ListView.builder(
                                    itemCount: _getFilteredIssues().length,
                                    itemBuilder: (context, index) {
                                      final issue = _getFilteredIssues()[index];
                                      return Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        elevation: 4,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          onTap: () async {
                                            final updatedIssue =
                                                await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (_) =>
                                                            IssueDetailsScreen(
                                                              issue: issue,
                                                            ),
                                                  ),
                                                );
                                            if (updatedIssue != null)
                                              _fetchIssues();
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _shortTitle(
                                                    issue["issue_details"],
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF384B70),
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Raised By: ${issue["raised_by"] ?? "N/A"}",
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      "Raised: ${issue["issue_raise_date"] ?? "-"}",
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Priority: ${issue["priority"] ?? "-"}",
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 14,
                                                              ),
                                                        ),
                                                        Text(
                                                          "Deadline: ${issue["deadline"] ?? "-"}",
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 14,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: _buildStatusChip(
                                                        issue["gms_status"],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                                : Expanded(
                                  child: GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio:
                                              width < 950 ? 1.6 : 4,
                                          crossAxisSpacing: 6,
                                          mainAxisSpacing: 6,
                                        ),
                                    itemCount: _getFilteredIssues().length,

                                    itemBuilder: (context, index) {
                                      final issue = _getFilteredIssues()[index];
                                      return Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        elevation: 4,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          onTap: () async {
                                            final updatedIssue =
                                                await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (_) =>
                                                            IssueDetailsScreen(
                                                              issue: issue,
                                                            ),
                                                  ),
                                                );
                                            if (updatedIssue != null)
                                              _fetchIssues();
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _shortTitle(
                                                    issue["issue_details"],
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF384B70),
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  "Raised By: ${issue["raised_by"] ?? "N/A"}",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  "Raised: ${issue["issue_raise_date"] ?? "-"}",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Priority: ${issue["priority"] ?? "-"}",
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 14,
                                                              ),
                                                        ),
                                                        Text(
                                                          "Deadline: ${issue["deadline"] ?? "-"}",
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 14,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: _buildStatusChip(
                                                        issue["gms_status"],
                                                      ),
                                                    ),
                                                  ],
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
