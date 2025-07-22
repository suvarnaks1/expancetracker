import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expance_tracker_app/resources/colors.dart';

class UpdatedPage extends StatefulWidget {
  const UpdatedPage({super.key});
  @override
  _UpdatedPageState createState() => _UpdatedPageState();
}

class _UpdatedPageState extends State<UpdatedPage> {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Center(child: Text('Not logged in'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Transactions'),
        backgroundColor: AppColors.deepPink,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('expenses')
            .snapshots(),
        builder: (c, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(color: AppColors.lightPink2),
            itemBuilder: (_, i) {
              final d = docs[i];
              final data = d.data() as Map<String, dynamic>;
              return ListTile(
                tileColor: AppColors.lightPink1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                title: Text(data['description'] ?? '—'),
                subtitle: Text(data['category'] ?? '—'),
                trailing: IconButton(
                  icon: Icon(Icons.edit, color: AppColors.mediumPink),
                  onPressed: () => _showBeautifulDialog(uid, d.id, data),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showBeautifulDialog(String uid, String docId, Map<String, dynamic> docData) {
    final _descCtrl = TextEditingController(text: docData['description']);
    final _amtCtrl = TextEditingController(text: (docData['amount'] as num).toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.lightPink1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amtCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.mediumPink),
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepPink,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final amt = double.tryParse(_amtCtrl.text) ?? 0;
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('expenses')
                  .doc(docId)
                  .update({
                'description': _descCtrl.text.trim(),
                'amount': amt,
                'updatedAt': FieldValue.serverTimestamp(),
              });
              Navigator.pop(context);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}
