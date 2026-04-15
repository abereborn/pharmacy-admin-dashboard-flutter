import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ObatByKategoriPage.dart';

class KategoriPage extends StatefulWidget {
  @override
  _KategoriPageState createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  List kategoriList = [];

  final String baseUrl = "http://localhost:8080/api/kategori";

  @override
  void initState() {
    super.initState();
    fetchKategori();
  }

  Future<void> hapusKategori(int id) async {
    await http.delete(Uri.parse("$baseUrl/$id"));
    fetchKategori();
  }

  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text("Konfirmasi"),
          ],
        ),
        content: Text("Yakin mau hapus kategori ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              hapusKategori(id);
              Navigator.pop(context);
            },
            child: Text("Hapus"),
          ),
        ],
      ),
    );
  }

  Future<void> tambahKategori(String nama) async {
    await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"namaKategori": nama}),
    );

    fetchKategori(); // refresh list
  }

  Future<void> fetchKategori() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      setState(() {
        kategoriList = json.decode(res.body);
      });
    }
  }

  void showForm() {
    final namaController = TextEditingController();

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
                "Tambah Kategori",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              TextField(
                controller: namaController,
                decoration: InputDecoration(labelText: "Nama Kategori"),
              ),

              SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  if (namaController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Nama kategori wajib diisi")),
                    );
                    return;
                  }

                  tambahKategori(namaController.text);
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () => showForm(),
        child: Icon(Icons.add),
      ),

      appBar: AppBar(
        title: Text("Kategori"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
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
          itemCount: kategoriList.length,
          itemBuilder: (context, index) {
            final kategori = kategoriList[index];

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
                  child: Icon(Icons.category, color: Colors.teal),
                ),

                title: Text(
                  kategori['namaKategori'] ?? "-",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_forward_ios, size: 16),

                    SizedBox(width: 8),

                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        confirmDelete(kategori['id']);
                      },
                    ),
                  ],
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ObatByKategoriPage(
                        kategoriId: kategori['id'],
                        namaKategori: kategori['namaKategori'],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
