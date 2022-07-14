import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/custom/currency.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:flutter_application_1/model/cartModel.dart';
import 'package:flutter_application_1/model/cartModel.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Checkout.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/custom/currency.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  final money = NumberFormat("#,##0", "en_US");
  final list = [];
  final GlobalKey<RefreshIndicatorState> _refresh =
      GlobalKey<RefreshIndicatorState>();
  var loading = false;
  String idUsers;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      idUsers = preferences.getString("userid");
      _countData();
    });
    _lihatData();
  }

  Future<void> _lihatData() async {
    list.clear();
    setState(() {
      loading = true;
    });
    final response =
        await http.get(Uri.parse(BaseUrl.urlDetailCart + idUsers.toString()));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      data.forEach((api) {
        final ab = new CartModel(api['id_barang'], idUsers.toString(),
            api['nama_barang'], api['gambar'], api['harga'], api['qty']);
        list.add(ab);
      });
    } else {
      print("Gagal Mendapatkan data, harap periksa koneksi anda !");
    }
    setState(() {
      _countData();
      loading = false;
    });
  }

  //checkout process
  dialogCheckout(String userid, String grandtotal) {
    showDialog(
        context: context,
        builder: (context) {
          var _key;
          return Dialog(
            child: Form(
              key: _key,
              child: ListView(
                padding: EdgeInsets.all(16.0),
                shrinkWrap: true,
                children: <Widget>[
                  Text("Form Pembayaran"),
                  TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CurrencyFormat()
                    ],
                    validator: (e) {
                      if ((e as dynamic).isEmpty) {
                        return "Silahkan isi niali bayar";
                      }
                    },
                    onSaved: (e) => nilaiBayar = e,
                    decoration: InputDecoration(labelText: "Nilai Bayar"),
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
                          "Batal",
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: 25.0,
                      ),
                      InkWell(
                        onTap: () {
                          check(userid, grandtotal);
                        },
                        child: Text(
                          "Proses",
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  } //end proses checkout

  //Checkout Empty Cart
  dialogNotif(String txt) {
    showDialog(
        context: context,
        builder: (context) {
          var _keyAlert;
          return Dialog(
            child: Form(
              key: _keyAlert,
              child: ListView(
                padding: EdgeInsets.all(16.0),
                shrinkWrap: true,
                children: <Widget>[
                  Text(
                    txt,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
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
                          "OK",
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  } // end empty cart

  check(String userid, String gt) {
    var _key;
    final form = _key.currentState;
    if ((form as dynamic).validate()) {
      (form as dynamic).save();
      double dTotal = double.parse(gt.replaceAll(",", ""));
      String nb = nilaiBayar.toString().replaceAll(",", "");
      double dNilaiBayar = double.parse(nb);

      if (dNilaiBayar >= dTotal) {
        _checkout(userid, dTotal, dNilaiBayar);
      } else {
        dialogNotif("pembayaran Kurang");
      }
    }
  }

  String totalBelanja = "0";
  Future<void> _countData() async {
    setState(() {
      loading = true;
    });
    final responseCnt =
        await http.get(Uri.parse(BaseUrl.urlCountCart + idUsers.toString()));
    if (responseCnt.contentLength == 2) {
    } else {
      final dataCnt = jsonDecode(responseCnt.body);
      dataCnt.forEach((api) {
        totalBelanja = api["totalharga"];
      });
      setState(() {
        loading = false;
      });
    }
  }

  String nilaiBayar;
  String totalBelanja = "0";
  _checkout(String iduser, double total, double bayar) async {
    double dNilaiKembali = bayar - total;

    final response = await http.post(Uri.parse(BaseUrl.urlCheckout), body: {
      "userid": iduser,
      "grandtotal": bayar.toString(),
      "nilaibayar": bayar.toString(),
      "nilaikembali": dNilaiKembali.toString()
    });

    final data = jsonDecode(response.body);
    int value = data['success'];
    String pesan = data['message'];
    if (value == 1) {
      setState(() {
        Navigator.pop(context);
        //link kehalaman berhasil checkout
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => new Checkout()));
      });
    } else {
      Navigator.pop(context);
      print(pesan);
    }

    _isAddQuantity(
        String idProduk, String harga, String paramUserID, bool isAdd) async {
      String url = isAdd ? BaseUrl.urlAddCart : BaseUrl.urlMinusQty;
      final response = await http.post(Uri.parse(url),
          body: {"userid": paramUserID, "id_barang": idProduk, "harga": harga});

      final data = jsonDecode(response.body);
      int value = data['success'];
      String pesan = data['message'];

      if (value == 1) {
        print(pesan);
        setState(() {
          getPref();
        });
      } else {
        print(pesan);
        throw StateError('Failed to update data.');
      }
    }

    final _keyAlert = new GlobalKey<FormState>();
    dialogDelProductInCart(String idProduk, String harga, String paramUserID) {
      showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: Form(
                  key: _keyAlert,
                  child: ListView(
                    padding: EdgeInsets.all(16.0),
                    shrinkWrap: true,
                    children: <Widget>[
                      Text(
                        "Ingin Menghapus Produk Dari Daftar Pembelian ?",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 18.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              //delete
                              _isAddQuantity(
                                  idProduk, harga, paramUserID, false);
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Ya",
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(width: 10.0),
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
                        ],
                      ),
                    ],
                  )),
            );
          });
    }

    @override
    void initState() {
      //TODO: implement initState
      super.initState();
      getPref();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0.1,
          backgroundColor: Colors.orange,
          title: Text('Detail Belanja'),
          actions: <Widget>[
            new IconButton(
              icon: Icon(Icons.search),
              color: Colors.white,
              onPressed: () {},
            ),
          ],
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
                    int _currentAmount = int.parse(x.qty);
                    int _idbrg =
                        x.id_barang == null ? 0 : int.parse(x.id_barang);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.white,
                                ),
                                child: Image.network(
                                    BaseUrl.paths + "" + x.gambar,
                                    width: 100.0,
                                    height: 160.0,
                                    fit: BoxFit.fill)),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "${x.nama_barang}",
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                                Text(
                                  "Rp. " +
                                      "${money.format(int.parse(x.harga))}",
                                ),
                                SizedBox(height: 15),
                                Row(
                                  children: <Widget>[
                                    GestureDetector(
                                      child: Container(
                                        padding: const EdgeInsets.all(5.0),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.orange,
                                        ),
                                        child: Icon(
                                          Icons.remove,
                                          color: Colors.white,
                                        ),
                                      ),
                                      onTap: () {
                                        if (_currentAmount > 0) {
                                          _isAddQuantity(x.id_barang, x.harga,
                                              x.userid, false);
                                        } else {
                                          _currentAmount = 0;
                                          dialogDelProductInCart(
                                              x.id_barang, x.harga, x.userid);
                                        }
                                      },
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Text(
                                      "$_currentAmount",
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                                    SizedBox(width: 15),
                                    GestureDetector(
                                      child: Container(
                                        padding: const EdgeInsets.all(5.0),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.orange,
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        ),
                                      ),
                                      onTap: () {
                                        _isAddQuantity(x.id_barang, x.harga,
                                            x.userid, true);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
        ),
        bottomNavigationBar: new Container(
          color: Colors.white,
          child: new Row(
            children: <Widget>[
              Expanded(
                child: ListTile(
                  title: new Text("Total : "),
                  subtitle:
                      new Text("Rp. " + money.format(int.parse(totalBelanja))),
                ),
              ),
              Expanded(
                child: new MaterialButton(
                  onPressed: () {
                    totalBelanja != "0"
                        ? dialogCheckout(idUsers.toString(), totalBelanja)
                        : dialogNotif("Tidak ada transaksi");
                  },
                  child: new Text("check out",
                      style: TextStyle(color: Colors.white)),
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
