import 'EbayItem.dart';
import 'EbayFindingApi.dart';

class EbayApiHandler {
  static final EbayFindingApi _ebayFindingApi = EbayFindingApi();

  Future<List<EbayItem>> getItemListings(String keywords, int page) async {
    //Get decoded response from api call
    Map<String, dynamic> responce =
        await _ebayFindingApi.findItemsAdvanced(keywords, page);

    //get product list from response
    var productList =
        responce["findItemsAdvancedResponse"][0]["searchResult"][0]["item"];

    return getEbayItems(productList);
  }

  List<EbayItem> getEbayItems(List<dynamic> productList) {
    List<EbayItem> ebayItems = [];

    for (int i = 0; i < productList.length; i++) {
      //get information for specific ebay item
      String title = productList[i]["title"][0];
      String price =
          productList[i]["sellingStatus"][0]["currentPrice"][0]["__value__"];
      String photoURL = "";
      String country = productList[i]["country"][0];
      String shippingCost = "";
      String condition = "";
      String ebayURL = productList[i]["viewItemURL"][0];

      if (productList[i]["galleryURL"] != null) {
        photoURL = productList[i]["galleryURL"][0];
      }

      if (productList[i]["shippingInfo"] != null) {
        if (productList[i]["shippingInfo"][0]["shippingServiceCost"] != null) {
          shippingCost = productList[i]["shippingInfo"][0]
              ["shippingServiceCost"][0]["__value__"];
        }
      }

      if (productList[i]["condition"] != null) {
        condition = productList[i]["condition"][0]["conditionDisplayName"][0];
      }

      //create ebay item from extracted information and add to ebayItems list
      EbayItem temp = EbayItem(
          title: title,
          price: price,
          photoURL: photoURL,
          country: country,
          condition: condition,
          shippingCost: shippingCost,
          ebayURL: ebayURL);

      ebayItems.add(temp);
    }

    return ebayItems;
  }
}
