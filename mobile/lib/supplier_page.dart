import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SupplierPage extends StatefulWidget {
  @override
  _SupplierPageState createState() => _SupplierPageState();
}

void confirmDelete({
  required BuildContext context,
  required int id,
  required Function(int) onDelete,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning, color: Colors.red),
          SizedBox(width: 8),
          Text("Konfirmasi"),
        ],
      ),
      content: Text("Yakin mau hapus data ini?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Batal"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            onDelete(id);
            Navigator.pop(context);
          },
          child: Text("Hapus"),
        ),
      ],
    ),
  );
}

class _SupplierPageState extends State<SupplierPage> {
  List supplierList = [];

  final String baseUrl = "http://localhost:8080/api/supplier";

  @override
  void initState() {
    super.initState();
    fetchSupplier();
  }

  Future<void> fetchSupplier() async {
    final res = await http.get(Uri.parse(baseUrl));

    if (res.statusCode == 200) {
      setState(() {
        supplierList = json.decode(res.body);
      });
    }
  }

  Future<void> tambahSupplier(String nama, String alamat, String noHp) async {
    await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"nama": nama, "alamat": alamat, "noHp": noHp}),
    );
    fetchSupplier();
  }

  Future<void> updateSupplier(
    int id,
    String nama,
    String alamat,
    String noHp,
  ) async {
    await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"nama": nama, "alamat": alamat, "noHp": noHp}),
    );
    fetchSupplier();
  }

  Future<void> hapusSupplier(int id) async {
    await http.delete(Uri.parse("$baseUrl/$id"));
    fetchSupplier();
  }

  void showForm({Map? supplier}) {
    final namaController = TextEditingController(text: supplier?['nama'] ?? "");
    final alamatController = TextEditingController(
      text: supplier?['alamat'] ?? "",
    );
    final hpController = TextEditingController(text: supplier?['noHp'] ?? "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                supplier == null ? "Tambah Supplier" : "Edit Supplier",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: namaController,
                decoration: InputDecoration(labelText: "Nama Supplier"),
              ),
              TextField(
                controller: alamatController,
                decoration: InputDecoration(labelText: "Alamat"),
              ),
              TextField(
                controller: hpController,
                decoration: InputDecoration(labelText: "No HP"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (namaController.text.isEmpty ||
                      alamatController.text.isEmpty ||
                      hpController.text.isEmpty) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Semua field wajib diisi")),
                    );
                    return;
                  }

                  if (supplier == null) {
                    tambahSupplier(
                      namaController.text,
                      alamatController.text,
                      hpController.text,
                    );
                  } else {
                    updateSupplier(
                      supplier['id'],
                      namaController.text,
                      alamatController.text,
                      hpController.text,
                    );
                  }

                  Navigator.pop(context);
                },
                child: Text("Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Data Supplier"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () => showForm(),
        child: Icon(Icons.add),
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade400, Colors.green.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: supplierList.length,
          itemBuilder: (context, index) {
            final s = supplierList[index];

            return Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 6,
                    color: Colors.black12,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),

                leading: CircleAvatar(
                  backgroundColor: Colors.teal.shade100,
                  child: Icon(Icons.local_shipping, color: Colors.teal),
                ),

                title: Text(
                  s['nama'] ?? "-",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text(s['alamat'] ?? "-"),
                    Text(
                      s['noHp'] ?? "-",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),

                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => showForm(supplier: s),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        confirmDelete(
                          context: context,
                          id: s['id'],
                          onDelete: hapusSupplier,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
