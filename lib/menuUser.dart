import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/ListProduk.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'model/ProdukModel.dart';
import 'package:flutter_application_1/custom/constans.dart';
import 'api/api.dart';
import 'screens/DetailProduk.dart';
import 'screens/Cart.dart';

class MenuUser extends StatefulWidget {
  final VoidCallback signOut;
  MenuUser(this.signOut);
  @override
  _MenuUserState createState() => _MenuUserState();
}

class _MenuUserState extends State<MenuUser> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refresh =
      GlobalKey<RefreshIndicatorState>();
  final money = NumberFormat("#,##0", "en_US");
  var loading = false;
  final listProduk = [];

  signOut() {
    setState(() {
      widget.signOut();
    });
  }

  String idUsers = "0";
  getPref() async {
    _lihatData();
  }

  Widget buildItem(ProdukModel listProduk) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      new DetailProduk(ListProduk: listProduk)));
        },
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: kGradient,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: Border.all(
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                ),
                margin: EdgeInsets.only(right: 24),
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 0,
                      ),
                      child:
                          //widget hero() dihapus
                          Center(
                        child: Image.network(
                          BaseUrl.paths + listProduk.image.toString(),
                          width: 190,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        //fitur add to cart
                        tambahKeranjang(listProduk.idBarang.toString(),
                            listProduk.harga.toString());
                        //print("Tambah Produk");
                      },
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.lime,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(25),
                            ),
                          ),
                          width: 60,
                          height: 60,
                          child: Center(
                            child: Icon(
                              Icons.add_shopping_cart,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                listProduk.namaBarang.toString(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "Rp. " + money.format(int.parse(listProduk.harga.toString())),
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold),
              ),
            ]));
  }

  List<Widget> buildItems() {
    List<Widget> list = [];
    for (var listProduk in listProduk) {
      list.add(buildItem(listProduk));
    }
    return list;
  }

  Future<void> _lihatData() async {
    listProduk.clear();
    setState(() {
      loading = true;
    });
    final response = await http.get(Uri.parse(BaseUrl.urlDataBarang));
    if (response.contentLength == 2) {
    } else {
      final data = jsonDecode(response.body);
      data.forEach((api) {
        final ab = new ProdukModel(api['idbarang'], api['id_kategori'],
            api['nama_barang'], api['harga'], api['image'], api['tglexpired']);
        listProduk.add(ab);
      });
      setState(() {
        loading = false;
      });
    }
  }

  tambahKeranjang(String id_produk, String harga) async {
    final response = await http.post(Uri.parse(BaseUrl.urlAddCart),
        body: {"userid": idUsers, "id_barang": id_produk, "harga": harga});

    final data = jsonDecode(response.body);
    int value = data['success'];
    String pesan = data['message'];
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _lihatData,
        key: _refresh,
        child: loading
            ? Center(child: CircularProgressIndicator())
            : Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Padding(
                    padding: EdgeInsets.only(left: 24),
                    child: IconButton(
                      onPressed: () => _scaffoldKey.currentState.openDrawer(),
                      icon: Icon(
                        Icons.menu,
                        size: 32,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  title: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0.0),
                      topRight: Radius.circular(0.0),
                    ),
                    child: Image.asset("asset/img/logo.png"),
                  ),
                  actions: <Widget>[
                    Stack(
                      children: <Widget>[
                        IconButton(
                          onPressed: () {
                            //aksi halaman cart
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => new Cart()));
                          },
                          icon: Icon(
                            Icons.shopping_cart,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                key: _scaffoldKey,
                body: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Container(
                    padding: EdgeInsets.only(left: 24, top: 16, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          "Produk Terlaris",
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 300,
                          child: ListView(
                            physics: BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            children: buildItems(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                drawer: Drawer(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      UserAccountsDrawerHeader(
                        accountName: new Text("Administrator"),
                        accountEmail: new Text("admin@globalshop.com"),
                        currentAccountPicture: new CircleAvatar(
                          backgroundImage: AssetImage('asset/img/user.png'),
                        ),
                      ),
                      ListTile(
                        title: Text("Master Data"),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => new ListProduk()));
                        },
                      ),
                      //fungsi LogOut
                      ListTile(
                        title: Text("LogOut"),
                        onTap: () {
                          setState(() {
                            signOut();
                          });
                        },
                      )
                    ],
                  ),
                ),
              ));
  }
}
