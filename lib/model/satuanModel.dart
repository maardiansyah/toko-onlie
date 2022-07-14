class satuanModel {
  String idSatuan;
  String namaSatuan;
  String satuan;

  satuanModel(this.idSatuan, this.namaSatuan, this.satuan);

  satuanModel.fromJson(Map<String, dynamic> json) {
    idSatuan = json['id_satuan'];
    namaSatuan = json['nama_satuan'];
    satuan = json['satuan'];
  }
}
