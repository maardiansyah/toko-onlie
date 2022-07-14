class kategoriModel {
  String idKategori;
  String namaKategori;

  kategoriModel(this.idKategori, this.namaKategori);

  kategoriModel.fromJson(Map<String, dynamic> json) {
    idKategori = json['id_kategori'];
    namaKategori = json['nama_kategori'];
  }
}
