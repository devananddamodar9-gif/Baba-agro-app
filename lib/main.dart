
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase config:
  // 1) Create a Firebase project.
  // 2) Add Android app package: com.babaagro.app
  // 3) Download google-services.json into android/app/
  // 4) Run: flutterfire configure
  // Then replace this try/catch with:
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    await Firebase.initializeApp();
  } catch (_) {}

  runApp(const BabaAgroApp());
}

class BabaAgroApp extends StatelessWidget {
  const BabaAgroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Baba Agro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B38)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F7F2),
      ),
      home: const HomePage(),
    );
  }
}

class Member {
  final String docId;
  final String memberId;
  final String name;
  final String mobile;
  final String city;
  final num earning;

  const Member({
    required this.docId,
    required this.memberId,
    required this.name,
    required this.mobile,
    required this.city,
    required this.earning,
  });

  factory Member.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Member(
      docId: doc.id,
      memberId: (data['memberId'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      mobile: (data['mobile'] ?? '').toString(),
      city: (data['city'] ?? '').toString(),
      earning: (data['earning'] ?? 0) as num,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF176B38),
        foregroundColor: Colors.white,
        title: const Text('🌱 BABA AGRO'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const _StatCard(
            label: 'Total IDs',
            value: '0',
          ),
          const SizedBox(height: 12),
          const _StatCard(
            label: 'Approved Earnings',
            value: '₹0',
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('नवीन ID नोंदणी'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RegistrationPage(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Products'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProductsPage(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.currency_rupee),
            label: const Text('Earnings'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EarningsPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final name = TextEditingController();
  final mobile = TextEditingController();
  final city = TextEditingController();
  bool saving = false;

  String makeId() =>
      'BA${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

  Future<void> save() async {
    final n = name.text.trim();
    final m = mobile.text.trim();
    final c = city.text.trim();

    if (n.isEmpty || !RegExp(r'^[0-9]{10}$').hasMatch(m)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('नाव आणि योग्य 10 अंकी मोबाइल क्रमांक भरा.')),
      );
      return;
    }

    setState(() => saving = true);
    try {
      final dup = await FirebaseFirestore.instance
          .collection('members')
          .where('mobile', isEqualTo: m)
          .limit(1)
          .get();

      if (dup.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('हा मोबाइल क्रमांक आधीच नोंदलेला आहे.')),
          );
        }
        return;
      }

      final memberId = makeId();
      await FirebaseFirestore.instance.collection('members').add({
        'memberId': memberId,
        'name': n,
        'mobile': m,
        'city': c,
        'earning': 0,
        'status': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('नोंदणी यशस्वी ✅'),
            content: Text('तुमची Baba Agro ID: $memberId'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('ठीक आहे'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('नोंदणी झाली नाही: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('नवीन ID नोंदणी')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'पूर्ण नाव')),
          const SizedBox(height: 12),
          TextField(
            controller: mobile,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            decoration: const InputDecoration(labelText: 'मोबाईल क्रमांक'),
          ),
          const SizedBox(height: 12),
          TextField(controller: city, decoration: const InputDecoration(labelText: 'गाव / शहर')),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: saving ? null : save,
            child: Text(saving ? 'जतन होत आहे...' : 'ID तयार करा'),
          )
        ],
      ),
    );
  }
}

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const products = ['बियाणे', 'खते', 'कीटकनाशके'];
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => Card(
          child: ListTile(
            leading: const Icon(Icons.agriculture),
            title: Text(products[i]),
            subtitle: const Text('Product details पुढे जोडता येतील.'),
          ),
        ),
      ),
    );
  }
}

class EarningsPage extends StatelessWidget {
  const EarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('members').snapshots(),
        builder: (context, snapshot) {
          final members =
              (snapshot.data?.docs ?? []).map(Member.fromDoc).toList();
          if (members.isEmpty) {
            return const Center(child: Text('अजून नोंदी नाहीत.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: members.length,
            itemBuilder: (_, i) {
              final m = members[i];
              return Card(
                child: ListTile(
                  title: Text(m.name),
                  subtitle: Text(m.memberId),
                  trailing: Text('₹${m.earning}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String queryText = '';

  Future<void> updateEarning(Member m) async {
    final controller = TextEditingController(text: '${m.earning}');
    final value = await showDialog<num>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${m.name} - Earnings'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(prefixText: '₹ '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              num.tryParse(controller.text.trim()) ?? 0,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (value != null) {
      await FirebaseFirestore.instance
          .collection('members')
          .doc(m.docId)
          .update({'earning': value < 0 ? 0 : value});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => queryText = v.toLowerCase()),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'नाव / मोबाइल / ID शोधा',
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('members')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                var members =
                    (snapshot.data?.docs ?? []).map(Member.fromDoc).toList();

                members = members.where((m) {
                  final haystack =
                      '${m.memberId} ${m.name} ${m.mobile} ${m.city}'.toLowerCase();
                  return haystack.contains(queryText);
                }).toList();

                if (members.isEmpty) {
                  return const Center(child: Text('नोंदी नाहीत.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: members.length,
                  itemBuilder: (_, i) {
                    final m = members[i];
                    return Card(
                      child: ListTile(
                        title: Text(m.name),
                        subtitle: Text('${m.memberId}\n${m.mobile} • ${m.city}'),
                        isThreeLine: true,
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('₹${m.earning}',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            TextButton(
                              onPressed: () => updateEarning(m),
                              child: const Text('Update'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF176B38)),
        title: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
