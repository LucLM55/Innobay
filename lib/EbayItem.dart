class EbayItem {
  final String title;
  final String price;
  final String photoURL;
  final String country;
  final String condition;
  final String shippingCost;
  final String ebayURL;

  EbayItem(
      {required this.title,
      required this.price,
      required this.photoURL,
      required this.country,
      required this.condition,
      required this.shippingCost,
      required this.ebayURL});
}
