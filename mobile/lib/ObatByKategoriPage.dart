import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ObatByKategoriPage extends StatefulWidget {
  final int kategoriId;
  final String namaKategori;

  const ObatByKategoriPage({
    super.key,
    required this.kategoriId,
    required this.namaKategori,
  });

  @override
  State<ObatByKategoriPage> createState() => _ObatByKategoriPageState();
}

class _ObatByKategoriPageState extends State<ObatByKategoriPage> {
  List obatList = [];

  final String baseUrl = "http://localhost:8080/api/obat";

  @override
  void initState() {
    super.initState();
    fetchObat();
  }

  Future<void> fetchObat() async {
    final response = await http.get(
      Uri.parse("$baseUrl?kategoriId=${widget.kategoriId}"),
    );

    if (response.statusCode == 200) {
      setState(() {
        obatList = json.decode(response.body);
      });
    }
  }

  String formatHarga(dynamic harga) {
    return "Rp ${int.parse(harga.toString())}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.namaKategori)),
      body: ListView.builder(
        itemCount: obatList.length,
        itemBuilder: (context, index) {
          final obat = obatList[index];

          return ListTile(
            title: Text(obat['namaObat']),
            subtitle: Text(
              "${obat['kategori']?['namaKategori'] ?? '-'} | "
              "${obat['supplier']?['nama'] ?? '-'} \n"
              "Stok: ${obat['stok'] ?? 0} | "
              "Harga: ${formatHarga(obat['harga'])}",
            ),
          );
        },
      ),
    );
  }
}
