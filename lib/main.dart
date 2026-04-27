import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ZikirmatikApp());
}

// --- VERİ MODELİ ---
class Zikir {
  String baslik;
  String metin;
  int hedef;
  int sayac;

  Zikir({
    required this.baslik,
    required this.metin,
    required this.hedef,
    this.sayac = 0,
  });

  // JSON'dan nesneye dönüştürme (Yükleme için)
  factory Zikir.fromJson(Map<String, dynamic> json) => Zikir(
        baslik: json['baslik'],
        metin: json['metin'],
        hedef: json['hedef'],
        sayac: json['sayac'],
      );

  // Nesneden JSON'a dönüştürme (Kaydetme için)
  Map<String, dynamic> toJson() => {
        'baslik': baslik,
        'metin': metin,
        'hedef': hedef,
        'sayac': sayac,
      };
}

class ZikirmatikApp extends StatelessWidget {
  const ZikirmatikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zikirmatik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFCFE1D2), // Adaçayı yeşili (Liste ekranı için)
        fontFamily: 'Roboto',
      ),
      home: const ZikirListesiEkrani(),
    );
  }
}

// --- 1. EKRAN: ZİKİR LİSTESİ ---
class ZikirListesiEkrani extends StatefulWidget {
  const ZikirListesiEkrani({super.key});

  @override
  State<ZikirListesiEkrani> createState() => _ZikirListesiEkraniState();
}

class _ZikirListesiEkraniState extends State<ZikirListesiEkrani> {
  List<Zikir> zikirler = [];

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  // Hafızadaki zikirleri yükle
  Future<void> _verileriYukle() async {
    final prefs = await SharedPreferences.getInstance();
    final String? zikirlerString = prefs.getString('zikir_listesi');
    
    if (zikirlerString != null) {
      final List<dynamic> jsonList = jsonDecode(zikirlerString);
      setState(() {
        zikirler = jsonList.map((j) => Zikir.fromJson(j)).toList();
      });
    } else {
      // İlk açılışta boşsa varsayılan örnekleri ekle
      setState(() {
        zikirler = [
          Zikir(baslik: "Sübhanallah", metin: "Sübhanallahi ve bihamdihi", hedef: 33),
          Zikir(baslik: "Estağfirullah", metin: "Estağfirullah el azîm ve etûbü ileyh", hedef: 100),
        ];
      });
    }
  }

  // Mevcut listeyi hafızaya kaydet
  Future<void> _verileriKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(zikirler.map((z) => z.toJson()).toList());
    await prefs.setString('zikir_listesi', encodedData);
  }

  // Yeni zikir ekleme diyaloğu
  void _yeniZikirEkle() {
    String baslik = "";
    String metin = "";
    int hedef = 33;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Yeni Zikir Ekle"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(decoration: const InputDecoration(labelText: "Zikir Başlığı"), onChanged: (v) => baslik = v),
              TextField(
                decoration: const InputDecoration(labelText: "Okunuşu/Metni"), 
                onChanged: (v) => metin = v,
                maxLines: 3,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Hedef Sayı"),
                keyboardType: TextInputType.number,
                onChanged: (v) => hedef = int.tryParse(v) ?? 33,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
          ElevatedButton(
            onPressed: () {
              if (baslik.isNotEmpty) {
                setState(() {
                  zikirler.add(Zikir(baslik: baslik, metin: metin, hedef: hedef));
                  _verileriKaydet();
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Ekle"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1E3A2B)),
            onPressed: _verileriYukle,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          const Text(
            "Zikir Takibi",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E3A2B)),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: zikirler.length,
              itemBuilder: (context, index) {
                return _ZikirKarti(
                  zikir: zikirler[index],
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ZikirSayacEkrani(zikir: zikirler[index])),
                    );
                    _verileriKaydet(); // Geri dönüldüğünde son sayıyı kaydet
                    setState(() {});
                  },
                  onDelete: () {
                    setState(() {
                      zikirler.removeAt(index);
                      _verileriKaydet();
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5A8B63),
        onPressed: _yeniZikirEkle,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// --- KART TASARIMI ---
class _ZikirKarti extends StatelessWidget {
  final Zikir zikir;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ZikirKarti({required this.zikir, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7ED),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 45,
          height: 45,
          decoration: const BoxDecoration(color: Color(0xFF9CBCA1), shape: BoxShape.circle),
          child: Center(
            child: Text(
              "${zikir.sayac}", 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
            )
          ),
        ),
        title: Text(zikir.baslik, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Hedef: ${zikir.hedef}"),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

// --- 2. EKRAN: SAYAÇ EKRANI ---
class ZikirSayacEkrani extends StatefulWidget {
  final Zikir zikir;
  const ZikirSayacEkrani({super.key, required this.zikir});

  @override
  State<ZikirSayacEkrani> createState() => _ZikirSayacEkraniState();
}

class _ZikirSayacEkraniState extends State<ZikirSayacEkrani> {
  double _yaziBoyutu = 18.0;
  bool _titresimAcik = true;

  @override
  void initState() {
    super.initState();
    _titresimAyariniYukle();
  }

  Future<void> _titresimAyariniYukle() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _titresimAcik = prefs.getBool('titresim_acik') ?? true;
    });
  }

  Future<void> _titresimAyariniDegistir() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _titresimAcik = !_titresimAcik;
      prefs.setBool('titresim_acik', _titresimAcik);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16181A),
      body: SafeArea(
        child: Column(
          children: [
            // Üst Navigasyon ve Kontroller
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white), 
                    onPressed: () => Navigator.pop(context)
                  ),
                  Flexible(
                    child: Text(
                      widget.zikir.baslik, 
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(_titresimAcik ? Icons.vibration : Icons.mobile_off, 
                        color: _titresimAcik ? Colors.white : Colors.white54),
                        onPressed: _titresimAyariniDegistir,
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white), 
                        onPressed: () => setState(() => widget.zikir.sayac = 0)
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Yazı Boyutu Kontrolü
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.text_decrease, color: Colors.white38, size: 20),
                    onPressed: () => setState(() { if (_yaziBoyutu > 12) _yaziBoyutu -= 2; }),
                  ),
                  IconButton(
                    icon: const Icon(Icons.text_increase, color: Colors.white38, size: 24),
                    onPressed: () => setState(() { if (_yaziBoyutu < 40) _yaziBoyutu += 2; }),
                  ),
                ],
              ),
            ),
            
            // Kaydırılabilir Metin Alanı
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    widget.zikir.metin, 
                    textAlign: TextAlign.center, 
                    style: TextStyle(
                      color: Colors.white70, 
                      fontSize: _yaziBoyutu, 
                      height: 1.6,
                      letterSpacing: 0.5
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Sayaç Görünümü
            Text(
              "${widget.zikir.sayac}", 
              style: const TextStyle(color: Colors.white, fontSize: 100, fontWeight: FontWeight.w200)
            ),
            Text(
              "Hedef: ${widget.zikir.hedef}", 
              style: const TextStyle(color: Colors.white30, fontSize: 16)
            ),
            
            const SizedBox(height: 30),
            
            // Büyük Tıklama Butonu
            GestureDetector(
              onTap: () {
                setState(() => widget.zikir.sayac++);
                if (_titresimAcik) {
                  HapticFeedback.lightImpact(); // iOS için ideal hafif titreşim
                }
              },
              child: Container(
                width: 170,
                height: 170,
                margin: const EdgeInsets.only(bottom: 50),
                decoration: BoxDecoration(
                  color: const Color(0xFF4DA2F9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4DA2F9).withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5
                    )
                  ],
                ),
                child: const Icon(Icons.add, size: 60, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}