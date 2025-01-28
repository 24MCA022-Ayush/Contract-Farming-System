import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../values/app_regex.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';


import '../components/app_text_form_field.dart';
import '../resources/resources.dart';
import '../utils/common_widgets/gradient_background.dart';
import '../utils/helpers/navigation_helper.dart';
import '../values/app_constants.dart';
import '../values/app_routes.dart';
import '../values/app_strings.dart';
import '../values/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
{
  final _formKey = GlobalKey<FormState>();

  final ValueNotifier<bool> passwordNotifier = ValueNotifier(true);
  final ValueNotifier<bool> fieldValidNotifier = ValueNotifier(false);

  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  bool _isLoading = false;

  void initializeControllers() {
    emailController = TextEditingController()..addListener(controllerListener);
    passwordController = TextEditingController()
      ..addListener(controllerListener);
  }

  void disposeControllers() {
    emailController.dispose();
    passwordController.dispose();
  }

  void controllerListener() {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty && password.isEmpty) return;

    if (AppRegex.emailRegex.hasMatch(email) &&
        AppRegex.passwordRegex.hasMatch(password)) {
      fieldValidNotifier.value = true;
    } else {
      fieldValidNotifier.value = false;
    }
  }

  Future<void> _signInWithEmailAndPassword() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      if (!_formKey.currentState!.validate()) {
                return; // Don't proceed if form is invalid
      }

      final args = ModalRoute.of(context)?.settings.arguments;
      final userType = args is String ? args : null;

      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Navigate to home page after successful login
      if (mounted && userCredential.user != null && userType != null) {
        // 1. Fetch the user's document from Firestore based on their UID
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection(userType)
            .doc(userCredential.user!.uid)
            .get();

        // 2. Check if the document exists and if the 'userType' field matches
        if (userDoc.exists && userDoc['userType'] == userType) {
          // Check If Users Details Are Registered Or Not
          if(userDoc['isRegistered'] == true)
          {
            // If Users Details Are Registered then, Go To Its Profile Page
            if(userType=='Farmer') {
              Navigator.pushReplacementNamed(context, AppRoutes.farmer_profile, arguments: userType);
            }
            else if(userType=='FCO'){}
            else if(userType=='Buyer'){}
          }
          else
          {
            // If Users Details Are Not Registered then, Go To Its Register Page
            if(userType=='Farmer') {
              Navigator.pushReplacementNamed(context, AppRoutes.farmer_register, arguments: userType);
            }
            else if(userType=='FCO'){}
            else if(userType=='Buyer'){}
          }

        }
        else {
            //  Sign out and show an error message)
          await FirebaseAuth.instance.signOut(); // Sign out the incorrect user
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid User Type For This Account.')),);
        }

      }

    } on FirebaseAuthException catch (e) {
      // Handle login errors (e.g., wrong password, user not found)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid Login Details.')));
    }
    finally {
      setState(() {
        _isLoading = false; // Hide loading indicator in finally block
      });
    }
  }

  @override
  void initState() {
    initializeControllers();
    super.initState();
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final userType = args is String ? args : null;

    return Scaffold(
      body: _isLoading  // Conditionally show loading indicator or the login form
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: EdgeInsets.zero,
        children: [
          const GradientBackground(
            children:
            [
              Text(
                AppStrings.signInToYourNAccount,
                style: AppTheme.titleLarge,
              ),
              SizedBox(height: 6),
              Text(AppStrings.signInToYourAccount, style: AppTheme.bodySmall),

            ],

          ),

          // Display userType AFTER the GradientBackground
          if (userType != null)
            Padding(
              padding: const EdgeInsets.all(16.0), // Add padding
              child: Text(
                'User Type: $userType',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [

                  // Email
                  AppTextFormField(
                    controller: emailController,
                    labelText: AppStrings.email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _formKey.currentState?.validate(),
                    validator: (value) {
                      return value!.isEmpty
                          ? AppStrings.pleaseEnterEmailAddress
                          : AppConstants.emailRegex.hasMatch(value)
                              ? null
                              : AppStrings.invalidEmailAddress;
                    },
                  ),

                  // Password
                  ValueListenableBuilder(
                    valueListenable: passwordNotifier,
                    builder: (_, passwordObscure, __) {
                      return AppTextFormField(
                        obscureText: passwordObscure,
                        controller: passwordController,
                        labelText: AppStrings.password,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.visiblePassword,
                        onChanged: (_) => _formKey.currentState?.validate(),
                        validator: (value) {
                          return value!.isEmpty
                              ? AppStrings.pleaseEnterPassword
                              : AppConstants.passwordRegex.hasMatch(value)
                                  ? null
                                  : AppStrings.invalidPassword;
                        },
                        suffixIcon: IconButton(
                          onPressed: () =>
                              passwordNotifier.value = !passwordObscure,
                          style: IconButton.styleFrom(
                            minimumSize: const Size.square(48),
                          ),
                          icon: Icon(
                            passwordObscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      );
                    },
                  ),

                  // Forgot Password
                  TextButton(
                    onPressed: () {},
                    child: const Text(AppStrings.forgotPassword),
                  ),

                  // Login Button
                  const SizedBox(height: 20),
                  ValueListenableBuilder(
                    valueListenable: fieldValidNotifier,
                    builder: (_, isValid, __) {
                      return FilledButton(
                        onPressed: _signInWithEmailAndPassword,
                        child: const Text(AppStrings.login),
                      );
                    },
                  ),


                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade200)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          AppStrings.orLoginWith,
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade200)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: SvgPicture.asset(Vectors.google, width: 14),
                          label: const Text(
                            AppStrings.google,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),


                      const SizedBox(width: 20),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: SvgPicture.asset(Vectors.facebook, width: 14),
                          label: const Text(
                            AppStrings.facebook,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.doNotHaveAnAccount,
                style: AppTheme.bodySmall.copyWith(color: Colors.black),
              ),
              const SizedBox(width: 4),
              TextButton(
                onPressed: () {
                    Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.register,
                        arguments: userType);
                },
                child: const Text(AppStrings.register),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
