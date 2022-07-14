import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/ProdukModel.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/screens/EditProduk.dart';
import 'package:flutter_application_1/screens/TambahProduk.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ListProduk extends StatefulWidget {
  @override
  _ListProdukState createState() => _ListProdukState();
}

class _ListProdukState extends State<ListProduk> {
  final money = NumberFormat("#,##0", "en_US");
  var loading = false;
  final list = [];
  final GlobalKey<RefreshIndicatorState> _refresh =
      GlobalKey<RefreshIndicatorState>();
  getPref() async {
    _lihatData();
  }

  Future<void> _lihatData() async {
    list.clear();
    setState(() {
      loading = true;
    });

    final response = await http.get(Uri.parse(BaseUrl.urlDataBarang));

    if (response.contentLength == 2) {
    } else {
      final data = jsonDecode(response.body);
      data.forEach((api) {
        final ab = new ProdukModel(api['id_barang'], api['id_kategori'],
            api['nama_barang'], api['harga'], api['image'], api['tglexpired']);
        list.add(ab);
      });

      setState(() {
        loading = false;
      });
    }
  }

  _proseshapus(String idbrg) async {
    final response = await http
        .post(Uri.parse(BaseUrl.urlHapusProduk), body: {"idProduk": idbrg});
    final data = jsonDecode(response.body);
    int value = data['success'];
    String pesan = data['message'];
    if (value == 1) {
      setState(() {
        Navigator.pop(context);
        _lihatData();
      });
    } else {
      print(pesan);
    }
  }

  dialogHapus(String idbrg) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: ListView(
            padding: EdgeInsets.all(16.0),
            shrinkWrap: true,
            children: <Widget>[
              Text(
                "Apakah anda yakin ingin menghapus data ini?",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 18.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Tidak",
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 25.0),
                  InkWell(
                    onTap: () {
                      _proseshapus(idbrg);
                    },
                    child: Text(
                      "Ya",
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                "Data Produk",
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => new TambahProduk(_lihatData)));
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromRGBO(255, 82, 48, 1),
      ),
      body: RefreshIndicator(
          onRefresh: _lihatData,
          key: _refresh,
          child: loading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final x = list[i];
                    return Container(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Image.network(BaseUrl.paths + "" + x.image.toString(),
                              width: 100.0, height: 120.0, fit: BoxFit.cover),
                          SizedBox(width: 10.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("No." + x.idBarang.toString(),
                                    style: TextStyle(fontSize: 15.0)),
                                Text(x.namaBarang.toString(),
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    "Rp." +
                                        money.format(
                                            int.parse(x.harga.toString())),
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        EditProduk(x, _lihatData)));
                              }),
                          IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                dialogHapus(x.idBarang);
                              }),
                        ],
                      ),
                    );
                  },
                )),
    );
  }
}
