import 'package:fake_vision/resources/auth_methods.dart';
import 'package:fake_vision/screens/login_screen.dart';
import 'package:fake_vision/utils/colors.dart';
import 'package:fake_vision/utils/global_variables.dart';
import 'package:fake_vision/utils/utils.dart';
import 'package:fake_vision/widgets/text_field_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isLoading = false;
  //The Uint8List is particularly useful when you are dealing with binary data or
  //interfacing with lower-level APIs, such as working with images, files, or network data.
  Uint8List? _image;

  void initState() {
    super.initState();

    // Set the status bar color when the screen is created
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: colorStatusBar, // Set your desired status bar color
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
  }

  void sign_up_user() async {
    // set loading to true

    setState(() {
      _isLoading = true;
    });

    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _bioController.text.isEmpty ||
        _image == null) {
      showSnackBar(context, "Please fill all the fields and select an image");
      setState(() {
        _isLoading = false;
      });
      return;
    }
    // signup user using our authmethods
    String res = await AuthMethods().signUpUser(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
        bio: _bioController.text,
        file: _image!);

    // if string returned is success, user has been created
    if (res == "success") {
      // navigate to the home screen
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    } else if (res == "Please fill all the fields!!") {
      showSnackBar(context, res);
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      // show the error
      if (context.mounted) {
        //will return true if widget is in tree
        showSnackBar(context, res);
      }
    }
  }

  selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    // set state because we need to display the image we selected on the circle avatar
    setState(() {
      _image = im;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('Images/bg16.png'), fit: BoxFit.fill),
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color.fromRGBO(20, 37, 83, 1), // light blue
                    Color.fromARGB(255, 22, 54, 70) // dark blue
                  ]),
            ),
            padding: MediaQuery.of(context).size.width > webScreenSize
                ? EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 4)
                : const EdgeInsets.symmetric(horizontal: 30),
            //full width of device
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
      height: 50, // Adjust the height as needed
    ),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [blue, green],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: Text(
                    'Let\'s Get Started',
                    style: TextStyle(
                      fontSize: 25.0,
                      fontFamily: 'Inter',
                      // The color must be set to white for the gradient to show
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  "Get registered and continue with us!",
                  style: TextStyle(
                      fontSize: 13, color: whiteColor, fontFamily: 'Inter'),
                ),
                const SizedBox(
                  height: 34,
                ),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _image != null
                          ? CircleAvatar(
                              radius: 64,
                              backgroundImage: MemoryImage(_image!),
                              backgroundColor:
                                  Color.fromARGB(255, 54, 114, 244),
                            )
                          : const CircleAvatar(
                              radius: 64,
                              backgroundImage: NetworkImage(
                                  'https://i.stack.imgur.com/l60Hf.png'),
                              backgroundColor: Colors.blue,
                            ),
                      Positioned(
                        bottom: -10,
                        left: 80,
                        child: IconButton(
                          onPressed: selectImage,
                          icon: const Icon(Icons.add_a_photo),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    color: whiteColor,
                  ),
                  child: TextFieldInput(
                    hintText: 'Enter your username',
                    textInputType: TextInputType.text,
                    textEditingController: _usernameController,
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    color: whiteColor,
                  ),
                  child: TextFieldInput(
                    hintText: 'Enter your email',
                    textInputType: TextInputType.emailAddress,
                    textEditingController: _emailController,
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    color: whiteColor,
                  ),
                  child: TextFieldInput(
                    hintText: 'Enter your password',
                    textInputType: TextInputType.text,
                    textEditingController: _passwordController,
                    isPassword: true,
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    color: whiteColor,
                  ),
                  child: TextFieldInput(
                    hintText: 'Enter your bio',
                    textInputType: TextInputType.text,
                    textEditingController: _bioController,
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                InkWell(
                  onTap: sign_up_user,
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color.fromRGBO(53, 102, 172, 1), // light blue
                            Color.fromARGB(255, 106, 175, 169) // dark blue
                          ]),
                    ),
                    child: !_isLoading
                        ? const Text('Sign up',
                            style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Inter',
                                color: whiteColor))
                        : const CircularProgressIndicator(
                            color: whiteColor,
                          ),
                  ),
                ),
                const SizedBox(
                  height: 77,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text('Already have an account?',
                          style: TextStyle(
                              color: whiteColor,
                              fontFamily: 'Inter',
                              fontSize: 13)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Text(
                          ' Login',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: blue,
                              fontFamily: 'Inter',
                              fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
