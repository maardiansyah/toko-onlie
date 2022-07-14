import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/custom/currency.dart';
import 'package:flutter_application_1/custom/datePicker.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/model/kategoriModel.dart';
import 'package:flutter_application_1/model/satuanModel.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:async/async.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class TambahProduk extends StatefulWidget {
  final VoidCallback reload;
  TambahProduk(this.reload);

  @override
  _TambahProdukState createState() => _TambahProdukState();
}

class _TambahProdukState extends State<TambahProduk> {
  String namaBarang, harga, userid, kategoriId, jumlah, satuanId;

  final _key = new GlobalKey<FormState>();
  File _imageFile;

  //tambahan dropdownlist kategori
  kategoriModel _currentKategori;
  satuanModel _currentSatuan;
  final String linkKategori = BaseUrl.urlListKategori;
  final String linkSatuan = BaseUrl.urlSatuan;

  Future<List<kategoriModel>> _fetchKategori() async {
    var response = await http.get(Uri.parse(linkKategori.toString()));
    print('hasil:' + response.statusCode.toString());
    if (response.statusCode == 200) {
      final items = json.decode(response.body).cast<Map<String, dynamic>>();
      List<kategoriModel> listOfKategori = items.map<kategoriModel>((json) {
        return kategoriModel.fromJson(json);
      }).toList();

      return listOfKategori;
    } else {
      throw Exception('failed to load internet');
    }
  }

  _pilihGalery() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 1920.0, maxWidth: 1080);

    setState(() {
      _imageFile = image;
      Navigator.pop(context);
    });
  }

  _pilihcamera() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 1920.0, maxWidth: 1080);

    setState(() {
      _imageFile = image;
      Navigator.pop(context);
    });
  }

  Future<List<satuanModel>> _fetchSatuan() async {
    var response = await http.get(Uri.parse(linkSatuan.toString()));
    print('hasil:' + response.statusCode.toString());
    if (response.statusCode == 200) {
      final items = json.decode(response.body).cast<Map<String, dynamic>>();
      List<satuanModel> listOfSatuan = items.map<satuanModel>((json) {
        return satuanModel.fromJson(json);
      }).toList();

      return listOfSatuan;
    } else {
      throw Exception('failed to load');
    }
  }

  check() {
    final form = _key.currentState;
    if ((form as dynamic).validate()) {
      (form as dynamic).save();
      simpanbarang();
    }
  }

  simpanbarang() async {
    try {
      var stream =
          http.ByteStream(DelegatingStream.typed(_imageFile.openRead()));
      var length = await _imageFile.length();
      final response =
          await http.post(Uri.parse(BaseUrl.urlTambahBarang.toString()), body: {
        "nama_barang": namaBarang,
        "harga": harga.replaceAll(",", ""),
        "tglexpired": "$tgl",
        "id_kategori": kategoriId.toString(),
        "id_satuan": satuanId,
        "userid": "1",
        "image": File(http.MultipartFile("image", stream, length,
                filename: path.basename(_imageFile.path))
            .toString()),
      });
      final data = jsonDecode(response.body);
      print(data);
      int code = data['success'];
      String pesan = data['message'];
      print(data);
      if (code == 1) {
        setState(() {
          Navigator.pop(context);
          widget.reload();
        });
      } else {
        print(pesan);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  String pilihTanggal, labelText;
  DateTime tgl = new DateTime.now();
  final TextStyle valueStyle = TextStyle(fontSize: 16.0);
  Future<Null> _selectedDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: tgl,
        firstDate: DateTime(1992),
        lastDate: DateTime(2099));

    if (picked != null && picked != tgl) {
      setState(() {
        tgl = picked;
        pilihTanggal = new DateFormat.yMd().format(tgl);
      });
    } else {}
  }

  //menambahkan file foto kedalam form
  dialogFileFoto() {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: ListView(
              padding: EdgeInsets.all(16.0),
              shrinkWrap: true,
              children: <Widget>[
                Text(
                  "Pilih Sumber Foto",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 18.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    InkWell(
                        onTap: () {
                          _pilihcamera();
                        },
                        child: Text(
                          "Kamera",
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        )),
                    SizedBox(
                      width: 25.0,
                    ),
                    InkWell(
                        onTap: () {
                          _pilihGalery();
                        },
                        child: Text(
                          "Gallery",
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        )),
                  ],
                )
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var placeholder = Container(
      width: double.infinity,
      height: 150.0,
      child: Image.asset("./asset/noimage.png"),
    );
    return Scaffold(
        backgroundColor: Color.fromRGBO(244, 244, 244, 1),
        appBar: AppBar(),
        body: Form(
          key: _key,
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: <Widget>[
              Text("Foto Produk"),
              Container(
                  width: double.infinity,
                  height: 150.0,
                  child: InkWell(
                      onTap: () {
                        dialogFileFoto();
                      },
                      child: _imageFile == null
                          ? placeholder
                          : Image.file(_imageFile, fit: BoxFit.fill))),
              Text("Kategori Produk"),
              FutureBuilder<List<kategoriModel>>(
                  future: _fetchKategori(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<kategoriModel>> snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    return DropdownButton<kategoriModel>(
                      items: snapshot.data
                          .map((listKategori) =>
                              DropdownMenuItem<kategoriModel>(
                                child:
                                    Text(listKategori.namaKategori.toString()),
                                value: listKategori,
                              ))
                          .toList(),
                      onChanged: (kategoriModel value) {
                        setState(() {
                          _currentKategori = value;
                          kategoriId = _currentKategori.idKategori;
                        });
                      },
                      isExpanded: false,
                      hint: Text(kategoriId == null
                          ? "0"
                          : _currentKategori.namaKategori.toString()),
                    );
                  }),
              Text("Satuan Produk"),
              FutureBuilder<List<satuanModel>>(
                  future: _fetchSatuan(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<satuanModel>> snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    return DropdownButton<satuanModel>(
                      items: snapshot.data
                          .map((listSatuan) => DropdownMenuItem<satuanModel>(
                                child: Text(listSatuan.namaSatuan.toString()),
                                value: listSatuan,
                              ))
                          .toList(),
                      onChanged: (satuanModel value) {
                        setState(() {
                          _currentSatuan = value;
                          satuanId = _currentSatuan.idSatuan;
                        });
                      },
                      isExpanded: false,
                      hint: Text(satuanId == null
                          ? "0"
                          : _currentSatuan.namaSatuan.toString()),
                    );
                  }),
              TextFormField(
                validator: (e) {
                  if ((e as dynamic).isEmpty) {
                    return "Silahkan isi nama Produk";
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
                validator: (e) {
                  if ((e as dynamic).isEmpty) {
                    return "Silahkan isi harga Produk";
                  }
                },
                onSaved: (e) => harga = e,
                decoration: InputDecoration(labelText: "Harga Produk"),
              ),
              Text("Tgl Expired"),
              DateDropDown(
                labelText: labelText,
                valueText: new DateFormat.yMd().format(tgl),
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
        ));
  }
}
