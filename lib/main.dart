import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/search_screen.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';
import 'utils/theme_provider.dart';
import 'utils/ticket_provider.dart';
import 'utils/auth_provider.dart';
import 'utils/favorite_provider.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Create providers
  final themeProvider = ThemeProvider();
  final ticketProvider = TicketProvider();
  final authProvider = AuthProvider();
  final favoriteProvider = FavoriteProvider();
  
  // Run the app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<TicketProvider>.value(value: ticketProvider),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<FavoriteProvider>.value(value: favoriteProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // Ensure status bar color matches theme
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: themeProvider.isDarkMode 
          ? Brightness.light 
          : Brightness.dark,
    ));

    return MaterialApp(
      title: 'Đặt Vé Xem Phim',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
        '/search': (context) => const SearchScreen(),
      },
    );
  }
}
