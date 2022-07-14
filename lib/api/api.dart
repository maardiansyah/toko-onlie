class BaseUrl {
  static String url = "https://apps.mahirdesain.com";
  static String paths = "https://apps.mahirdesain.com/upload/";

  //Data Barang
  static String urlDataBarang = url + "api/data_barang.php";
  //List Kategori
  static String urlListKategori = url + "api/list_kategori.php";
  //tambah barang
  static String urlTambahBarang = url + "api/add_barang.php";
  //Edit data
  static String urlEditingProduk = url + "api/edit_barang.php";
  //Hapus Data
  static String urlHapusProduk = url + "api/delete_barang.php";
  //list satuan
  static String urlSatuan = url + "api/data_satuan.php";
  //sistem login
  static String urlLogin = url + "api/login.php";
  //cart
  static String urlDetailCart = url + "api/detail_cart.php?userid=";
  //add cart
  static String urlAddCart = url + "api/add_cart.php";
  static String urlCountCart = url + "api/count_cart.php?userid=";
  static String urlMinusQty = url + "api/minus_qty_cart.php";
  static String urlCheckout = url + "api/proses_checkout.php";
}
