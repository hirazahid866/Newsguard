import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResultScreen extends StatefulWidget {
  final String userInput;
  final String prediction;
  final double reliability;
  final String sentiment;
  final double sentimentScore;
  final List<dynamic> relatedArticles;

  const ResultScreen({
    super.key,
    required this.userInput,
    required this.prediction,
    required this.reliability,
    required this.sentiment,
    required this.sentimentScore,
    required this.relatedArticles,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool isNotificationOn = true;
  bool isDropdownOpen = false;
  String selectedMode = "Light";

  void _showProfilePopup(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 10),
              const CircleAvatar(
                radius: 30,
                child: Icon(Icons.person, size: 35),
              ),
              const SizedBox(height: 10),
              Text(
                "User Profile",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                user?.email ?? "No Email",
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    final isReal = widget.prediction.trim().toLowerCase() == "real news";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // DRAWER
      drawer: Drawer(
        backgroundColor: theme.drawerTheme.backgroundColor ?? cardColor,
        child: ListView(
          children: [
            // HEADER
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: const Center(
                child: Text(
                  "NewsGuard",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // HOME
            ListTile(
              leading: Icon(
                Icons.home,
                color: textColor,
              ),
              title: Text(
                "Home",
                style: TextStyle(
                  color: textColor,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            // FEEDBACK
            ListTile(
              leading: Icon(
                Icons.feedback,
                color: textColor,
              ),
              title: Text(
                "Feedback",
                style: TextStyle(
                  color: textColor,
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    TextEditingController feedbackController =
                    TextEditingController();

                    return AlertDialog(
                      backgroundColor: cardColor,
                      title: Text(
                        "Give Feedback",
                        style: TextStyle(
                          color: textColor,
                        ),
                      ),
                      content: TextField(
                        controller: feedbackController,
                        maxLines: 4,
                        style: TextStyle(
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter your feedback",
                          hintStyle: TextStyle(
                            color: isDark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            String feedback =
                            feedbackController.text.trim();

                            if (feedback.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                  Text("Please enter your feedback"),
                                ),
                              );
                              return;
                            }

                            try {
                              final user =
                                  FirebaseAuth.instance.currentUser;

                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user!.uid)
                                  .collection('feedback')
                                  .add({
                                'feedback': feedback,
                                'createdAt':
                                FieldValue.serverTimestamp(),
                              });

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Feedback Submitted Successfully",
                                  ),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                  Text("Failed to submit feedback: $e"),
                                ),
                              );
                            }
                          },
                          child: const Text("Submit"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            // SETTINGS
            ListTile(
              leading: Icon(
                Icons.settings,
                color: textColor,
              ),
              title: Text(
                "Settings",
                style: TextStyle(
                  color: textColor,
                ),
              ),
              trailing: Icon(
                isDropdownOpen
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: textColor,
              ),
              onTap: () {
                setState(() {
                  isDropdownOpen = !isDropdownOpen;
                });
              },
            ),

            // THEME DROPDOWN
            if (isDropdownOpen)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey[850]
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedMode,
                  underline: const SizedBox(),
                  dropdownColor:
                  isDark ? Colors.grey[900] : Colors.white,
                  style: TextStyle(
                    color: textColor,
                  ),
                  items: [
                    "Light",
                    "Dark",
                  ].map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(
                        mode,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedMode = value;
                      });

                      if (value == "Light") {
                        Provider.of<ThemeProvider>(
                          context,
                          listen: false,
                        ).setTheme(
                          ThemeMode.light,
                        );
                      } else {
                        Provider.of<ThemeProvider>(
                          context,
                          listen: false,
                        ).setTheme(
                          ThemeMode.dark,
                        );
                      }
                    }
                  },
                ),
              ),

            // LOGOUT
            ListTile(
              leading: Icon(
                Icons.logout,
                color: textColor,
              ),
              title: Text(
                "Logout",
                style: TextStyle(
                  color: textColor,
                ),
              ),
              onTap: () {
                Navigator.pop(context);

                showModalBottomSheet(
                  context: context,
                  backgroundColor: cardColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Account Options",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ListTile(
                            leading: const Icon(
                              Icons.logout,
                              color: Colors.orange,
                            ),
                            title: Text(
                              "Logout",
                              style: TextStyle(
                                color: textColor,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                                    (route) => false,
                              );
                            },
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            // DELETE ACCOUNT
            ListTile(
              leading: Icon(
                Icons.delete,
                color: textColor,
              ),
              title: Text(
                "Delete Account",
                style: TextStyle(
                  color: textColor,
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      title: Text(
                        "Delete Account",
                        style: TextStyle(
                          color: textColor,
                        ),
                      ),
                      content: Text(
                        "Are you sure you want to delete your account?",
                        style: TextStyle(
                          color: textColor,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const LoginScreen(),
                              ),
                                  (route) => false,
                            );
                          },
                          child: const Text("Delete"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),

      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          "NewsGuard",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                _showProfilePopup(context);
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),

      // BODY
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // NEWS CARD
              Card(
                color: cardColor,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        "News Headline",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        widget.userInput,
                        style: TextStyle(
                          fontSize: 17,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // RESULT CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: isReal
                      ? (isDark
                      ? const Color(0xFF173A24)
                      : Colors.green.shade100)
                      : (isDark
                      ? const Color(0xFF421E1E)
                      : Colors.red.shade100),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(
                      isReal
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: isReal
                          ? Colors.green
                          : Colors.red,
                      size: 70,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      widget.prediction.toUpperCase(),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: isReal
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // RELATED ARTICLES
              Card(
                color: cardColor,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Related News from Trusted Sources",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 15),

                      if (widget.relatedArticles.isEmpty)
                        Text(
                          "No articles found supporting this claim",
                          style: TextStyle(
                            color: textColor,
                          ),
                        ),

                      ...widget.relatedArticles.map((article) {
                        return Card(
                          color: isDark
                              ? const Color(0xFF2A2A2A)
                              : Colors.white,
                          margin:
                          const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(
                              article["title"]?.toString() ??
                                  "No Title",
                              style: TextStyle(
                                color: textColor,
                              ),
                            ),
                            subtitle: Text(
                              article["source"]?["name"]
                                  ?.toString() ??
                                  "Unknown Source",
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // RELIABILITY SCORE
              Card(
                color: cardColor,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      Text(
                        "Reliability Score",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 25),
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.blue,
                        child: Text(
                          "${widget.reliability.toStringAsFixed(1)}%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // SENTIMENT
              Card(
                color: cardColor,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        widget.sentiment.toLowerCase() ==
                            "positive"
                            ? Icons.sentiment_satisfied
                            : widget.sentiment.toLowerCase() ==
                            "negative"
                            ? Icons.sentiment_dissatisfied
                            : Icons.sentiment_neutral,
                        color:
                        widget.sentiment.toLowerCase() ==
                            "positive"
                            ? Colors.green
                            : widget.sentiment.toLowerCase() ==
                            "negative"
                            ? Colors.red
                            : Colors.orange,
                        size: 35,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          "${widget.sentiment} Sentiment",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // CHECK AGAIN BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xff0B4F7D),
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Check Again",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
