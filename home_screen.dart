import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'theme_provider.dart';
import 'result_screen.dart';


class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool isDropdownOpen = false;
  String selectedMode = "System";
  bool notificationsEnabled = true;
  bool isSearchFocused = false;
  final FocusNode _focusNode = FocusNode();

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

  // ================= LOGOUT BOTTOM SHEET =================
  void _showLogoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
              SizedBox(height: 20),

              Text(
                "Account Options",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 20),

              ListTile(
                leading: Icon(Icons.logout, color: Colors.orange),
                title: Text("Logout"),
                onTap: () {
                  Navigator.pop(context);
                  _logoutUser(context);
                },
              ),

              ListTile(
                leading: Icon(Icons.delete_forever, color: Colors.red),
                title: Text("Delete Account"),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context);
                },
              ),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _logoutUser(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Account"),
        content: Text(
          "Are you sure you want to delete your account? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount(context);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  void _showProfilePopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
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
              SizedBox(height: 10),
              Text(
                "userName", // dynamic user name
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                "userEmail",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }


  void _deleteAccount(BuildContext context) {
    // Future: Firebase delete logic
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
    );
  }
  void _goToResultScreen() {
    if (_searchController.text.trim().isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ResultScreen(userInput: _searchController.text.trim()),
      ),
    );
  }


  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(


      backgroundColor: Theme.of(context).scaffoldBackgroundColor,


      // 🔵 APP BAR
      appBar: AppBar(

        backgroundColor: Colors.blue,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title:  Text(
          "NewsGuard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                _showProfilePopup(context);
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blue),
              ),
            ),

          ),
        ],
      ),

      // 📂 DRAWER
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Center(
                child: Text(
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
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text("Notifications"),
              trailing: Switch(
                value: notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              trailing: Icon(
                isDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              ),
              onTap: () {
                setState(() {
                  isDropdownOpen = !isDropdownOpen;
                });
              },
            ),

            // Dropdown for App Mode (Light/Dark/System)
            if (isDropdownOpen)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850] // dark mode background
                      : Colors.grey[200], // light mode background
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedMode,
                  dropdownColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[900] // dark mode dropdown bg
                      : Colors.white,    // light mode dropdown bg
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white // dark mode text
                        : Colors.black, // light mode text
                  ),
                  items: ["Light", "Dark", "System"].map((mode) {
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
                          Provider.of<ThemeProvider>(context, listen: false)
                              .setTheme(ThemeMode.light);
                          break;
                        case "Dark":
                          Provider.of<ThemeProvider>(context, listen: false)
                              .setTheme(ThemeMode.dark);
                          break;
                        default:
                          Provider.of<ThemeProvider>(context, listen: false)
                              .setTheme(ThemeMode.system);
                      }
                    }
                  },
                ),
              ),

            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () {
                Navigator.pop(context);
                _showLogoutSheet(context);
              },
            ),
          ],
        ),
      ),

      // 🧠 BODY
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Verify news before you trust",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white // Dark mode
                      : Colors.black87, // Light mode
                ),
              ),
            ),
          ),

          // 🔍 SEARCH BAR (BOTTOM → TOP)
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: isSearchFocused ? null : 40,
            top: isSearchFocused ? 20 : null,
            left: 20,
            right: 20,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onSubmitted: (_) => _goToResultScreen(),

                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: "Which news you are looking for",
                  hintStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey.shade400,
                    fontSize: 14,
                  ),

                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.grey,
                  ),

                  /// 👉 SEARCH ICON CLICK
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.arrow_forward,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.grey,
                    ),
                    onPressed: _goToResultScreen,
                  ),

                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[900]
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
