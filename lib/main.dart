
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      home: const LoginPage(),
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


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final idController = TextEditingController();
  final passwordController = TextEditingController();
  bool hidePassword = true;

  void login() {
    if (idController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID आणि Password टाका')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.agriculture, size: 80, color: Color(0xFF176B38)),
                const SizedBox(height: 16),
                const Text(
                  'BABA AGRO',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Login to continue'),
                const SizedBox(height: 32),
                TextField(
                  controller: idController,
                  decoration: const InputDecoration(
                    labelText: 'ID Number',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        hidePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => hidePassword = !hidePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: login,
                    child: const Text('LOGIN'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text("Refer"),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Refer option लवकरच सुरू होईल")),
                );
              },
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
  final password = TextEditingController();
  bool saving = false;

  String makeId() =>
      'BA${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

  Future<void> save() async {
    final n = name.text.trim();
    final m = mobile.text.trim();
    final c = city.text.trim();
    final p = password.text.trim();

    if (n.isEmpty || !RegExp(r'^[0-9]{10}$').hasMatch(m) || p.length < 6) {
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
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: '$m@babaagro.app', password: p);
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
            TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password (किमान 6 अक्षरे)')),
            const SizedBox(height: 20),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baba Agro Products'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data?.docs ?? [];

          if (products.isEmpty) {
            return const Center(
              child: Text('अजून Products उपलब्ध नाहीत.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final doc = products[index];
              final data = doc.data();
              final name = data['name'] ?? 'Product';
              final price = (data['price'] ?? 0) as num;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.agriculture),
                  title: Text(
                    name.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Price: ₹${price.toStringAsFixed(0)}',
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderPage(
                            productId: doc.id,
                            productName: name.toString(),
                            price: price.toDouble(),
                          ),
                        ),
                      );
                    },
                    child: const Text('Order'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
class OrderPage extends StatefulWidget {
  final String productId;
  final String productName;
  final double price;

  const OrderPage({
    super.key,
    required this.productId,
    required this.productName,
    required this.price,
  });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final baIdController = TextEditingController();
  int quantity = 1;
  bool saving = false;

  double get total => widget.price * quantity;

  Future<void> placeOrder() async {
    final baId = baIdController.text.trim();

    if (baId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('तुमचा BA ID टाका')),
      );
      return;
    }

    setState(() => saving = true);

    try {
      await FirebaseFirestore.instance.collection('orders').add({
        'baId': baId,
        'productId': widget.productId,
        'productName': widget.productName,
        'price': widget.price,
        'quantity': quantity,
        'total': total,
        'status': 'New',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order यशस्वी झाला')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order झाला नाही: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Place Order')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.productName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Price: ₹${widget.price.toStringAsFixed(0)}'),
            const SizedBox(height: 20),
            TextField(
              controller: baIdController,
              decoration: const InputDecoration(
                labelText: 'तुमचा BA ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Quantity: '),
                IconButton(
                  onPressed: quantity > 1
                      ? () => setState(() => quantity--)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  '$quantity',
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  onPressed: () => setState(() => quantity++),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Total: ₹${total.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: saving ? null : placeOrder,
              child: Text(saving ? 'Please wait...' : 'Order करा'),
            ),
          ],
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


  Future<void> addProduct() async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    final save = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('नवीन Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Product नाव',
              ),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price',
                prefixText: '₹ ',
              ),
            ),
              ],
            ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (save == true &&
        nameController.text.trim().isNotEmpty &&
        priceController.text.trim().isNotEmpty) {
      await FirebaseFirestore.instance.collection('products').add({
        'name': nameController.text.trim(),
        'price': double.tryParse(priceController.text.trim()) ?? 0,
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

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
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: addProduct, icon: const Icon(Icons.add_shopping_cart), label: const Text("Add Product")))),
        const SizedBox(height: 10),
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
