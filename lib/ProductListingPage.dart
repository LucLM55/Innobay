import 'package:flutter/material.dart';
import 'package:innobay/EbayApiHandler.dart';
import 'EbayItem.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductListingPage extends StatefulWidget {
  final String keywords;
  ProductListingPage({Key? key, required this.keywords}) : super(key: key);

  @override
  _ProductListingPageState createState() =>
      _ProductListingPageState(keywords: this.keywords);
}

class _ProductListingPageState extends State<ProductListingPage> {
  String keywords;
  List<EbayItem> _itemListing = [];
  final EbayApiHandler _ebayApiHandler = EbayApiHandler();
  int _page = 1;
  ScrollController _scrollController = ScrollController();
  bool _loadingNewPage = false;

  _ProductListingPageState({required this.keywords});

  @override
  initState() {
    super.initState();
    getItemListings();
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_loadingNewPage) {
        //prevents subsequent listener events until new items loaded
        _loadingNewPage = true;

        //increase product page to get next ebay items
        _page++;

        await getItemListings();

        _loadingNewPage = false;
      }
    });
  }

  getItemListings() async {
    //loads new ebay items and concatenates it to current list of ebay items
    List<EbayItem> newItems =
        await _ebayApiHandler.getItemListings(keywords, _page);

    setState(() {
      _itemListing = _itemListing + newItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //Used to close keyboard when tapping elsewhere on screen
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Color(0xFF18191A),
          elevation: 0.0,
          automaticallyImplyLeading: false,
          leading: null,
          title: TextFormField(
            initialValue: keywords,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
            onChanged: (String k) {
              keywords = k;
            },
            onEditingComplete: () {
              //clear currently displayed items
              setState(() {
                _itemListing.clear();
                _page = 1;
              });

              //get first page of items for new keyword
              getItemListings();

              //close keyboard
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                color: Colors.white,
                size: 30,
              ),
              filled: true,
              hintStyle: TextStyle(
                color: Color(0xFFB3B3B3),
                fontSize: 17,
              ),
              contentPadding:
                  EdgeInsets.only(left: 0, right: 0, top: 14, bottom: 0),
              hintText: "Search for anything",
              fillColor: Color(0xFF3A3B3C),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF3A3B3C)),
                borderRadius: BorderRadius.circular(30),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF3A3B3C)),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        backgroundColor: Color(0xFF18191A),
        body: _itemListing.length == 0
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                controller: _scrollController,
                itemCount: _itemListing.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index < _itemListing.length) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: 100,
                          minWidth: double.infinity,
                        ),
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 1.0,
                                spreadRadius: 0.0,
                                offset: Offset(0.0, 1.0),
                              )
                            ],
                            color: Color(0xFF2A2B2C),
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0))),
                        child: Row(children: [
                          Expanded(
                            //add item image
                            flex: 30,
                            child: _itemListing[index].photoURL != ""
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: FittedBox(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        child: Container(
                                          height: 100,
                                          width: 100,
                                          color: Color(0xFF3A3B3C),
                                          child: Image.network(
                                            _itemListing[index].photoURL,
                                            scale: 0.8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),
                          ),
                          Expanded(
                            flex: 70,
                            child: Column(
                              children: [
                                //add title
                                Container(
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: GestureDetector(
                                      onTap: () async {
                                        if (await canLaunch(
                                            _itemListing[index].ebayURL)) {
                                          await launch(
                                              _itemListing[index].ebayURL);
                                        }
                                      },
                                      child: Text(
                                        _itemListing[index].title,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.left,
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                //add item condition if information is available
                                if (_itemListing[index].condition != "")
                                  Container(
                                    width: double.infinity,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        "${_itemListing[index].condition}",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Color(0xFFB3B3B3),
                                        ),
                                      ),
                                    ),
                                  ),

                                //add item price
                                Container(
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      "\$${_itemListing[index].price}",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Color(0xFFF15524),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ),
                                ),

                                //add shipping cost if information is available
                                if (_itemListing[index].shippingCost != "")
                                  Container(
                                    width: double.infinity,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        _itemListing[index].shippingCost !=
                                                "0.0"
                                            ? "Shipping Cost: \$${_itemListing[index].shippingCost}"
                                            : "Free Shipping",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Color(0xFFB3B3B3),
                                        ),
                                      ),
                                    ),
                                  ),
                                SizedBox(
                                  height: 8,
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),
                    );
                  } else {
                    //show progress indicator if reached end of list
                    return Container(
                      height: 50,
                      child: Center(
                        child: Container(
                          height: 30,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }
                }),
      ),
    );
  }
}
