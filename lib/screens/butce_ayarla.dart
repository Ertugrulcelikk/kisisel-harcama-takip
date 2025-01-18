import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/veritabani_yardimcisi.dart';
import 'harcama_listesi.dart';

class ButceAyarla extends StatefulWidget {
  final int kullaniciId;

  const ButceAyarla({
    super.key,
    required this.kullaniciId,
  });

  @override
  State<ButceAyarla> createState() => _ButceAyarlaState();
}

class _ButceAyarlaState extends State<ButceAyarla> {
  final _formKey = GlobalKey<FormState>();
  final _butceController = TextEditingController();
  final _db = VeritabaniYardimcisi();
  final _numberFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

  @override
  void initState() {
    super.initState();
    _mevcutButceyiGetir();
  }

  Future<void> _mevcutButceyiGetir() async {
    final butce = await _db.kullaniciButce(widget.kullaniciId);
    if (butce > 0) {
      _butceController.text = butce.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Aylık Bütçenizi Belirleyin',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Harcamalarınızı daha iyi takip etmek için aylık bütçe hedefi belirleyin',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _butceController,
                    decoration: InputDecoration(
                      labelText: 'Aylık Bütçe',
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
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
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
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _butceyiKaydet,
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
                    'DEVAM ET',
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

  Future<void> _butceyiKaydet() async {
    if (_formKey.currentState!.validate()) {
      try {
        final yeniButce = double.parse(_butceController.text);
        debugPrint('Bütçe kaydetme başladı');
        debugPrint('Kullanıcı ID: ${widget.kullaniciId}');
        debugPrint('Yeni bütçe: $yeniButce');

        // Yükleniyor göstergesi
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bütçe kaydediliyor...'),
              duration: Duration(seconds: 1),
            ),
          );
        }

        // Önce kullanıcının bütçesini kontrol et
        final mevcutButce = await _db.kullaniciButce(widget.kullaniciId);
        debugPrint('Mevcut bütçe: $mevcutButce');

        final basarili = await _db.butceGuncelle(widget.kullaniciId, yeniButce);
        debugPrint('Bütçe güncelleme sonucu: $basarili');

        if (!mounted) return;

        if (basarili) {
          debugPrint('Bütçe başarıyla güncellendi');
          // Başarılı mesajı
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bütçe başarıyla kaydedildi'),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.green,
            ),
          );

          // Kısa bir gecikme sonrası diğer sayfaya geç
          await Future.delayed(const Duration(milliseconds: 500));

          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  HarcamaListesi(kullaniciId: widget.kullaniciId),
            ),
          );
        } else {
          debugPrint('Bütçe güncellenemedi');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  const Text('Bütçe kaydedilemedi. Lütfen tekrar deneyin.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e, stackTrace) {
        debugPrint('Bütçe kaydetme hatası: $e');
        debugPrint('Hata detayı: $stackTrace');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Bütçe kaydedilirken bir hata oluştu'),
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

  @override
  void dispose() {
    _butceController.dispose();
    super.dispose();
  }
}
