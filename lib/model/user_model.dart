class UserModel {
  String? Name;
  String? Id;
  String? mobileNumber;
  String? childEmail;
  String? parentEmail;
  String? type;
  UserModel({
    this.Name,
    this.childEmail,
    this.Id,
    this.mobileNumber,
    this.parentEmail,
    this.type,
  });

  Map<String, dynamic> toJson() => {
        'Id': Id,
        'Name': Name,
        'Mobile Number': mobileNumber,
        'Child E-Mail': childEmail,
        'Parent E-mail': parentEmail,
        'Type': type
      };
}
