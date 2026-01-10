import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_routes.dart';
import 'app_style.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/doctor_specialty_screen.dart';
import 'screens/setup_profile_screen.dart';
import 'screens/home_patient_screen.dart';
import 'screens/home_doctor_screen.dart';
import 'screens/doctors_list_screen.dart';
import 'screens/doctor_detail_screen.dart';
import 'screens/appointment_screen.dart';
import 'screens/patient_details_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/search_screen.dart';
import 'screens/appointments_screen.dart';
import 'screens/appointment_detail_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/voice_call_screen.dart';
import 'screens/video_call_screen.dart';
import 'screens/call_ended_screen.dart';
import 'screens/message_ended_screen.dart';
import 'screens/write_review_screen.dart';
import 'screens/incoming_call_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/pro_member_screen.dart';
import 'screens/faqs_screen.dart';
import 'screens/help_screen.dart';
import 'screens/invite_friend_screen.dart';
import 'screens/favourite_doctors_screen.dart';
import 'services/firebase_initializer.dart';
import 'session.dart';

void main() async {
  await FirebaseInitializer.init();
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString('locale');
  if (code != null && code.isNotEmpty) {
    appSession.setLocale(Locale(code));
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appSession,
      builder: (context, _) {
        return MaterialApp(
      title: 'DoctorPoint',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: ThreeDPageTransitionsBuilder(),
            TargetPlatform.iOS: ThreeDPageTransitionsBuilder(),
            TargetPlatform.macOS: ThreeDPageTransitionsBuilder(),
            TargetPlatform.windows: ThreeDPageTransitionsBuilder(),
            TargetPlatform.linux: ThreeDPageTransitionsBuilder(),
            TargetPlatform.fuchsia: ThreeDPageTransitionsBuilder(),
          },
        ),
      ),
      debugShowCheckedModeBanner: false,
      locale: appSession.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('bn'),
        Locale('nl'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.onboarding: (_) => const OnboardingScreen(),
        AppRoutes.auth: (_) => const AuthChoiceScreen(),
        AppRoutes.signIn: (_) => const SignInScreen(),
        AppRoutes.signUp: (_) => const SignUpScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppRoutes.otp: (_) => const OtpScreen(),
        AppRoutes.resetPassword: (_) => const ResetPasswordScreen(),
        // Post-auth prototype
        AppRoutes.roleSelection: (_) => const RoleSelectionScreen(),
        AppRoutes.doctorSpecialty: (_) => const DoctorSpecialtyScreen(),
        AppRoutes.setupProfile: (_) => const SetupProfileScreen(),
        AppRoutes.homePatient: (_) => const HomePatientScreen(),
        AppRoutes.homeDoctor: (_) => const HomeDoctorScreen(),
        AppRoutes.doctorsList: (_) => const DoctorsListScreen(),
        AppRoutes.doctorDetail: (_) => const DoctorDetailScreen(),
        AppRoutes.appointment: (_) => const AppointmentScreen(),
        AppRoutes.patientDetails: (_) => const PatientDetailsScreen(),
        AppRoutes.payment: (_) => const PaymentScreen(),
        AppRoutes.notifications: (_) => const NotificationsScreen(),
        AppRoutes.search: (_) => const SearchScreen(),
        AppRoutes.appointments: (_) => const AppointmentsScreen(),
        AppRoutes.appointmentDetail: (_) => const AppointmentDetailScreen(),
        AppRoutes.chat: (_) => const ChatScreen(),
        AppRoutes.voiceCall: (_) => const VoiceCallScreen(),
        AppRoutes.videoCall: (_) => const VideoCallScreen(),
        AppRoutes.callEnded: (_) => const CallEndedScreen(),
        AppRoutes.messageEnded: (_) => const MessageEndedScreen(),
        AppRoutes.writeReview: (_) => const WriteReviewScreen(),
        AppRoutes.incomingCall: (_) => const IncomingCallScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
        AppRoutes.editProfile: (_) => const EditProfileScreen(),
        AppRoutes.proMember: (_) => const ProMemberScreen(),
        AppRoutes.faqs: (_) => const FaqsScreen(),
        AppRoutes.help: (_) => const HelpScreen(),
        AppRoutes.inviteFriend: (_) => const InviteFriendScreen(),
        AppRoutes.favouriteDoctors: (_) => const FavouriteDoctorsScreen(),
      },
    );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _textCtrl;
  late final Animation<double> _rotationX;
  late final Animation<double> _rotationY;
  late final Animation<double> _scale;
  late final Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed && mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
        }
      });
    _rotationX = Tween<double>(begin: -math.pi, end: 0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _rotationY = Tween<double>(begin: math.pi, end: 0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.2).chain(CurveTween(curve: Curves.easeOutBack)), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 40),
    ]).animate(_controller);
    _controller.forward();
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _textOpacity = CurvedAnimation(parent: _textCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final m = Matrix4.identity()
                    ..setEntry(3, 2, 0.0035)
                    ..rotateX(_rotationX.value)
                    ..rotateY(_rotationY.value);
                  return Transform(
                    transform: m,
                    alignment: Alignment.center,
                    child: Transform.scale(scale: _scale.value, child: child),
                  );
                },
                child: const Image(
                  image: AssetImage('asset/Logo_maquette.png'),
                  width: 240,
                ),
              ),
              const SizedBox(height: 12),
              FadeTransition(
                opacity: _textOpacity,
                child: const Text(
                  'Welcome  to Version3.0',
                  style: TextStyle(color: Color(0xFF0F9D58), fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ThreeDPageTransitionsBuilder extends PageTransitionsBuilder {
  const ThreeDPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic);
    return AnimatedBuilder(
      animation: curved,
      builder: (context, _) {
        final t = curved.value;
        final angle = (1 - t) * math.pi / 3;
        final m = Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..rotateY(angle);
        final s = 0.9 + 0.1 * t;
        return Transform(
          transform: m,
          alignment: Alignment.center,
          child: Transform.scale(
            scale: s,
            child: Opacity(
              opacity: t.clamp(0.0, 1.0),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _controller;
  int _index = 0;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      imagePath: 'asset/Page_2.png',
      title: 'Thousands of doctors',
      subtitle:
          'Access thousands of Doctors instantly.\nYou can easily contact with the doctors\nand contact for your needs.',
    ),
    _OnboardingPageData(
      imagePath: 'asset/Page3.png',
      title: 'Live talk with doctor',
      subtitle:
          'Easily connect with doctor and start\nvideo chat for your better treatment &\nPrescription.',
    ),
    _OnboardingPageData(
      imagePath: 'asset/Page4.png',
      title: 'Chat with doctors',
      subtitle:
          'Book an appointment with doctor. Chat\nwith doctor via appointment letter.\nGet consultant.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_index < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      return;
    }
    Navigator.of(context).pushReplacementNamed(AppRoutes.auth);
  }

  void _skip() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.auth);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isWide = size.width >= 700;
    final double headerHeight = (size.height * (isWide ? 0.42 : 0.52))
        .clamp(isWide ? 240.0 : 320.0, isWide ? 360.0 : 520.0)
        .toDouble();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView.builder(
          controller: _controller,
          itemCount: _pages.length,
          onPageChanged: (value) => setState(() => _index = value),
          itemBuilder: (context, i) {
            final page = _pages[i];
            return Column(
              children: [
                _OnboardingHeader(imagePath: page.imagePath, height: headerHeight),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 18, bottom: 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: _OnboardingCard(
                          title: page.title,
                          subtitle: page.subtitle,
                          activeIndex: _index,
                          onGetStarted: _goNext,
                          onSkip: _skip,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final String imagePath;
  final String title;
  final String subtitle;

  const _OnboardingPageData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });
}

class _OnboardingHeader extends StatelessWidget {
  final String imagePath;
  final double height;

  const _OnboardingHeader({required this.imagePath, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          ClipPath(
            clipper: _CurvedBottomClipper(),
            child: SizedBox.expand(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _CurvedBottomStrokePainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int activeIndex;
  final VoidCallback onGetStarted;
  final VoidCallback onSkip;

  const _OnboardingCard({
    required this.title,
    required this.subtitle,
    required this.activeIndex,
    required this.onGetStarted,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: kTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.45,
              color: kMutedTextColor,
            ),
          ),
          const SizedBox(height: 18),
          _OnboardingIndicator(activeIndex: activeIndex),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onGetStarted,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Get started',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onSkip,
            child: const Text(
              'Skip for now',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFFCBCDD6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingIndicator extends StatelessWidget {
  final int activeIndex;

  const _OnboardingIndicator({required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final bool active = i == activeIndex;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: active
              ? const Icon(Icons.add, size: 18, color: kPrimaryColor)
              : Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFBFD7D2),
                  ),
                ),
        );
      }),
    );
  }
}

class _CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 44);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height,
      size.width,
      size.height - 44,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _CurvedBottomStrokePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = const Color(0xFFBFD7D2);

    final path = Path();
    path.moveTo(0, size.height - 44);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height,
      size.width,
      size.height - 44,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isWide = size.width >= 700;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 520 : double.infinity),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  const Image(
                    image: AssetImage('asset/Logo_maquette.png'),
                    width: 210,
                  ),
                  const SizedBox(height: 36),
                  const Text(
                    'Create a free account',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: kTextColor,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.signUp),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Create an account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.signIn),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimaryColor,
                        side: const BorderSide(color: Color(0xFFE8EAF0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
