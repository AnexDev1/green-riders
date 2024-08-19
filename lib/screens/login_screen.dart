import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _key = GlobalKey();
  AutovalidateMode _validate = AutovalidateMode.disabled;
  String? email, password;

  Future<void> _login() async {
    if (_key.currentState!.validate()) {
      _key.currentState!.save();
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email!,
          password: password!,
        );
        // Navigate to home screen or show success message
      } on FirebaseAuthException catch (e) {
        // Handle login error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Login failed')),
        );
      }
    } else {
      setState(() {
        _validate = AutovalidateMode.onUserInteraction;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Form(
        key: _key,
        autovalidateMode: _validate,
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 32.0, right: 16.0, left: 16.0),
              child: Text(
                'Sign In',
                style: TextStyle(
                    color: Color(0xFF00A86B),
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
              child: TextFormField(
                textAlignVertical: TextAlignVertical.center,
                textInputAction: TextInputAction.next,
                onSaved: (String? val) {
                  email = val;
                },
                style: const TextStyle(fontSize: 18.0),
                keyboardType: TextInputType.emailAddress,
                cursorColor: const Color(0xFF00A86B),
                decoration: const InputDecoration(
                  hintText: 'Email Address',
                  errorStyle: TextStyle(color: Colors.red),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
              child: TextFormField(
                textAlignVertical: TextAlignVertical.center,
                obscureText: true,
                onSaved: (String? val) {
                  password = val;
                },
                textInputAction: TextInputAction.done,
                style: const TextStyle(fontSize: 18.0),
                cursorColor: const Color(0xFF00A86B),
                decoration: const InputDecoration(
                  hintText: 'Password',
                  errorStyle: TextStyle(color: Colors.red),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16, right: 24),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    // Navigate to ResetPasswordScreen
                  },
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                        color: Colors.lightBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 1),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  backgroundColor: const Color(0xFF00A86B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: const BorderSide(
                      color: Color(0xFF00A86B),
                    ),
                  ),
                ),
                onPressed: _login,
                child: const Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Apple Sign-In button can be added here if needed
          ],
        ),
      ),
    );
  }
}
