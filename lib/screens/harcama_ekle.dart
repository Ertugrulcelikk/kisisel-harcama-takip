import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/veritabani_yardimcisi.dart';
import '../models/harcama.dart';

class HarcamaEkle extends StatefulWidget {
  final int kullaniciId;

  const HarcamaEkle({
    super.key,
    required this.kullaniciId,
  });

  @override
  State<HarcamaEkle> createState() => _HarcamaEkleState();
}

class _HarcamaEkleState extends State<HarcamaEkle> {
  final _formKey = GlobalKey<FormState>();
  final _baslikController = TextEditingController();
  final _miktarController = TextEditingController();
  final _db = VeritabaniYardimcisi();
  String _secilenKategori = 'Yiyecek';
  DateTime _secilenTarih = DateTime.now();
  double _butce = 0;
  double _toplamHarcama = 0;

  final List<String> _kategoriler = [
    'Yiyecek',
    'Ulaşım',
    'Alışveriş',
    'Faturalar',
    'Eğlence',
    'Diğer',
  ];

  final List<String> _aylar = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık'
  ];

  String _tarihFormatla(DateTime tarih) {
    return '${tarih.day} ${_aylar[tarih.month - 1]} ${tarih.year}';
  }

  @override
  void initState() {
    super.initState();
    _butceVeHarcamalariGetir();
  }

  Future<void> _butceVeHarcamalariGetir() async {
    final butce = await _db.kullaniciButce(widget.kullaniciId);
    final harcamalar = await _db.kullaniciHarcamalari(widget.kullaniciId);
    final toplam = harcamalar.fold<double>(
      0,
      (toplam, harcama) => toplam + harcama.miktar,
    );
    setState(() {
      _butce = butce;
      _toplamHarcama = toplam;
    });
  }

  Widget _butceDurumu() {
    if (_butce == 0) return const SizedBox.shrink();

    final kalanButce = _butce - _toplamHarcama;
    final yeniMiktar = double.tryParse(_miktarController.text) ?? 0;
    final yeniKalanButce = kalanButce - yeniMiktar;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: yeniKalanButce < 0 ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              yeniKalanButce < 0 ? Colors.red.shade200 : Colors.green.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kalan Bütçe:',
                style: TextStyle(
                  color: yeniKalanButce < 0
                      ? Colors.red.shade700
                      : Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                NumberFormat.currency(locale: 'tr_TR', symbol: '₺')
                    .format(kalanButce),
                style: TextStyle(
                  color: yeniKalanButce < 0
                      ? Colors.red.shade700
                      : Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (yeniMiktar > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Harcama Sonrası:',
                  style: TextStyle(
                    color:
                        yeniKalanButce < 0 ? Colors.red : Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  NumberFormat.currency(locale: 'tr_TR', symbol: '₺')
                      .format(yeniKalanButce),
                  style: TextStyle(
                    color:
                        yeniKalanButce < 0 ? Colors.red : Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Yeni Harcama',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_butce == 0)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _butceDuzenle(),
              tooltip: 'Bütçe Belirle',
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _butceDurumu(),
                TextFormField(
                  controller: _baslikController,
                  decoration: InputDecoration(
                    labelText: 'Harcama Başlığı',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir başlık girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _secilenKategori,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: Icon(
                      _getKategoriIcon(_secilenKategori),
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  items: _kategoriler.map((kategori) {
                    return DropdownMenuItem(
                      value: kategori,
                      child: Text(kategori),
                    );
                  }).toList(),
                  onChanged: (String? yeniDeger) {
                    setState(() {
                      _secilenKategori = yeniDeger!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _miktarController,
                  decoration: InputDecoration(
                    labelText: 'Miktar (₺)',
                    prefixIcon: const Icon(Icons.currency_lira),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir miktar girin';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Geçerli bir sayı girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Tarih'),
                    subtitle: Text(_tarihFormatla(_secilenTarih)),
                    onTap: () async {
                      final DateTime? secilenTarih = await showDatePicker(
                        context: context,
                        initialDate: _secilenTarih,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                        locale: const Locale('tr', 'TR'),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Colors.blue,
                              ),
                              dialogBackgroundColor: Colors.white,
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (secilenTarih != null) {
                        setState(() {
                          _secilenTarih = secilenTarih;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _harcamaKaydet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'KAYDET',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getKategoriIcon(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'yiyecek':
        return Icons.restaurant;
      case 'ulaşım':
        return Icons.directions_car;
      case 'alışveriş':
        return Icons.shopping_bag;
      case 'faturalar':
        return Icons.receipt;
      case 'eğlence':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }

  Future<void> _harcamaKaydet() async {
    if (_formKey.currentState!.validate()) {
      final harcama = Harcama(
        baslik: _baslikController.text.trim(),
        kategori: _secilenKategori,
        miktar: double.parse(_miktarController.text),
        tarih: _secilenTarih,
      );

      try {
        await _db.harcamaEkle(harcama, widget.kullaniciId);
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Harcama eklenirken bir hata oluştu'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _butceDuzenle() async {
    final controller = TextEditingController(
      text: _butce > 0 ? _butce.toString() : '',
    );
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(_butce > 0 ? 'Bütçe Düzenle' : 'Bütçe Belirle'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Aylık Bütçe',
              prefixIcon: Icon(Icons.currency_lira),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Lütfen bir bütçe girin';
              }
              if (double.tryParse(value) == null) {
                return 'Geçerli bir sayı girin';
              }
              if (double.parse(value) <= 0) {
                return 'Bütçe 0\'dan büyük olmalıdır';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, double.parse(controller.text));
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      await _db.butceGuncelle(widget.kullaniciId, result);
      await _butceVeHarcamalariGetir();
    }
  }

  @override
  void dispose() {
    _baslikController.dispose();
    _miktarController.dispose();
    super.dispose();
  }
}
