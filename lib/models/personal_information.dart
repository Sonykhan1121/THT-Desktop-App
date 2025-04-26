class personalInformation {
  final String? id;
  final String shortDescription;
  final String phone;
  final String email;
  final String degree;
  final String address;
  personalInformation({
     this.id,
    required this.shortDescription,
    required this.phone,
    required this.email,
    required this.degree,
    required this.address,

});
  factory personalInformation.fromMap(Map<String, dynamic> data , String id)
  {
    return personalInformation(shortDescription: data['shortDescription'] ?? '', phone: data['phone'] ?? "", email: data['email'] ?? '', degree: data['degree'] ?? '', address: data['address'] ?? '');
  }
  Map<String, dynamic> toMap()
  {
    return {
      'shortDescription' : shortDescription,
      'phone' :phone,
      'email' :email,
      'degree' : degree,
      'address' :address
    };
  }


}