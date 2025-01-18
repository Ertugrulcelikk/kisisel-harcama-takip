class Kullanici {
  final int? id;
  final String email;
  final String sifre;
  final String? ad;

  Kullanici({
    this.id,
    required this.email,
    required this.sifre,
    this.ad,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'sifre': sifre,
      'ad': ad,
    };
  }

  factory Kullanici.fromMap(Map<String, dynamic> map) {
    return Kullanici(
      id: map['id'],
      email: map['email'],
      sifre: map['sifre'],
      ad: map['ad'],
    );
  }
}
