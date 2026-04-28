import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
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
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4FC3F7),
        ),
      ),
      home: const ZikirListePage(),
    );
  }
}

// ─── Veri Modeli ───────────────────────────────────────────────────────────────

class Zikir {
  final String isim;
  final String arapca;
  final String okunusu;
  final String anlami;
  final int hedef;

  const Zikir({
    required this.isim,
    required this.arapca,
    required this.okunusu,
    required this.anlami,
    required this.hedef,
  });
}

// ─── Hazır Zikirler ────────────────────────────────────────────────────────────

const List<Zikir> hazirZikirler = [
  Zikir(
    isim: 'Sübhanallah',
    arapca: 'سُبْحَانَ اللّٰهِ',
    okunusu: 'Sübhanallah',
    anlami: 'Allah\'ı tüm eksikliklerden tenzih ederim.',
    hedef: 33,
  ),
  Zikir(
    isim: 'Elhamdülillah',
    arapca: 'اَلْحَمْدُ لِلّٰهِ',
    okunusu: 'Elhamdülillah',
    anlami: 'Hamd yalnızca Allah\'a aittir.',
    hedef: 33,
  ),
  Zikir(
    isim: 'Allahu Ekber',
    arapca: 'اَللّٰهُ أَكْبَرُ',
    okunusu: 'Allahu Ekber',
    anlami: 'Allah en büyüktür.',
    hedef: 33,
  ),
  Zikir(
    isim: 'La ilahe illallah',
    arapca: 'لَا إِلٰهَ إِلَّا اللّٰهُ',
    okunusu: 'La ilahe illallah',
    anlami: 'Allah\'tan başka ilah yoktur.',
    hedef: 100,
  ),
  Zikir(
    isim: 'Estağfirullah',
    arapca: 'أَسْتَغْفِرُ اللّٰهَ',
    okunusu: 'Estağfirullah',
    anlami: 'Allah\'tan bağışlanma dilerim.',
    hedef: 100,
  ),
  Zikir(
    isim: 'Salavat',
    arapca: 'اَللّٰهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ',
    okunusu: 'Allahümme salli ala seyyidina Muhammed',
    anlami: 'Allah\'ım! Efendimiz Muhammed\'e salat eyle.',
    hedef: 100,
  ),
  Zikir(
    isim: 'Hasbünallah',
    arapca: 'حَسْبُنَا اللّٰهُ وَنِعْمَ الْوَكِيلُ',
    okunusu: 'Hasbünallahü ve ni\'mel vekil',
    anlami: 'Allah bize yeter, O ne güzel vekildir.',
    hedef: 450,
  ),
  Zikir(
    isim: 'İhlas Suresi',
    arapca: 'قُلْ هُوَ اللّٰهُ أَحَدٌ',
    okunusu:
        'İhlas Suresi\nBismillahirrahmânirrahîm\nKul huvallâhu ehad\nAllahüssamed\nLem yelid ve lem yûled\nVe lem yekun lehu kufuven ehad',
    anlami:
        'De ki: O Allah birdir.\nAllah Samed\'dir (her şey O\'na muhtaçtır).\nO doğurmamış ve doğurulmamıştır.\nHiçbir şey O\'na denk değildir.',
    hedef: 40000,
  ),
  Zikir(
    isim: 'La havle',
    arapca: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللّٰهِ',
    okunusu: 'La havle ve la kuvvete illa billah',
    anlami: 'Güç ve kuvvet yalnızca Allah\'a aittir.',
    hedef: 33,
  ),
  Zikir(
    isim: 'Bismillah',
    arapca: 'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيمِ',
    okunusu: 'Bismillahirrahmânirrahîm',
    anlami: 'Rahman ve Rahim olan Allah\'ın adıyla.',
    hedef: 786,
  ),
];

// ─── Zikir Liste Sayfası ───────────────────────────────────────────────────────

class ZikirListePage extends StatelessWidget {
  const ZikirListePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'ZikirMatik',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border, color: Colors.amber),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              '${hazirZikirler.length}+ Hazır Zikir',
              style: const TextStyle(
                color: Color(0xFF4FC3F7),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: hazirZikirler.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final zikir = hazirZikirler[index];
                return _ZikirKart(zikir: zikir);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ZikirKart extends StatelessWidget {
  final Zikir zikir;
  const _ZikirKart({required this.zikir});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ZikirSayacPage(zikir: zikir),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF3A3A3A)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF4FC3F7).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.brightness_5_rounded,
                color: Color(0xFF4FC3F7),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zikir.isim,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hedef: ${zikir.hedef}',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              zikir.arapca,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: Color(0xFF4FC3F7),
                fontSize: 18,
              ),
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
  int _tabIndex = 1; // 0: Arapça, 1: Okunuş, 2: Anlamı
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _artir() {
    HapticFeedback.mediumImpact();
    _animController.forward().then((_) => _animController.reverse());
    setState(() => _sayac++);

    if (_sayac == widget.zikir.hedef) {
      _hedefUlastiDialog();
    }
  }

  void _azalt() {
    if (_sayac > 0) {
      HapticFeedback.selectionClick();
      setState(() => _sayac--);
    }
  }

  void _sifirla() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('Sıfırla', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Sayacı sıfırlamak istediğinize emin misiniz?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _sayac = 0);
              Navigator.pop(ctx);
            },
            child:
                const Text('Sıfırla', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _hedefUlastiDialog() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          '🎉 Tebrikler!',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        content: Text(
          '${widget.zikir.isim} zikrini ${widget.zikir.hedef} kez tamamladınız!',
          style: const TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Devam Et',
                style: TextStyle(color: Color(0xFF4FC3F7)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _aktifIcerik {
    switch (_tabIndex) {
      case 0:
        return widget.zikir.arapca;
      case 2:
        return widget.zikir.anlami;
      default:
        return widget.zikir.okunusu;
    }
  }

  double get _ilerleme =>
      widget.zikir.hedef > 0 ? (_sayac / widget.zikir.hedef).clamp(0.0, 1.0) : 0;

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
          child: const Text(
            '-1',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _sifirla,
            child: const Text(
              'Sıfırla',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard, color: Colors.white70),
            onPressed: _manuelGirisDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Tab Bar ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF3A3A3A)),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: ['Arapça', 'Okunuşu', 'Anlamı']
                    .asMap()
                    .entries
                    .map((e) => Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _tabIndex = e.key),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _tabIndex == e.key
                                    ? const Color(0xFF4FC3F7).withOpacity(0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                                border: _tabIndex == e.key
                                    ? Border.all(color: const Color(0xFF4FC3F7))
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
                                ),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── İçerik Kutusu ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF252525),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3A3A3A)),
              ),
              child: Text(
                _aktifIcerik,
                textAlign: TextAlign.center,
                textDirection: _tabIndex == 0
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _tabIndex == 0 ? 22 : 16,
                  height: 1.8,
                ),
              ),
            ),
          ),

          const Spacer(),

          // ── Hedef & İlerleme ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Text(
                  'Hedef Sayı: ${widget.zikir.hedef}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _ilerleme,
                    backgroundColor: const Color(0xFF3A3A3A),
                    color: const Color(0xFF4FC3F7),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Sayaç ────────────────────────────────────────────────
          ScaleTransition(
            scale: _scaleAnim,
            child: Text(
              '$_sayac',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 80,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // ── Artır Butonu ─────────────────────────────────────────
          GestureDetector(
            onTap: _artir,
            child: Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xFF4FC3F7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x554FC3F7),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),

          const SizedBox(height: 50),
        ],
      ),
    );
  }

  void _manuelGirisDialog() {
    final controller = TextEditingController(text: '$_sayac');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Sayı Gir',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4FC3F7)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4FC3F7)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val >= 0) {
                setState(() => _sayac = val);
              }
              Navigator.pop(ctx);
            },
            child: const Text(
              'Tamam',
              style: TextStyle(color: Color(0xFF4FC3F7)),
            ),
          ),
        ],
      ),
    );
  }
}