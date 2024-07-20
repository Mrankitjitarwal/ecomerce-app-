class Users {
 // int id;
  String name;
  String email;
  String password;

  Users(
     // this.id,
      this.name,
      this.email,
      this.password,
      );

  Map<String, dynamic> toJson()=>
      {
        //'id': id.toString(),
        'name': name,
        'email':email,
        'password':password,
      };
}