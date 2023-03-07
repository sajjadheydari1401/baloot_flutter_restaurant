class Profile {
  final String title;
  final String address;
  final String phone;

  Profile({
    required this.title,
    required this.address,
    required this.phone,
  });

  // Define the [] operator to access properties using []
  dynamic operator [](String property) {
    switch (property) {
      case 'title':
        return title;
      case 'address':
        return address;
      case 'phone':
        return phone;
      default:
        throw ArgumentError('Invalid property: $property');
    }
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      title: map['title'],
      address: map['address'],
      phone: map['phone'],
    );
  }
}
