import 'package:flutter/material.dart';
import 'package:mousavi/models/models.dart';
import 'package:mousavi/providers/profiles_provider.dart';
import 'package:mousavi/widgets/widgets.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isInit = true;
  bool _isLoading = false;
  bool _isFormValid = false;

  late TextEditingController _titleController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late Profile myProfile;

  @override
  void initState() {
    super.initState();

    final profilesProvider = Provider.of<Profiles>(context, listen: false);
    profilesProvider.fetchProfile().then((profile) {
      setState(() {
        myProfile = profile;
        _titleController = TextEditingController(text: myProfile.title);
        _addressController = TextEditingController(text: myProfile.address);
        _phoneController = TextEditingController(text: myProfile.phone);
        _isFormValid = isFormValid();
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Profiles>(context).fetchProfile().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  bool isFormValid() {
    return _titleController.text.trim().isNotEmpty &&
        _addressController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty;
  }

  void _saveProfile(BuildContext context) async {
    final profilesProvider = Provider.of<Profiles>(context, listen: false);
    final title = _titleController.text;
    final address = _addressController.text;
    final phone = _phoneController.text;
    await profilesProvider.updateMyProfile(title, address, phone);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green[300],
        content: const Text('پروفایل بروزرسانی شد'),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profilesProvider = Provider.of<Profiles>(context, listen: false);
    dynamic myProfile = profilesProvider.profile;
    return Scaffold(
      appBar: const CustomAppBar(title: 'پروفایل من'),
      bottomNavigationBar: const CustomNavBar(currentTabIndex: 2),
      body: Center(
        child: Container(
          alignment: Alignment.center,
          width: 400,
          margin: const EdgeInsets.only(top: 30),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              if (_isLoading)
                const CircularProgressIndicator()
              else if (myProfile != null)
                Form(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 50,
                        child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              _isFormValid = isFormValid();
                            });
                          },
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          controller: _titleController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.name,
                          decoration: const InputDecoration(
                            labelText: 'عنوان',
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 50,
                        child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              _isFormValid = isFormValid();
                            });
                          },
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          controller: _addressController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.name,
                          decoration: const InputDecoration(
                            labelText: 'آدرس',
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 50,
                        child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              _isFormValid = isFormValid();
                            });
                          },
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          controller: _phoneController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.name,
                          decoration: const InputDecoration(
                            labelText: 'تلفن',
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 150,
                        height: 50,
                        child: IgnorePointer(
                          ignoring: !isFormValid(),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff70e000),
                            ),
                            onPressed: isFormValid()
                                ? () => _saveProfile(context)
                                : null,
                            child: const Text(
                              'ذخیره پروفایل',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
