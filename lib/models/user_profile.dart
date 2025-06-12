class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String meterNumber;
  final String monthlyBill; 
  final String householdSize;
  final String averageConsumption;
  final String electricityProvider;
  final String tariffPlan;
  final List<String> appliances;
  final bool profileCompleted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.address,
    required this.meterNumber, 
    required this.monthlyBill, 
    required this.householdSize,
    required this.averageConsumption,
    required this.electricityProvider,
    required this.tariffPlan,
    required this.appliances,
    this.profileCompleted = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      meterNumber: map['meterNumber'] ?? '', // 🆕 NOUVEAU
      monthlyBill: map['monthlyBill'] ?? '', // 🆕 NOUVEAU
      householdSize: map['householdSize'] ?? '',
      averageConsumption: map['averageConsumption'] ?? '',
      electricityProvider: map['electricityProvider'] ?? '',
      tariffPlan: map['tariffPlan'] ?? '',
      appliances: List<String>.from(map['appliances'] ?? []),
      profileCompleted: map['profileCompleted'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'meterNumber': meterNumber, // 🆕 NOUVEAU
      'monthlyBill': monthlyBill, // 🆕 NOUVEAU
      'householdSize': householdSize,
      'averageConsumption': averageConsumption,
      'electricityProvider': electricityProvider,
      'tariffPlan': tariffPlan,
      'appliances': appliances,
      'profileCompleted': profileCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'UserProfile{uid: $uid, name: $name, email: $email, meterNumber: $meterNumber, monthlyBill: $monthlyBill, profileCompleted: $profileCompleted}';
  }
}