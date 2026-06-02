import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'theme_provider.dart';

class ResultScreen extends StatefulWidget {
  final String userInput;

  const ResultScreen({
    super.key,
    required this.userInput,
  });
  @override
  State<ResultScreen> createState() =>
      _ResultScreenState();
}
class _ResultScreenState
    extends State<ResultScreen> {
  bool isNotificationOn = true;
  bool isDropdownOpen = false;
  String selectedMode = "System";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ================= DRAWER =================
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
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(
                                context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Feedback Submitted"),
                              ),
                            );
                          },
                          child:
                          const Text(
                              "Submit"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            // NOTIFICATIONS
            SwitchListTile(
              secondary:
              const Icon(
                  Icons.notifications),
              title:
              const Text(
                  "Notifications"),
              value: isNotificationOn,
              onChanged: (value) {
                setState(() {
                  isNotificationOn =
                      value;
                });
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
                    "System"
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
                        default:
                          Provider.of<
                              ThemeProvider>(
                              context,
                              listen: false)
                              .setTheme(
                            ThemeMode.system,
                          );
                      }
                    }
                  },
                ),
              ),
            // LOGOUT
            ListTile(
              leading:
              const Icon(Icons.logout),
              title:
              const Text("Logout"),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                            25),
                      ),
                      child: Container(
                        padding:
                        const EdgeInsets.all(
                            25),
                        child: Column(
                          mainAxisSize:
                          MainAxisSize.min,
                          children: [
                            // TOP BAR
                            Container(
                              width: 40,
                              height: 5,
                              decoration:
                              BoxDecoration(
                                color:
                                Colors.grey,
                                borderRadius:
                                BorderRadius.circular(
                                    20),
                              ),
                            ),
                            const SizedBox(
                                height: 25),
                            // TITLE
                            const Text(
                              "Account Options",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                                height: 25),
                            // LOGOUT OPTION
                            ListTile(
                              leading:
                              const Icon(
                                Icons.logout,
                                color:
                                Colors.orange,
                              ),
                              title:
                              const Text(
                                "Logout",
                              ),
                              onTap: () {
                                Navigator.pop(
                                    context);
                                Navigator.pop(context);
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                    const LoginScreen(),
                                  ),
                                      (route) => false,
                                );
                              },
                            ),
                            ListTile(
                              leading:
                              const Icon(Icons.delete, color: Colors.red,
                              ),
                              title:
                              const Text(
                                "Delete Account",
                              ),
                              onTap: () {
                                showDialog(
                                  context:
                                  context,
                                  builder:
                                      (context) {
                                    return AlertDialog(
                                      shape:
                                      RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(
                                            30),
                                      ),
                                      title:
                                      const Text(
                                        "Delete Account",
                                      ),
                                      content:
                                      const Text(
                                        "Are you sure you want to delete your account? This action cannot be undone.",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () {
                                            Navigator.pop(
                                                context);
                                          },
                                          child:
                                          const Text(
                                            "Cancel",
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(
                                                context);
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                const LoginScreen(),
                                              ),
                                                  (route) => false,
                                            );
                                          },
                                          child:
                                          const Text(
                                            "Delete",
                                            style:
                                            TextStyle(
                                              color:
                                              Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox(
                                height: 10),
                            // CANCEL
                            TextButton(
                              onPressed: () {
                                Navigator.pop(
                                    context);
                              },
                              child:
                              const Text(
                                "Cancel",
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      // ================= APPBAR =================
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
          PopupMenuButton(
            icon: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      "userName",
                      style: TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text("userEmail"),
                  ],
                ),
              ),
              PopupMenuItem(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child:
                  const Text("Close"),
                ),
              ),
            ],
          ),
        ],
      ),
      // ================= BODY =================
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
                child: const Column(
                  children: [
                    Icon(
                      Icons.cancel,
                      color: Colors.red,
                      size: 70,
                    ),
                    SizedBox(height: 15),
                    Text(
                      "FAKE NEWS",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight:
                        FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              // RELIABILITY SCORE
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
                          "25%",
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
                    Navigator.pop(context);
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
