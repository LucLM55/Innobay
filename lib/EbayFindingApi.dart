import 'dart:convert';
import 'package:http/http.dart' as http;

class EbayFindingApi {
  static final String _findingApiURL =
      "https://svcs.ebay.com/services/search/FindingService/v1?";
  static final String _appIDSandbox =
      "StevenRo-FusionGo-SBX-6c8ec878c-edd01a0c";
  static final String _appID = "StevenRo-FusionGo-PRD-3c8ec878c-8e82459a";
  static final int _entriesPerPage = 20;

  Future<Map<String, dynamic>> findItemsAdvanced(
      String keywords, int page) async {
    String url =
        "${_findingApiURL}OPERATION-NAME=findItemsAdvanced&SERVICE-VERSION=1.12.0&SECURITY-APPNAME=$_appID&RESPONSE-DATA-FORMAT=JSON&paginationInput.entriesPerPage=$_entriesPerPage&paginationInput.pageNumber=$page&itemFilter.name=HideDuplicateItems&itemFilter.value=true&keywords=$keywords";

    //encode url using percent-encoding
    var encoded = Uri.encodeFull(url);

    //make api call
    var responce = await http.get(Uri.parse(encoded));

    print(responce.body);

    //decode JSON response into Map
    Map<String, dynamic> decodedData = json.decode(responce.body);

    return decodedData;
  }
}
