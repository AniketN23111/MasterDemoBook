import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class EditProfilePage extends StatefulWidget {
  final String profileImageURL; // Receive the profile image URL from ProfilePage
  const EditProfilePage(this.profileImageURL, {super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    }

  void _updateUserProfile() {
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Edit Profile'),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () {
            // Return to the previous page (ProfilePage) without saving changes
            Navigator.pop(context);
          },
        ),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              CupertinoTextField(
                controller: _firstNameController,
                placeholder: 'First Name',
                clearButtonMode: OverlayVisibilityMode.editing,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              const SizedBox(height: 16.0),
              CupertinoTextField(
                controller: _lastNameController,
                placeholder: 'Last Name',
                clearButtonMode: OverlayVisibilityMode.editing,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              const SizedBox(height: 16.0),
              CupertinoTextField(
                controller: _emailController,
                placeholder: 'Email',
                clearButtonMode: OverlayVisibilityMode.editing,
                keyboardType: TextInputType.emailAddress,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              const SizedBox(height: 16.0),
              CupertinoTextField(
                controller: _mobileNumberController,
                placeholder: 'Mobile Number',
                clearButtonMode: OverlayVisibilityMode.editing,
                keyboardType: TextInputType.phone,
                inputFormatters: [LengthLimitingTextInputFormatter(15)],
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              const SizedBox(height: 16.0),
              CupertinoTextField(
                controller: _dateOfBirthController,
                placeholder: 'Date of Birth',
                clearButtonMode: OverlayVisibilityMode.editing,
                keyboardType: TextInputType.text,
                inputFormatters: [LengthLimitingTextInputFormatter(10)],
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              const SizedBox(height: 20.0),
              CupertinoButton.filled(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _updateUserProfile();
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
