import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);
    final supabase = ref.read(supabaseProvider);

    try {
      if (_isSignUp) {
        await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Welcome to AU Fuel! Your account is ready.'),
              backgroundColor: Color(0xFF0D4D44),
            ),
          );
        }
      } else {
        await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Accent Section
            Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF0D4D44),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_gas_station, size: 80, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    'AU FUEL',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'Smarter Fueling, Every Day',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isSignUp ? 'Create Account' : 'Welcome Back',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E3D2F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignUp 
                      ? 'Sign up to sync your favorite stations across devices.' 
                      : 'Login to access your saved alerts and fuel logs.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // AutofillGroup helps the OS bundle these fields together
                  AutofillGroup(
                    child: Column(
                      children: [
                        // Email Field
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          icon: Icons.email_outlined,
                          hint: 'name@example.com',
                          autofillHints: [AutofillHints.email, AutofillHints.username],
                        ),
                        const SizedBox(height: 20),
                        
                        // Password Field
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          hint: '••••••••',
                          autofillHints: [
                            _isSignUp ? AutofillHints.newPassword : AutofillHints.password,
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D4D44),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isSignUp ? 'Create Account' : 'Login Now',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Toggle Text
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() => _isSignUp = !_isSignUp),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(color: Colors.black54, fontSize: 14),
                          children: [
                            TextSpan(text: _isSignUp ? 'Already have an account? ' : 'New here? '),
                            TextSpan(
                              text: _isSignUp ? 'Login' : 'Create Account',
                              style: const TextStyle(
                                color: Color(0xFF0D4D44),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    required String hint,
    required List<String> autofillHints,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E3D2F).withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            autofillHints: autofillHints,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black26),
              prefixIcon: Icon(icon, color: const Color(0xFF0D4D44).withOpacity(0.7)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
