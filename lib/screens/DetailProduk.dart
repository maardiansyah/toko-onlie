import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/model/ProdukModel.dart';
import 'package:flutter_application_1/custom/constans.dart';

class DetailProduk extends StatefulWidget {
  final ProdukModel ListProduk;

  DetailProduk({@required this.ListProduk});

  @override
  _DetailProdukState createState() => _DetailProdukState();
}

class _DetailProdukState extends State<DetailProduk> {
  final money = NumberFormat("#,##0", "en_US");

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.keyboard_arrow_left,
                size: 32,
                color: Colors.black,
              ),
            ),
            actions: <Widget>[
              Stack(children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.shopping_cart,
                    color: Colors.cyanAccent,
                  ),
                  onPressed: () {},
                )
              ])
            ]),
        body: Container(
          decoration: BoxDecoration(gradient: kGradient),
          child: SafeArea(
              child: Column(
            children: <Widget>[
              Expanded(
                child: PageView(
                  physics: BouncingScrollPhysics(),
                  children: <Widget>[
                    Container(
                        child: Hero(
                      tag: widget.ListProduk.namaBarang.toString(),
                      child: Image.network(
                        BaseUrl.paths + widget.ListProduk.image.toString(),
                        width: 100,
                        fit: BoxFit.contain,
                      ),
                    ))
                  ],
                ),
              ),
              Container(
                height: size.height * 0.4,
                decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    )),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: size.height * 0.3,
                      padding: EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            widget.ListProduk.namaBarang.toString(),
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.deepPurpleAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  "Rp. " +
                                      money.format(int.parse(
                                          widget.ListProduk.harga.toString())),
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.deepPurpleAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      "Price Ratings",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.blueGrey[200]),
                                    ),
                                    Row(children: <Widget>[
                                      Icon(
                                        Icons.star,
                                        size: 16,
                                        color: kStarsColor,
                                      ),
                                      Icon(
                                        Icons.star,
                                        size: 16,
                                        color: kStarsColor,
                                      ),
                                      Icon(
                                        Icons.star,
                                        size: 16,
                                        color: kStarsColor,
                                      ),
                                      Icon(
                                        Icons.star,
                                        size: 16,
                                        color: kStarsColor,
                                      ),
                                      Icon(
                                        Icons.star_half,
                                        size: 16,
                                        color: kStarsColor,
                                      ),
                                    ])
                                  ],
                                )
                              ]),
                        ],
                      ),
                    ),
                    Container(
                      height: size.height * 0.1,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "Add to Cart",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white),
                            ),
                            SizedBox(width: 16),
                            Icon(
                              Icons.shopping_basket,
                              color: Colors.white,
                              size: 30,
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          )),
        ));
  }
}
