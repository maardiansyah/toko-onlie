import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/custom/currency.dart';
import 'package:flutter_application_1/custom/datePicker.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/model/KategoriModel.dart';
import 'package:flutter_application_1/model/ProdukModel.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class EditProduk extends StatefulWidget {
  final VoidCallback reload;
  final ProdukModel model;
  EditProduk(this.model, this.reload);

  @override
  _EditProdukState createState() => _EditProdukState();
}

class _EditProdukState extends State<EditProduk> {
  String idBarang, namaBarang, harga, tglExpired, kategoriID;
  final _key = new GlobalKey<FormState>();

  TextEditingController txtnamaBarang, txtHarga;
  setup() async {
    tglExpired = widget.model.tglexpired;
    txtnamaBarang = TextEditingController(text: widget.model.namaBarang);
    txtHarga = TextEditingController(text: widget.model.harga);
    idBarang = widget.model.idBarang;
  }

  //tambahan ddl
  kategoriModel _currentKategori;
  final listKategori = [];
  final String linkKategori = BaseUrl.urlListKategori;

  Future<List<kategoriModel>> _fetchKategori() async {
    var response = await http.get(Uri.parse(linkKategori));

    if (response.statusCode == 200) {
      final items = json.decode(response.body).cast<Map<String, dynamic>>();
      List<kategoriModel> listOfKategori = items.map<kategoriModel>((json) {
        return kategoriModel.fromJson(json);
      }).toList();
      return listOfKategori;
    } else {
      throw Exception('Failed to Load Internet');
    }
  }

  check() {
    final form = _key.currentState;
    if ((form as dynamic).validate()) {
      (form as dynamic).save();
      prosesbarang();
    }
  }

  prosesbarang() async {
    try {
      final response = await http
          .post(Uri.parse(BaseUrl.urlEditingProduk.toString()), body: {
        "id_barang": idBarang,
        "nama_barnag": namaBarang,
        "harga": harga.replaceAll(",", ""),
        "tglexpired": "$tgl",
        "id_kategori": kategoriID.toString()
      });
      final data = jsonDecode(response.body);
      print(data);
      int code = data['success'];
      String pesan = data['message'];
      print(data);
      if (code == 1) {
        setState(() {
          widget.reload();
          Navigator.pop(context);
        });
      } else {
        print(pesan);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  String labelText;
  DateTime tgl = new DateTime.now();
  var formatTgl = new DateFormat('yyyy-MM-dd');
  final TextStyle valueStyle = TextStyle(fontSize: 16.0);
  Future<Null> _selectedDate(BuildContext context) async {
    tgl = DateTime.parse(widget.model.tglexpired.toString());
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: tgl,
        firstDate: DateTime(1992),
        lastDate: DateTime(2099));

    if (picked != null && picked != tgl) {
      setState(() {
        tgl = picked;
        tglExpired = formatTgl.format(tgl);
      });
    } else {}
  }

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(244, 244, 244, 1),
      appBar: AppBar(),
      body: Form(
        key: _key,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            Text('Kategori Produk'),
            FutureBuilder<List<kategoriModel>>(
                future: _fetchKategori(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<kategoriModel>> snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  return DropdownButton<kategoriModel>(
                    items: snapshot.data
                        .map((listkategori) => DropdownMenuItem<kategoriModel>(
                              child: Text(listkategori.namaKategori.toString()),
                              value: listkategori,
                            ))
                        .toList(),
                    onChanged: (kategoriModel value) {
                      setState(() {
                        _currentKategori = value;
                        kategoriID = _currentKategori?.idKategori;
                      });
                    },
                    isExpanded: false,
                    hint: Text(kategoriID == null
                        ? "0"
                        : _currentKategori.namaKategori.toString()),
                  );
                }),
            TextFormField(
              controller: txtnamaBarang,
              validator: (e) {
                if (e.isEmpty) {
                  return "Silahkan isi Nama Produk";
                } else {
                  return null;
                }
              },
              onSaved: (e) => namaBarang = e,
              decoration: InputDecoration(labelText: "Nama Produk"),
            ),
            TextFormField(
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyFormat()
              ],
              controller: txtHarga,
              validator: (e) {
                if (e.isEmpty) {
                  return "Silahkan isi Harga Produk";
                }
              },
              onSaved: (e) => harga = e,
              decoration: InputDecoration(labelText: "Harga Produk"),
            ),
            Text("Tgl Expired"),
            DateDropDown(
              labelText: labelText,
              valueText: tglExpired,
              valueStyle: valueStyle,
              onPressed: () {
                _selectedDate(context);
              },
            ),
            MaterialButton(
              onPressed: () {
                check();
              },
              child: Text("Simpan"),
            )
          ],
        ),
      ),
    );
  }
}
