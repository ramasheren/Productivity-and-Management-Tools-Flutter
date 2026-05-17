import 'package:flutter/material.dart';
import 'helpers/preferences_helper.dart';
import 'database/database_helper.dart';
import 'models/task.dart';
import 'models/note.dart';
import 'screens/dashboard_screen.dart';
import 'screens/task_list_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/add_note_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/timer_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesHelper.init();
  await DatabaseHelper().initDB();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
      routes: {
        '/tasks': (context) => const TaskListScreen(),
        '/addTask': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Task?;
          return AddTaskScreen(task: args);
        },
        '/addNote': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Note?;
          return AddNoteScreen(note: args);
        },
        '/notes': (context) => const NotesScreen(),
        '/timer': (context) => const TimerScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TaskListScreen(),
    const NotesScreen(),
    const TimerScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = PreferencesHelper.getLastTabIndex();
  }

  void _onBottomNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    PreferencesHelper.setLastTabIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_currentIndex],
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: Builder(
              builder: (context) => CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.85),
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black87),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Timer',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.account_circle,
                      size: 48, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    PreferencesHelper.getUsername(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.checklist),
              title: const Text('Tasks'),
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text('Notes'),
              onTap: () {
                setState(() {
                  _currentIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Timer'),
              onTap: () {
                setState(() {
                  _currentIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
