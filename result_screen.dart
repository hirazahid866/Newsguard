
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
  State<ResultScreen> createState() =>
      _ResultScreenState();
}
class _ResultScreenState
    extends State<ResultScreen> {
  bool isNotificationOn = true;
  bool isDropdownOpen = false;
  String selectedMode = "Light";
  void _showProfilePopup(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    showModalBottomSheet(
      context: context,
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

              const Text(
                "User Profile",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
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
    return Scaffold(
      //  DRAWER
      drawer: Drawer(
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
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            // FEEDBACK
            ListTile(
              leading:
              const Icon(Icons.feedback),
              title:
              const Text("Feedback"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    TextEditingController
                    feedbackController =
                    TextEditingController();
                    return AlertDialog(
                      title:
                      const Text(
                          "Give Feedback"),
                      content: TextField(
                        controller:
                        feedbackController,
                        maxLines: 4,
                        decoration:
                        InputDecoration(
                          hintText:
                          "Enter your feedback",
                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                                12),
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child:
                          const Text(
                              "Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            String feedback = feedbackController.text.trim();
                            // Empty feedback check
                            if (feedback.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please enter your feedback"),
                                ),
                              );
                              return;
                            }

                            try {
                              final user = FirebaseAuth.instance.currentUser;
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user!.uid)
                                  .collection('feedback')
                                  .add({
                                'feedback': feedback,
                                'createdAt': FieldValue.serverTimestamp(),
                              });

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Feedback Submitted Successfully"),
                                ),
                              );

                            } catch (e) {

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Failed to submit feedback: $e"),
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
              leading:
              const Icon(Icons.settings),
              title:
              const Text("Settings"),
              trailing: Icon(
                isDropdownOpen

                    ? Icons.keyboard_arrow_up

                    : Icons.keyboard_arrow_down,
              ),
              onTap: () {
                setState(() {
                  isDropdownOpen =
                  !isDropdownOpen;
                });
              },
            ),
            // THEME DROPDOWN
            if (isDropdownOpen)
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .brightness ==
                      Brightness.dark
                      ? Colors.grey[850]
                      : Colors.grey[200],
                  borderRadius:
                  BorderRadius.circular(
                      8),
                ),

                child:
                DropdownButton<String>(

                  isExpanded: true,

                  value: selectedMode,

                  underline:
                  const SizedBox(),

                  dropdownColor:
                  Theme.of(context)
                      .brightness ==

                      Brightness.dark

                      ? Colors.grey[900]

                      : Colors.white,

                  style: TextStyle(

                    color: Theme.of(context)
                        .brightness ==

                        Brightness.dark

                        ? Colors.white

                        : Colors.black,
                  ),
                  items: [
                    "Light",
                    "Dark",
                  ].map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(mode),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedMode =
                            value;
                      });
                      switch (value) {
                        case "Light":
                          Provider.of<
                              ThemeProvider>(
                              context,
                              listen: false)

                              .setTheme(
                            ThemeMode.light,
                          );
                          break;
                        case "Dark":
                          Provider.of<
                              ThemeProvider>(
                              context,
                              listen: false)
                              .setTheme(
                            ThemeMode.dark,
                          );
                          break;
                      }
                    }
                  },
                ),
              ),
            // LOGOUT
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pop(context);

                showModalBottomSheet(
                  context: context,
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

                          const Text(
                            "Account Options",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          ListTile(
                            leading: const Icon(
                              Icons.logout,
                              color: Colors.orange,
                            ),
                            title: const Text("Logout"),
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
            ListTile(
              leading: const Icon(
                Icons.delete,
              ),
              title: const Text("Delete Account"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(30),
                      ),
                      title: const Text(
                        "Delete Account",
                      ),
                      content: const Text(
                        "Are you sure you want to delete your account?",
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
                          child: const Text(
                            "Delete",
                            style: TextStyle(
                            ),
                          ),
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
          padding:
          const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // NEWS CARD
              Card(
                elevation: 5,
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                      20),
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      const Text(
                        "News Headline",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                          height: 15),
                      Text(
                        widget.userInput,
                        style:
                        const TextStyle(
                          fontSize: 17,
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
                padding:
                const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color:
                  Colors.red.shade100,
                  borderRadius:
                  BorderRadius.circular(
                      20),
                ),
                child: Column(
                  children: [
                    Icon(
                      widget.prediction == "Real News"
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: widget.prediction == "Real News"
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
                        color: widget.prediction == "Real News"
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              //show articles
              const SizedBox(height: 25),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "Related News from Trusted Sources",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      if (widget.relatedArticles.isEmpty)
                        const Text(
                          "No articles found supporting this claim",
                        ),
                      ...widget.relatedArticles.map((article) {

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(
                              article["title"]?.toString() ?? "No Title",
                            ),
                            subtitle: Text(
                              article["source"]?["name"]?.toString() ?? "Unknown Source",
                            ),
                          ),
                        );

                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              // reliability score
              Card(
                elevation: 5,
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                      20),
                ),
                child:  Padding(
                  padding:
                  EdgeInsets.all(25),
                  child: Column(
                    children: [
                      Text(
                        "Reliability Score",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 25),
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.blue,
                        child: Text(
                          "${widget.reliability.toStringAsFixed(1)}%",
                          style: TextStyle(
                            color:
                            Colors.white,
                            fontSize: 30,
                            fontWeight:
                            FontWeight.bold,
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
                elevation: 5,
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                      20),
                ),
                child: const Padding(
                  padding:
                  EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        Icons
                            .sentiment_dissatisfied,
                        color: Colors.red,
                        size: 35,
                      ),
                      SizedBox(width: 15),
                      Text(
                        "Negative Sentiment",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 35),
              // BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context,true);
                  },
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(
                        0xff0B4F7D),
                    padding:
                    const EdgeInsets
                        .symmetric(
                      vertical: 18,
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius
                          .circular(
                          15),
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
