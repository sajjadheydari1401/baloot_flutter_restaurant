import 'package:flutter/foundation.dart';
import 'package:mousavi/models/models.dart';
import '../helpers/db_helper.dart';

class Profiles with ChangeNotifier {
  Profile _profile = Profile(address: '', phone: '', title: '');

  Profile get profile {
    return _profile;
  }

  Future<void> updateMyProfile(
      String title, String address, String phone) async {
    await DBHelper.updateProfile(title, address, phone);
    notifyListeners();
  }

  Future<Profile> fetchProfile() async {
    final savedProfiles = await DBHelper.getData('profiles');
    if (savedProfiles.isEmpty) {
      await DBHelper.insert('profiles', {
        'title': 'عنوان پیش فرض',
        'address': 'آدرس پیش فرض',
        'phone': 'تلفن پیش فرض',
      });
      notifyListeners();
      return _profile;
    } else {
      final savedProfile = savedProfiles.first;
      _profile = Profile(
        title: savedProfile['title'],
        address: savedProfile['address'],
        phone: savedProfile['phone'],
      );

      notifyListeners();
      return _profile;
    }
  }
}
