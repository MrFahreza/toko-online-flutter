import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toko_online_flutter/ui/views/auth/startup_view.dart';
import 'package:toko_online_flutter/ui/widgets/setup_snackbar_ui.dart';
import 'constants/route_name.dart';
import 'package:toko_online_flutter/app/locator.dart';
import 'package:toko_online_flutter/app/router.dart';

/// Fungsi utama aplikasi.
/// 
/// Bertanggung jawab untuk inisialisasi binding Flutter, konfigurasi Supabase,
/// dan setup locator dependency injection.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const String supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Menginisialisasi klien Supabase.
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  setupLocator();

  runApp(const MainApp());
}

/// Widget root utama aplikasi.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  /// @override
  /// Membangun widget root dan menginisialisasi [ScreenUtil].
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {

        /// Panggil setupSnackbarUi setelah ScreenUtil terinisialisasi
        setupSnackbarUi();

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Toko Online',
          theme: ThemeData(useMaterial3: true),
          initialRoute: startupViewRoute,
          onGenerateRoute: generateRoute,
          navigatorKey: StackedService.navigatorKey,
          home: const StartupView(),
        );
      },
    );
  }
}