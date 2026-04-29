import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZikirMatikApp());
}

class ZikirMatikApp extends StatelessWidget {
  const ZikirMatikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZikirMatik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        colorScheme: const ColorScheme.dark(primary: Color(0xFF4FC3F7)),
      ),
      home: const ZikirListePage(),
    );
  }
}

// ─── Veri Modeli ───────────────────────────────────────────────────────────────

class Zikir {
  String id;
  String isim;
  String arapca;
  String okunusu;
  String anlami;
  int hedef;
  bool ozel;

  Zikir({
    required this.id,
    required this.isim,
    required this.arapca,
    required this.okunusu,
    required this.anlami,
    required this.hedef,
    this.ozel = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'isim': isim,
        'arapca': arapca,
        'okunusu': okunusu,
        'anlami': anlami,
        'hedef': hedef,
        'ozel': ozel,
      };

  factory Zikir.fromJson(Map<String, dynamic> json) => Zikir(
        id: json['id'] ?? UniqueKey().toString(),
        isim: json['isim'] ?? '',
        arapca: json['arapca'] ?? '',
        okunusu: json['okunusu'] ?? '',
        anlami: json['anlami'] ?? '',
        hedef: json['hedef'] ?? 33,
        ozel: json['ozel'] ?? false,
      );

  Zikir copyWith({
    String? isim,
    String? arapca,
    String? okunusu,
    String? anlami,
    int? hedef,
    bool? ozel,
  }) =>
      Zikir(
        id: id,
        isim: isim ?? this.isim,
        arapca: arapca ?? this.arapca,
        okunusu: okunusu ?? this.okunusu,
        anlami: anlami ?? this.anlami,
        hedef: hedef ?? this.hedef,
        ozel: ozel ?? this.ozel,
      );
}

// ─── Uygulama Ayarları ─────────────────────────────────────────────────────────

class AppSettings {
  static bool titresimAcik = true;
  static double yaziBoyutu = 15.0;
}

// ─── Varsayılan Hazır Zikirler ─────────────────────────────────────────────────

List<Zikir> _varsayilanZikirler() => [
      Zikir(id: 'h1', isim: 'Sübhanallah', arapca: 'سُبْحَانَ اللّٰهِ', okunusu: 'Sübhanallah', anlami: "Allah'ı tüm eksikliklerden tenzih ederim.", hedef: 33),
      Zikir(id: 'h2', isim: 'Elhamdülillah', arapca: 'اَلْحَمْدُ لِلّٰهِ', okunusu: 'Elhamdülillah', anlami: "Hamd yalnızca Allah'a aittir.", hedef: 33),
      Zikir(id: 'h3', isim: 'Allahu Ekber', arapca: 'اَللّٰهُ أَكْبَرُ', okunusu: 'Allahu Ekber', anlami: "Allah en büyüktür.", hedef: 33),
      Zikir(id: 'h4', isim: 'La ilahe illallah', arapca: 'لَا إِلٰهَ إِلَّا اللّٰهُ', okunusu: 'La ilahe illallah', anlami: "Allah'tan başka ilah yoktur.", hedef: 100),
      Zikir(id: 'h5', isim: 'Estağfirullah', arapca: 'أَسْتَغْفِرُ اللّٰهَ', okunusu: 'Estağfirullah', anlami: "Allah'tan bağışlanma dilerim.", hedef: 100),
      Zikir(id: 'h6', isim: 'Salavat', arapca: 'اَللّٰهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ', okunusu: 'Allahümme salli ala seyyidina Muhammed', anlami: "Allah'ım! Efendimiz Muhammed'e salat eyle.", hedef: 100),
      Zikir(id: 'h7', isim: 'Hasbünallah', arapca: 'حَسْبُنَا اللّٰهُ وَنِعْمَ الْوَكِيلُ', okunusu: "Hasbünallahü ve ni'mel vekil", anlami: "Allah bize yeter, O ne güzel vekildir.", hedef: 450),
      Zikir(id: 'h8', isim: 'İhlas Suresi', arapca: 'قُلْ هُوَ اللّٰهُ أَحَدٌ', okunusu: 'İhlas Suresi\nBismillahirrahmânirrahîm\nKul huvallâhu ehad\nAllahüssamed\nLem yelid ve lem yûled\nVe lem yekun lehu kufuven ehad', anlami: "De ki: O Allah birdir.\nAllah Samed'dir.\nO doğurmamış ve doğurulmamıştır.\nHiçbir şey O'na denk değildir.", hedef: 40000),
      Zikir(id: 'h9', isim: 'La havle', arapca: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللّٰهِ', okunusu: 'La havle ve la kuvvete illa billah', anlami: "Güç ve kuvvet yalnızca Allah'a aittir.", hedef: 33),
      Zikir(id: 'h10', isim: 'Bismillah', arapca: 'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيمِ', okunusu: 'Bismillahirrahmânirrahîm', anlami: "Rahman ve Rahim olan Allah'ın adıyla.", hedef: 786),
    ];

// ─── SharedPreferences Yardımcısı ─────────────────────────────────────────────

class ZikirStorage {
  static const _key = 'zikirler_v1';
  static const _sayacPrefix = 'sayac_';

  static Future<List<Zikir>> yukle() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) {
      final varsayilan = _varsayilanZikirler();
      await kaydet(varsayilan);
      return varsayilan;
    }
    final List<dynamic> liste = jsonDecode(jsonStr);
    return liste.map((e) => Zikir.fromJson(e)).toList();
  }

  static Future<void> kaydet(List<Zikir> zikirler) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(zikirler.map((z) => z.toJson()).toList()));
  }

  static Future<void> sayacKaydet(String zikirId, int deger) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_sayacPrefix$zikirId', deger);
  }

  static Future<int> sayacYukle(String zikirId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_sayacPrefix$zikirId') ?? 0;
  }

  static Future<void> sayacSifirla(String zikirId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_sayacPrefix$zikirId');
  }
}

// ─── Zikir Liste Sayfası ───────────────────────────────────────────────────────

class ZikirListePage extends StatefulWidget {
  const ZikirListePage({super.key});

  @override
  State<ZikirListePage> createState() => _ZikirListePageState();
}

class _ZikirListePageState extends State<ZikirListePage> {
  List<Zikir> _zikirler = [];
  bool _yukleniyor = true;
  bool _titresim = true;

  @override
  void initState() {
    super.initState();
    _zikirYukle();
  }

  Future<void> _zikirYukle() async {
    final liste = await ZikirStorage.yukle();
    setState(() {
      _zikirler = liste;
      _yukleniyor = false;
    });
  }

  Future<void> _kaydet() async => ZikirStorage.kaydet(_zikirler);

  void _ekle(Zikir z) {
    setState(() => _zikirler.add(z));
    _kaydet();
  }

  void _sil(Zikir z) {
    setState(() => _zikirler.removeWhere((e) => e.id == z.id));
    ZikirStorage.sayacSifirla(z.id); // sayacı da temizle
    _kaydet();
  }

  void _duzenle(Zikir eskiZ, Zikir yeniZ) {
    setState(() {
      final idx = _zikirler.indexWhere((e) => e.id == eskiZ.id);
      if (idx != -1) _zikirler[idx] = yeniZ;
    });
    _kaydet();
  }

  void _titresimToggle(bool val) {
    setState(() {
      _titresim = val;
      AppSettings.titresimAcik = val;
    });
  }

  void _zikirFormDialog({
    required String baslik,
    Zikir? mevcutZikir,
    required void Function(Zikir) onKaydet,
  }) {
    final isimCtrl = TextEditingController(text: mevcutZikir?.isim ?? '');
    final arapcaCtrl = TextEditingController(text: mevcutZikir?.arapca ?? '');
    final okunusCtrl = TextEditingController(text: mevcutZikir?.okunusu ?? '');
    final anlamCtrl = TextEditingController(text: mevcutZikir?.anlami ?? '');
    final hedefCtrl = TextEditingController(
        text: mevcutZikir != null ? '${mevcutZikir.hedef}' : '33');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF2A2A2A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(baslik,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(color: Color(0xFF3A3A3A)),
                const SizedBox(height: 12),
                _buildField('Zikir Adı *', isimCtrl),
                const SizedBox(height: 12),
                _buildField('Arapça (opsiyonel)', arapcaCtrl,
                    textDir: TextDirection.rtl),
                const SizedBox(height: 12),
                _buildField('Okunuşu *', okunusCtrl, maxLines: 4),
                const SizedBox(height: 12),
                _buildField('Anlamı (opsiyonel)', anlamCtrl, maxLines: 3),
                const SizedBox(height: 12),
                _buildField('Hedef Sayı *', hedefCtrl,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF3A3A3A)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('İptal',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4FC3F7),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          if (isimCtrl.text.trim().isEmpty ||
                              okunusCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Zikir adı ve okunuşu zorunludur!'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }
                          final hedef = int.tryParse(hedefCtrl.text) ?? 33;
                          final yeni = mevcutZikir != null
                              ? mevcutZikir.copyWith(
                                  isim: isimCtrl.text.trim(),
                                  arapca: arapcaCtrl.text.trim(),
                                  okunusu: okunusCtrl.text.trim(),
                                  anlami: anlamCtrl.text.trim(),
                                  hedef: hedef,
                                )
                              : Zikir(
                                  id: DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  isim: isimCtrl.text.trim(),
                                  arapca: arapcaCtrl.text.trim(),
                                  okunusu: okunusCtrl.text.trim(),
                                  anlami: anlamCtrl.text.trim(),
                                  hedef: hedef,
                                  ozel: true,
                                );
                          onKaydet(yeni);
                          Navigator.pop(ctx);
                        },
                        child: const Text('Kaydet',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    TextDirection textDir = TextDirection.ltr,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textDirection: textDir,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF4FC3F7)),
        ),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
      ),
    );
  }

  void _silOnay(Zikir zikir) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Zikiri Sil',
            style: TextStyle(color: Colors.white)),
        content: Text('"${zikir.isim}" zikrini silmek istiyor musunuz?',
            style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal')),
          TextButton(
            onPressed: () {
              _sil(zikir);
              Navigator.pop(ctx);
            },
            child: const Text('Sil',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _ayarlarDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.settings, color: Color(0xFF4FC3F7)),
              SizedBox(width: 10),
              Text('Ayarlar', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(color: Color(0xFF3A3A3A)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(children: [
                    Icon(Icons.vibration, color: Colors.white70),
                    SizedBox(width: 10),
                    Text('Titreşim',
                        style:
                            TextStyle(color: Colors.white, fontSize: 16)),
                  ]),
                  Switch(
                    value: _titresim,
                    onChanged: (val) {
                      setDlg(() {});
                      _titresimToggle(val);
                    },
                    activeColor: const Color(0xFF4FC3F7),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _titresim ? 'Titreşim açık' : 'Titreşim kapalı',
                  style: TextStyle(
                      color: _titresim
                          ? const Color(0xFF4FC3F7)
                          : Colors.grey[600],
                      fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFF3A3A3A)),
              Row(
                children: [
                  const Icon(Icons.text_fields, color: Colors.white70),
                  const SizedBox(width: 10),
                  const Text('Yazı Boyutu',
                      style:
                          TextStyle(color: Colors.white, fontSize: 16)),
                  const Spacer(),
                  Text(AppSettings.yaziBoyutu.toStringAsFixed(0),
                      style: const TextStyle(
                          color: Color(0xFF4FC3F7),
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ],
              ),
              Slider(
                value: AppSettings.yaziBoyutu,
                min: 10,
                max: 26,
                divisions: 16,
                activeColor: const Color(0xFF4FC3F7),
                inactiveColor: const Color(0xFF3A3A3A),
                label: AppSettings.yaziBoyutu.toStringAsFixed(0),
                onChanged: (val) {
                  setDlg(() => AppSettings.yaziBoyutu = val);
                  setState(() {});
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Küçük',
                      style:
                          TextStyle(color: Colors.grey, fontSize: 11)),
                  Text('Büyük',
                      style:
                          TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFF3A3A3A)),
              TextButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final onay = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      backgroundColor: const Color(0xFF2A2A2A),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      title: const Text('Sıfırla',
                          style: TextStyle(color: Colors.white)),
                      content: const Text(
                          'Tüm değişiklikler silinecek ve varsayılan zikirler yüklenecek. Emin misiniz?',
                          style: TextStyle(color: Colors.grey)),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(c, false),
                            child: const Text('İptal')),
                        TextButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: const Text('Sıfırla',
                              style:
                                  TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  );
                  if (onay == true) {
                    final varsayilan = _varsayilanZikirler();
                    await ZikirStorage.kaydet(varsayilan);
                    setState(() => _zikirler = varsayilan);
                  }
                },
                icon:
                    const Icon(Icons.restore, color: Colors.orangeAccent),
                label: const Text('Varsayılanlara Sıfırla',
                    style: TextStyle(color: Colors.orangeAccent)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Kapat',
                  style: TextStyle(color: Color(0xFF4FC3F7))),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text('ZikirMatik',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Titreşim',
            icon: Icon(
              _titresim ? Icons.vibration : Icons.phonelink_erase,
              color: _titresim ? const Color(0xFF4FC3F7) : Colors.grey,
            ),
            onPressed: () => _titresimToggle(!_titresim),
          ),
          IconButton(
            tooltip: 'Ayarlar',
            icon: const Icon(Icons.settings, color: Colors.white70),
            onPressed: _ayarlarDialog,
          ),
        ],
      ),
      body: _yukleniyor
          ? const Center(
              child:
                  CircularProgressIndicator(color: Color(0xFF4FC3F7)))
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF1E3A4A), Color(0xFF1A2A3A)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_zikirler.length} Zikir  •  ${_zikirler.where((z) => z.ozel).length} Özel',
                        style: const TextStyle(
                            color: Color(0xFF4FC3F7),
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                      Icon(
                        _titresim
                            ? Icons.vibration
                            : Icons.phonelink_erase,
                        color: _titresim
                            ? const Color(0xFF4FC3F7)
                            : Colors.grey,
                        size: 18,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    itemCount: _zikirler.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final zikir = _zikirler[index];
                      return _ZikirKart(
                        zikir: zikir,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    ZikirSayacPage(zikir: zikir)),
                          );
                          // Geri dönünce listeyi yenile (sayaç göstergesi için)
                          setState(() {});
                        },
                        onDuzenle: () => _zikirFormDialog(
                          baslik: 'Zikiri Düzenle',
                          mevcutZikir: zikir,
                          onKaydet: (z) => _duzenle(zikir, z),
                        ),
                        onSil: () => _silOnay(zikir),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _zikirFormDialog(
          baslik: 'Yeni Zikir Ekle',
          onKaydet: _ekle,
        ),
        backgroundColor: const Color(0xFF4FC3F7),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Özel Zikir',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ─── Zikir Kartı ───────────────────────────────────────────────────────────────

class _ZikirKart extends StatelessWidget {
  final Zikir zikir;
  final VoidCallback onTap;
  final VoidCallback onDuzenle;
  final VoidCallback onSil;

  const _ZikirKart({
    required this.zikir,
    required this.onTap,
    required this.onDuzenle,
    required this.onSil,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: zikir.ozel
              ? const Color(0xFF1E2E1E)
              : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: zikir.ozel
                  ? const Color(0xFF2E5E2E)
                  : const Color(0xFF3A3A3A)),
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: zikir.ozel
                    ? Colors.green.withOpacity(0.15)
                    : const Color(0xFF4FC3F7).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                zikir.ozel
                    ? Icons.edit_note
                    : Icons.brightness_5_rounded,
                color: zikir.ozel
                    ? Colors.greenAccent
                    : const Color(0xFF4FC3F7),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(zikir.isim,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (zikir.ozel) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Özel',
                              style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 10)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text('Hedef: ${zikir.hedef}',
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            if (zikir.arapca.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(zikir.arapca,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                        color: Color(0xFF4FC3F7), fontSize: 16),
                    overflow: TextOverflow.ellipsis),
              ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDuzenle,
              child: const Icon(Icons.edit,
                  color: Colors.white54, size: 20),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSil,
              child: const Icon(Icons.delete,
                  color: Colors.redAccent, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Zikir Sayaç Sayfası ───────────────────────────────────────────────────────

class ZikirSayacPage extends StatefulWidget {
  final Zikir zikir;
  const ZikirSayacPage({super.key, required this.zikir});

  @override
  State<ZikirSayacPage> createState() => _ZikirSayacPageState();
}

class _ZikirSayacPageState extends State<ZikirSayacPage>
    with SingleTickerProviderStateMixin {
  int _sayac = 0;
  bool _yukleniyor = true;
  int _tabIndex = 1;
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut));
    _sayacYukle();
  }

  Future<void> _sayacYukle() async {
    final deger = await ZikirStorage.sayacYukle(widget.zikir.id);
    setState(() {
      _sayac = deger;
      _yukleniyor = false;
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _artir() {
    if (AppSettings.titresimAcik) HapticFeedback.mediumImpact();
    _animCtrl.forward().then((_) => _animCtrl.reverse());
    setState(() => _sayac++);
    ZikirStorage.sayacKaydet(widget.zikir.id, _sayac);
    if (_sayac == widget.zikir.hedef) _hedefDialog();
  }

  void _azalt() {
    if (_sayac > 0) {
      if (AppSettings.titresimAcik) HapticFeedback.selectionClick();
      setState(() => _sayac--);
      ZikirStorage.sayacKaydet(widget.zikir.id, _sayac);
    }
  }

  void _sifirla() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Sıfırla',
            style: TextStyle(color: Colors.white)),
        content: const Text('Sayacı sıfırlamak istiyor musunuz?',
            style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal')),
          TextButton(
            onPressed: () {
              setState(() => _sayac = 0);
              ZikirStorage.sayacSifirla(widget.zikir.id); // kalıcı sıfırla
              Navigator.pop(ctx);
            },
            child: const Text('Sıfırla',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _hedefDialog() {
    if (AppSettings.titresimAcik) HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('🎉 Tebrikler!',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center),
        content: Text(
            '${widget.zikir.isim} zikrini ${widget.zikir.hedef} kez tamamladınız!',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Devam Et',
                  style: TextStyle(color: Color(0xFF4FC3F7))),
            ),
          ),
        ],
      ),
    );
  }

  void _manuelGiris() {
    final ctrl = TextEditingController(text: '$_sayac');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Sayı Gir',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 22),
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4FC3F7))),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4FC3F7))),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal',
                  style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text);
              if (v != null && v >= 0) {
                setState(() => _sayac = v);
                ZikirStorage.sayacKaydet(widget.zikir.id, v); // kaydet
              }
              Navigator.pop(ctx);
            },
            child: const Text('Tamam',
                style: TextStyle(color: Color(0xFF4FC3F7))),
          ),
        ],
      ),
    );
  }

  void _yaziBoyutuDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.text_fields, color: Color(0xFF4FC3F7)),
              SizedBox(width: 10),
              Text('Yazı Boyutu',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF3A3A3A)),
                ),
                child: Text(
                  widget.zikir.okunusu.split('\n').first,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: AppSettings.yaziBoyutu,
                      height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Boyut:',
                      style: TextStyle(color: Colors.white70)),
                  Text(AppSettings.yaziBoyutu.toStringAsFixed(0),
                      style: const TextStyle(
                          color: Color(0xFF4FC3F7),
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ],
              ),
              Slider(
                value: AppSettings.yaziBoyutu,
                min: 10,
                max: 26,
                divisions: 16,
                activeColor: const Color(0xFF4FC3F7),
                inactiveColor: const Color(0xFF3A3A3A),
                label: AppSettings.yaziBoyutu.toStringAsFixed(0),
                onChanged: (val) {
                  setDlg(() => AppSettings.yaziBoyutu = val);
                  setState(() {});
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('10 — Küçük',
                      style:
                          TextStyle(color: Colors.grey, fontSize: 11)),
                  Text('26 — Büyük',
                      style:
                          TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tamam',
                  style: TextStyle(color: Color(0xFF4FC3F7))),
            ),
          ],
        ),
      ),
    );
  }

  String get _icerik {
    switch (_tabIndex) {
      case 0:
        return widget.zikir.arapca.isEmpty
            ? '(Arapça girilmedi)'
            : widget.zikir.arapca;
      case 2:
        return widget.zikir.anlami.isEmpty
            ? '(Anlam girilmedi)'
            : widget.zikir.anlami;
      default:
        return widget.zikir.okunusu;
    }
  }

  double get _ilerleme => widget.zikir.hedef > 0
      ? (_sayac / widget.zikir.hedef).clamp(0.0, 1.0)
      : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextButton(
          onPressed: _azalt,
          child: const Text('-1',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ),
        actions: [
          TextButton(
            onPressed: _sifirla,
            child: const Text('Sıfırla',
                style: TextStyle(color: Colors.white70, fontSize: 15)),
          ),
          IconButton(
            tooltip: 'Yazı Boyutu',
            icon: const Icon(Icons.text_fields, color: Colors.white70),
            onPressed: _yaziBoyutuDialog,
          ),
          IconButton(
            icon: const Icon(Icons.keyboard, color: Colors.white70),
            onPressed: _manuelGiris,
          ),
        ],
      ),
      body: _yukleniyor
          ? const Center(
              child:
                  CircularProgressIndicator(color: Color(0xFF4FC3F7)))
          : Column(
              children: [
                // ── Sekme ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: const Color(0xFF3A3A3A)),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: ['Arapça', 'Okunuşu', 'Anlamı']
                          .asMap()
                          .entries
                          .map((e) => Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(
                                      () => _tabIndex = e.key),
                                  child: AnimatedContainer(
                                    duration: const Duration(
                                        milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 9),
                                    decoration: BoxDecoration(
                                      color: _tabIndex == e.key
                                          ? const Color(0xFF4FC3F7)
                                              .withOpacity(0.2)
                                          : Colors.transparent,
                                      borderRadius:
                                          BorderRadius.circular(30),
                                      border: _tabIndex == e.key
                                          ? Border.all(
                                              color: const Color(
                                                  0xFF4FC3F7))
                                          : null,
                                    ),
                                    child: Text(
                                      e.value,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _tabIndex == e.key
                                            ? const Color(0xFF4FC3F7)
                                            : Colors.grey,
                                        fontWeight: _tabIndex == e.key
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),

                // ── İçerik kutusu ──────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(
                        minHeight: 70, maxHeight: 360),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF252525),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: const Color(0xFF3A3A3A)),
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        child: Text(
                          _icerik,
                          textAlign: TextAlign.center,
                          textDirection: _tabIndex == 0
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _tabIndex == 0
                                ? AppSettings.yaziBoyutu + 4
                                : AppSettings.yaziBoyutu,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // ── Yazı boyutu kısayolu ───────────────────────────────
                GestureDetector(
                  onTap: _yaziBoyutuDialog,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.text_fields,
                          color: Color(0xFF4FC3F7), size: 13),
                      const SizedBox(width: 4),
                      Text(
                        'Yazı: ${AppSettings.yaziBoyutu.toStringAsFixed(0)}px  (değiştir)',
                        style: const TextStyle(
                            color: Color(0xFF4FC3F7), fontSize: 11),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // ── Titreşim göstergesi ────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      AppSettings.titresimAcik
                          ? Icons.vibration
                          : Icons.phonelink_erase,
                      color: AppSettings.titresimAcik
                          ? const Color(0xFF4FC3F7)
                          : Colors.grey[700],
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      AppSettings.titresimAcik
                          ? 'Titreşim Açık'
                          : 'Titreşim Kapalı',
                      style: TextStyle(
                        color: AppSettings.titresimAcik
                            ? const Color(0xFF4FC3F7)
                            : Colors.grey[700],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // ── Hedef & progress ──────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Text(
                        'Hedef Sayı: ${widget.zikir.hedef}',
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _ilerleme,
                          backgroundColor: const Color(0xFF3A3A3A),
                          color: _ilerleme >= 1.0
                              ? Colors.greenAccent
                              : const Color(0xFF4FC3F7),
                          minHeight: 7,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                          '%${(_ilerleme * 100).toStringAsFixed(1)}',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 11)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Artır butonu — sayaç içinde ───────────────────────
                GestureDetector(
                  onTap: _artir,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF4FC3F7),
                            Color(0xFF0288D1)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4FC3F7)
                                .withOpacity(0.4),
                            blurRadius: 28,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add,
                              color: Colors.white, size: 30),
                          const SizedBox(height: 2),
                          Text(
                            '$_sayac',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1,
                            ),
                          ),
                          Text(
                            '/ ${widget.zikir.hedef}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
    );
  }
}