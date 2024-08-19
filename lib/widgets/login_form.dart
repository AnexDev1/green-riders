import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
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
    return Form(
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
            padding: const EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
            child: TextFormField(
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.next,
              onSaved: (String? val) {
                email = val;
              },
              style: const TextStyle(fontSize: 18.0),
              keyboardType: TextInputType.emailAddress,
              cursorColor: const Color(0xFF00A86B),
              decoration: InputDecoration(
                hintText: 'Email Address',
                errorStyle: TextStyle(color: Colors.red),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
            child: TextFormField(
              textAlignVertical: TextAlignVertical.center,
              obscureText: true,
              onSaved: (String? val) {
                password = val;
              },
              textInputAction: TextInputAction.done,
              style: const TextStyle(fontSize: 18.0),
              cursorColor: const Color(0xFF00A86B),
              decoration: InputDecoration(
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
              child: const Text(
                'Log In',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onPressed: _login,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                'OR',
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 40.0, left: 40.0, bottom: 20),
            child: ElevatedButton.icon(
              label: const Text(
                'Facebook Login',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              icon: Image.asset(
                'assets/images/facebook_logo.png',
                color: Colors.white,
                height: 24,
                width: 24,
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: const Color(0xFF3B5998),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: const BorderSide(
                    color: Color(0xFF3B5998),
                  ),
                ),
              ),
              onPressed: () {
                // Handle Facebook login
              },
            ),
          ),
          // Apple Sign-In button can be added here if needed
        ],
      ),
    );
  }
}
