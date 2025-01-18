class Harcama {
  final int? id;
  final String baslik;
  final String kategori;
  final double miktar;
  final DateTime tarih;

  Harcama({
    this.id,
    required this.baslik,
    required this.kategori,
    required this.miktar,
    required this.tarih,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'baslik': baslik,
      'kategori': kategori,
      'miktar': miktar,
      'tarih': tarih.toIso8601String(),
    };
  }

  factory Harcama.fromMap(Map<String, dynamic> map) {
    return Harcama(
      id: map['id'],
      baslik: map['baslik'],
      kategori: map['kategori'],
      miktar: map['miktar'],
      tarih: DateTime.parse(map['tarih']),
    );
  }
}
