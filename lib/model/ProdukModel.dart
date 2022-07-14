class ProdukModel {
  String idBarang;
  String idKategori;
  String namaBarang;
  String harga;
  String image;
  String tglexpired;

  ProdukModel(this.idBarang, this.idKategori, this.namaBarang, this.harga,
      this.image, this.tglexpired);

  ProdukModel.fromJson(Map<String, dynamic> json) {
    idBarang = json['id_barang'];
    idKategori = json['id_kategori'];
    namaBarang = json['nama_barang'];
    harga = json['harga'];
    image = json['image'];
    tglexpired = json['tglexpored'];
  }
}
