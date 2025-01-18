import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/harcama.dart';
import '../models/kullanici.dart';
import 'package:flutter/foundation.dart';

class VeritabaniYardimcisi {
  static final VeritabaniYardimcisi _instance =
      VeritabaniYardimcisi._internal();
  static Database? _database;

  factory VeritabaniYardimcisi() => _instance;

  VeritabaniYardimcisi._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'harcama_takip.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    debugPrint('Tablolar oluşturuluyor...');

    await db.execute('''
      CREATE TABLE kullanicilar(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        sifre TEXT NOT NULL,
        ad TEXT,
        butce REAL DEFAULT 0,
        butce_belirlendi INTEGER DEFAULT 0
      )
    ''');
    debugPrint('Kullanıcılar tablosu oluşturuldu');

    await db.execute('''
      CREATE TABLE harcamalar(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        baslik TEXT NOT NULL,
        kategori TEXT NOT NULL,
        miktar REAL NOT NULL,
        tarih TEXT NOT NULL,
        kullanici_id INTEGER NOT NULL,
        FOREIGN KEY (kullanici_id) REFERENCES kullanicilar (id)
      )
    ''');
    debugPrint('Harcamalar tablosu oluşturuldu');
  }

  Future<int> kullaniciEkle(Kullanici kullanici) async {
    try {
      final db = await database;
      final id = await db.insert(
        'kullanicilar',
        kullanici.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      debugPrint('Yeni kullanıcı eklendi. ID: $id');
      return id;
    } catch (e) {
      debugPrint('Kullanıcı ekleme hatası: $e');
      rethrow;
    }
  }

  Future<Kullanici?> kullaniciGiris(String email, String sifre) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kullanicilar',
      where: 'email = ? AND sifre = ?',
      whereArgs: [email, sifre],
    );
    if (maps.isEmpty) return null;
    return Kullanici.fromMap(maps.first);
  }

  Future<int> harcamaEkle(Harcama harcama, int kullaniciId) async {
    final db = await database;
    final harcamaMap = harcama.toMap();
    harcamaMap['kullanici_id'] = kullaniciId;
    return await db.insert('harcamalar', harcamaMap);
  }

  Future<List<Harcama>> kullaniciHarcamalari(int kullaniciId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'harcamalar',
      where: 'kullanici_id = ?',
      whereArgs: [kullaniciId],
      orderBy: 'tarih DESC',
    );
    return List.generate(maps.length, (i) => Harcama.fromMap(maps[i]));
  }

  Future<int> harcamaGuncelle(Harcama harcama) async {
    final db = await database;
    return await db.update(
      'harcamalar',
      harcama.toMap(),
      where: 'id = ?',
      whereArgs: [harcama.id],
    );
  }

  Future<int> harcamaSil(int id) async {
    final db = await database;
    return await db.delete(
      'harcamalar',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> kullaniciButce(int kullaniciId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kullanicilar',
      columns: ['butce'],
      where: 'id = ?',
      whereArgs: [kullaniciId],
    );
    return maps.first['butce'] ?? 0.0;
  }

  Future<bool> butceBelirlendiMi(int kullaniciId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kullanicilar',
      columns: ['butce_belirlendi'],
      where: 'id = ?',
      whereArgs: [kullaniciId],
    );
    return maps.first['butce_belirlendi'] == 1;
  }

  Future<bool> butceGuncelle(int kullaniciId, double yeniButce) async {
    try {
      final db = await database;

      final kullanici = await db.query(
        'kullanicilar',
        where: 'id = ?',
        whereArgs: [kullaniciId],
      );

      if (kullanici.isEmpty) {
        debugPrint('Kullanıcı bulunamadı: $kullaniciId');
        return false;
      }

      debugPrint('Mevcut kullanıcı: ${kullanici.first}');
      debugPrint('Yeni bütçe: $yeniButce');

      final sonuc = await db.rawUpdate(
        'UPDATE kullanicilar SET butce = ?, butce_belirlendi = 1 WHERE id = ?',
        [yeniButce, kullaniciId],
      );

      debugPrint('Güncelleme sonucu: $sonuc');
      return sonuc > 0;
    } catch (e, stackTrace) {
      debugPrint('Bütçe güncelleme hatası: $e');
      debugPrint('Hata detayı: $stackTrace');
      return false;
    }
  }
}
