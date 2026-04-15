import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'kategori_page.dart'; // ⬅️ IMPORT PAGE BARU
import 'supplier_page.dart';
import 'login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Apotek App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: LoginPage(), // 🔥 ubah menjadi LoginPage
    );
  }
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

class ObatPage extends StatefulWidget {
  @override
  _ObatPageState createState() => _ObatPageState();
}

class _ObatPageState extends State<ObatPage> {
  List obatList = [];
  List filteredList = [];

  List kategoriData = []; // 🔥 dari API
  List supplierData = [];
  int? selectedKategoriId;
  int? selectedSupplierId;

  final String baseUrl = "http://localhost:8080/api/obat";
  final String kategoriUrl = "http://localhost:8080/api/kategori";

  TextEditingController searchController = TextEditingController();

  String selectedKategori = "Semua";
  List<String> kategoriList = ["Semua"];

  @override
  void initState() {
    super.initState();
    fetchObat();
    fetchKategori(); // 🔥 penting
    fetchSupplier();
  }

  Future<void> fetchKategori() async {
    final res = await http.get(Uri.parse(kategoriUrl));
    if (res.statusCode == 200) {
      setState(() {
        kategoriData = json.decode(res.body);
      });
    }
  }

  Future<void> fetchObat() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      Set<String> kategoriSet = {"Semua"};
      for (var item in data) {
        if (item['kategori'] != null) {
          kategoriSet.add(item['kategori']['namaKategori']);
        }
      }

      setState(() {
        obatList = data;
        filteredList = data;
        kategoriList = kategoriSet.toList();
      });
    }
  }

  Future<void> fetchSupplier() async {
    final res = await http.get(Uri.parse("http://localhost:8080/api/supplier"));

    if (res.statusCode == 200) {
      setState(() {
        supplierData = json.decode(res.body);
      });
    }
  }

  void applyFilter() {
    String keyword = searchController.text.toLowerCase();

    final result = obatList.where((obat) {
      final nama = obat['namaObat'].toString().toLowerCase();
      final kategori = (obat['kategori']?['namaKategori'] ?? "").toLowerCase();

      final matchSearch = nama.contains(keyword) || kategori.contains(keyword);

      final matchKategori =
          selectedKategori == "Semua" ||
          kategori == selectedKategori.toLowerCase();

      return matchSearch && matchKategori;
    }).toList();

    setState(() {
      filteredList = result;
    });
  }

  Future<void> tambahObat(String nama, int harga, int stok) async {
    await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "namaObat": nama,
        "harga": harga,
        "stok": stok,
        "kategori": {"id": selectedKategoriId},
        "supplier": {"id": selectedSupplierId}, // 🔥 WAJIB
      }),
    );
    fetchObat();
  }

  Future<void> updateObat(int id, String nama, int harga, int stok) async {
    await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "namaObat": nama,
        "harga": harga,
        "stok": stok,
        "kategori": {"id": selectedKategoriId},
        "supplier": {"id": selectedSupplierId}, // 🔥 WAJIB
      }),
    );
    fetchObat();
  }

  Future<void> hapusObat(int id) async {
    await http.delete(Uri.parse("$baseUrl/$id"));
    fetchObat();
  }

  void showForm({Map? obat}) {
    final namaController = TextEditingController(text: obat?['namaObat'] ?? "");
    final hargaController = TextEditingController(
      text: obat?['harga']?.toString() ?? "",
    );
    final stokController = TextEditingController(
      text: obat?['stok']?.toString() ?? "",
    );

    // 🔥 RESET kalau tambah
    if (obat == null) {
      selectedKategoriId = null;
      selectedSupplierId = null;
    } else {
      selectedKategoriId = obat['kategori']?['id'];
      selectedSupplierId = obat['supplier']?['id'];
    }

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
                obat == null ? "Tambah Obat" : "Edit Obat",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              TextField(
                controller: namaController,
                decoration: InputDecoration(labelText: "Nama"),
              ),

              TextField(
                controller: hargaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Harga"),
              ),

              TextField(
                controller: stokController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Stok"),
              ),

              // ✅ KATEGORI
              DropdownButtonFormField<int>(
                value: selectedKategoriId,
                hint: Text("Pilih Kategori"),
                items: kategoriData.map<DropdownMenuItem<int>>((item) {
                  return DropdownMenuItem(
                    value: item['id'],
                    child: Text(item['namaKategori']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedKategoriId = value;
                  });
                },
              ),

              // ✅ SUPPLIER
              DropdownButtonFormField<int>(
                value: selectedSupplierId,
                hint: Text("Pilih Supplier"),
                items: supplierData.map<DropdownMenuItem<int>>((item) {
                  return DropdownMenuItem(
                    value: item['id'],
                    child: Text(item['nama']), // 🔥 FIX DISINI JUGA
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSupplierId = value;
                  });
                },
              ),

              SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  // 🔥 VALIDASI WAJIB
                  if (selectedKategoriId == null ||
                      selectedSupplierId == null) {
                    Navigator.pop(context);

                    Future.delayed(Duration(milliseconds: 200), () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Semua field wajib diisi")),
                      );
                    });

                    return;
                  }

                  if (namaController.text.isEmpty ||
                      hargaController.text.isEmpty ||
                      stokController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Semua field wajib diisi")),
                    );
                    return;
                  }

                  if (obat == null) {
                    tambahObat(
                      namaController.text,
                      int.parse(hargaController.text),
                      int.parse(stokController.text),
                    );
                  } else {
                    updateObat(
                      obat['id'],
                      namaController.text,
                      int.parse(hargaController.text),
                      int.parse(stokController.text),
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

  String formatHarga(dynamic harga) {
    if (harga == null) return "Rp 0";
    return "Rp ${int.tryParse(harga.toString()) ?? 0}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.teal,
        title: Text(
          'Apotek App 💊',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),

      // ✅ SIDEBAR
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              color: Colors.teal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.local_pharmacy, size: 50, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    "Apotek App",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text("Admin Panel", style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            ListTile(
              leading: Icon(Icons.medication),
              title: Text("Data Obat"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.category),
              title: Text("Kategori"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => KategoriPage()),
                ).then((_) {
                  fetchKategori(); // 🔥 refresh setelah balik
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.local_shipping),
              title: Text("Supplier"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SupplierPage()),
                ).then((_) {
                  fetchSupplier(); // 🔥 refresh setelah balik
                });
              },
            ),
          ],
        ),
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
        child: filteredList.isEmpty
            ? Center(
                child: Text(
                  "Data kosong",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final obat = filteredList[index];

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

                      title: Text(
                        obat['namaObat'] ?? "-",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 6),

                          Text(
                            "${obat['kategori']?['namaKategori'] ?? '-'} | "
                            "${obat['supplier']?['nama'] ?? '-'}",
                            style: TextStyle(color: Colors.grey[700]),
                          ),

                          SizedBox(height: 4),

                          Text(
                            "Stok: ${obat['stok'] ?? 0}",
                            style: TextStyle(fontSize: 12),
                          ),

                          Text(
                            "Harga: ${formatHarga(obat['harga'])}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.orange),
                            onPressed: () => showForm(obat: obat),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              confirmDelete(
                                context: context,
                                id: obat['id'],
                                onDelete: hapusObat,
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
