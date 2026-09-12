import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'result_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'FlaskAPI_service.dart';
import 'NewsAPI_service.dart';
import 'keyword_service.dart';
import 'article_filter_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  final TextEditingController _searchController =
  TextEditingController();

  bool isDropdownOpen = false;
  String selectedMode = "Light";

  bool isSearchFocused = false;
  final FocusNode _focusNode = FocusNode();

  Future<void> _logoutUser(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      setState(() {
        isSearchFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showLogoutSheet(BuildContext context) {
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
                  color: Colors.grey.shade400,
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
                  _logoutUser(context);
                },
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          ),
        );
      },
    );
  }

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
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 35,
                child: Icon(
                  Icons.person,
                  size: 35,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "User Profile",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? "No Email Found",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 15),
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

  void _deleteAccount(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  Future<void> _goToResultScreen() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newsText = _searchController.text.trim();

      final result = await ApiService.predict(newsText);

      final searchQuery =
      KeywordService.buildSearchQuery(newsText);

      print("Search Query: $searchQuery");

      List<String> keywords =
      searchQuery.toLowerCase().split(" ");

      print(keywords);

      final relatedArticles =
      await NewsApiService.searchNews(searchQuery);

      print("Before Filter: ${relatedArticles.length}");

      final filteredArticles = relatedArticles;

      print("After Articles: ${filteredArticles.length}");

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('analyses')
            .add({
          'userInput': newsText,
          'prediction': result["prediction"],
          'reliabilityScore': double.parse(
            result["reliability_score"].toString(),
          ),
          'sentiment': result["sentiment"],
          'relatedArticles':
          filteredArticles.map((article) {
            return {
              'title': article['title'],
              'source': article['source']['name'],
              'url': article['url'],
            };
          }).toList(),
        });
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      final shouldClear = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            userInput: newsText,
            prediction: result["prediction"],
            reliability: double.parse(
              result["reliability_score"].toString(),
            ),
            sentiment: result["sentiment"],
            sentimentScore: result["sentiment_score"],
            relatedArticles: filteredArticles,
          ),
        ),
      );

      if (shouldClear == true) {
        _searchController.clear();
        _focusNode.unfocus();
      }
    } catch (e, stack) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      print("========== ERROR ==========");
      print(e);

      print("========== STACK TRACE ==========");
      print(stack);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider =
    Provider.of<ThemeProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor:
      Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () =>
                Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "NewsGuard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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

      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(
                child: const Text(
                  "NewsGuard",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text("Feedback"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    TextEditingController
                    feedbackController =
                    TextEditingController();

                    return AlertDialog(
                      title: const Text("Give Feedback"),
                      content: TextField(
                        controller: feedbackController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText:
                          "Enter your feedback here",
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(12),
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
                            feedbackController.text
                                .trim();

                            if (feedback.isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please enter your feedback",
                                  ),
                                ),
                              );
                              return;
                            }

                            try {
                              final user =
                                  FirebaseAuth.instance
                                      .currentUser;

                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user!.uid)
                                  .collection('feedback')
                                  .add({
                                'feedback': feedback,
                                'createdAt':
                                FieldValue
                                    .serverTimestamp(),
                              });

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Feedback Submitted Successfully",
                                  ),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Failed to submit feedback: $e",
                                  ),
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

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              trailing: Icon(
                isDropdownOpen
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
              onTap: () {
                setState(() {
                  isDropdownOpen = !isDropdownOpen;
                });
              },
            ),

            if (isDropdownOpen)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness ==
                      Brightness.dark
                      ? Colors.grey[850]
                      : Colors.grey[200],
                  borderRadius:
                  BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedMode,
                  dropdownColor:
                  Theme.of(context).brightness ==
                      Brightness.dark
                      ? Colors.grey[900]
                      : Colors.white,
                  style: TextStyle(
                    color: Theme.of(context).brightness ==
                        Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                  items: ["Light", "Dark"].map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(mode),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedMode = value;
                      });

                      switch (value) {
                        case "Light":
                          Provider.of<ThemeProvider>(
                            context,
                            listen: false,
                          ).setTheme(
                            ThemeMode.light,
                          );
                          break;

                        case "Dark":
                          Provider.of<ThemeProvider>(
                            context,
                            listen: false,
                          ).setTheme(
                            ThemeMode.dark,
                          );
                          break;
                      }
                    }
                  },
                ),
              ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pop(context);
                _showLogoutSheet(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Delete Account"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title:
                      const Text("Delete Account"),
                      content: const Text(
                        "Are you sure you want to delete your account? ",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            try {
                              Navigator.pop(context);

                              final user =
                                  FirebaseAuth.instance
                                      .currentUser;

                              if (user != null) {
                                await FirebaseFirestore
                                    .instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .delete();

                                await user.delete();

                                if (!context.mounted) return;

                                Navigator
                                    .pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                    const LoginScreen(),
                                  ),
                                      (route) => false,
                                );
                              }
                            } catch (e) {
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content:
                                  Text("Error: $e"),
                                ),
                              );
                            }
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

      body: Stack(
        children: [
          Center(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Verify news before you trust",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness ==
                      Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ),
          ),

          AnimatedPositioned(
            duration:
            const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: MediaQuery.of(context)
                .viewInsets
                .bottom +
                20,
            left: 20,
            right: 20,
            child: Material(
              elevation: 4,
              borderRadius:
              BorderRadius.circular(12),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onSubmitted: (_) =>
                    _goToResultScreen(),
                keyboardType:
                TextInputType.multiline,
                textInputAction:
                TextInputAction.newline,
                minLines: 1,
                maxLines: 5,
                style: TextStyle(
                  color: Theme.of(context).brightness ==
                      Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: "Which news you are looking for",
                  hintStyle: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),

                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),

                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                    onPressed: _goToResultScreen,
                  ),

                  filled: true,
                  fillColor: const Color(0xFF2E73FF),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Please wait...",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
