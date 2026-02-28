import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../app_style.dart';
import '../widgets/auth_widgets.dart';
import '../services/auth_service.dart';
import '../session.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscure = true;
  final _email = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _name.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _doSignUp() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final user = await AuthService.instance.signUpWithEmail(
        email: _email.text.trim(),
        password: _password.text,
        name: _name.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      );
      if (!mounted || user == null) return;

      // Après création de compte, demander s'il est patient ou docteur.
      final role = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Bienvenue sur DoctorPoint',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kTextColor),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vous êtes médecin ou patient ? Choisissez votre rôle pour personnaliser votre expérience.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: kMutedTextColor),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop('patient'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text('Je suis patient', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop('doctor'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kPrimaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text('Je suis médecin', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kPrimaryColor)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      final uid = user.uid;
      final usersRef = FirebaseFirestore.instance.collection('users').doc(uid);

      if (role == 'doctor') {
        // Mettre à jour le rôle en docteur et lancer le flux spécialité + profil.
        await usersRef.set({'role': 'doctor'}, SetOptions(merge: true));
        appSession.setRole(UserRole.doctor);
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.doctorSpecialty, (r) => false);
      } else {
        // Rester patient par défaut.
        await usersRef.set({'role': 'patient'}, SetOptions(merge: true));
        appSession.setRole(UserRole.patient);
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.homePatient, (r) => false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign up failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Stack(
          children: [
            // Fond dégradé + bulles floutées pour un effet 3D subtil
            Positioned(
              top: -80,
              left: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF34D399), Color(0xFF0EA5E9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -90,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFA5B4FC), Color(0xFF22C55E)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: authMaxWidthConstraints(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      const Center(
                        child: Image(
                          image: AssetImage('asset/Logo_maquette.png'),
                          width: 150,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: Text(
                          'Create your account',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: kTextColor,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'Join DoctorPoint to connect with your doctor anytime.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: kMutedTextColor),
                        ),
                      ),
                      const SizedBox(height: 22),
                      // Carte 3D contenant le formulaire
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.96, end: 1.0),
                        duration: const Duration(milliseconds: 420),
                        curve: Curves.easeOutBack,
                        builder: (context, t, child) {
                          final scale = t;
                          final dy = (1 - t) * 16;
                          return Transform.translate(
                            offset: Offset(0, dy),
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.0015)
                                ..rotateX((1.0 - scale) * 0.14)
                                ..rotateY((1.0 - scale) * -0.06),
                              child: Transform.scale(
                                scale: scale,
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x19000000),
                                blurRadius: 26,
                                offset: Offset(0, 18),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AuthField(
                                label: 'Email',
                                hint: 'you@example.com',
                                prefix: Icons.mail_outline,
                                keyboardType: TextInputType.emailAddress,
                                controller: _email,
                              ),
                              const SizedBox(height: 20),
                              AuthField(
                                label: 'Name',
                                hint: 'Enter your full name',
                                prefix: Icons.person_outline,
                                controller: _name,
                              ),
                              const SizedBox(height: 20),
                              PhoneField(controller: _phone),
                              const SizedBox(height: 20),
                              AuthField(
                                label: 'Password',
                                hint: 'Enter password',
                                prefix: Icons.lock_outline,
                                obscureText: _obscure,
                                suffix: IconButton(
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: const Color(0xFF9CA3B7),
                                  ),
                                ),
                                controller: _password,
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _doSignUp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    _loading ? 'Please wait...' : 'Create account',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: BottomQuestionLink(
                          question: 'Already have an account? ',
                          action: 'Sign in',
                          onTap: () => Navigator.of(context)
                              .pushReplacementNamed(AppRoutes.signIn),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const OrDivider(label: 'Or Sign up with'),
                      const SizedBox(height: 16),
                      const SocialRow(),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
