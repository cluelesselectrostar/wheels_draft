import 'package:flutter/material.dart';
import 'package:wheels_draft/nwfb_eta.dart';

import 'main_fav_model.dart';
import 'nwfb_stop.dart';
import 'kmb_tab_controller.dart';
import 'nwfb_tab_controller.dart';

class AllRouteFav extends StatefulWidget {
  @override
  _AllRouteFavState createState() => _AllRouteFavState();
  final GlobalKey<ScaffoldState> _scaffoldKey =
      new GlobalKey<ScaffoldState>(); //WARNING
}

class _AllRouteFavState extends State<AllRouteFav> {
  String _setImage(String operatorHK) {
    if (operatorHK == "lwb") {
      return 'images/lwb.png';
    } else if (operatorHK == "kmb") {
      return 'images/kmb.png';
    } else if (operatorHK == "NWFB") {
      return 'images/nwfb.jpg';
    } else if (operatorHK == "CTB") {
      return 'images/ctb.png';
    } else {
      return 'images/joint.png';
    }
  }

  Widget stopTitle(String operatorHK, String cName) {
    if (operatorHK == "kmb" || operatorHK == "lwb") {
      return Text(cName);
    } else if (operatorHK == "CTB" || operatorHK == "NWFB") {
      return NWFBStop(stopID: cName);
    } else {
      return Text(cName);
    }
  }

  Widget loadETA(String operatorHK, String stopID, String route, String bound,
      String serviceType, String seq) {
    if (operatorHK == 'CTB' || operatorHK == 'NWFB') {
      return NWFBETA(operatorHK: operatorHK, stopID: stopID, route: route);
    } else if (operatorHK == 'kmb' || operatorHK == 'lwb') {
      return Text('ETA Placeholder');
    } else {
      //TODO: this is just temporary
      return NWFBETA(operatorHK: operatorHK, stopID: stopID, route: route);
    }
  }

  void pushtoListStop(
      String operatorHK,
      String stopID,
      String route,
      String bound,
      String serviceType,
      String seq,
      String oriTC,
      String destTC) {
    if (operatorHK == "kmb" || operatorHK == "lwb") {
      setState(() {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => KMBTabs(
                    //TODO: need to fix circular
                    route: route,
                    serviceType: serviceType,
                    bound: bound,
                    oriTC: oriTC,
                    destTC: destTC,
                    isSearching: false,
                    isCircular: false,
                  )),
        );
      });
    } else if (operatorHK == "CTB" || operatorHK == "NWFB") {
      String boundMod;
      if (bound.contains("O")) { //Outbound
        boundMod = "1";
      } else if (bound.contains("I")) { //Inbound
        bound = "2";
      } else {
        boundMod = "0";
      }
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NWFBTabs(
                  route: route,
                  bound: boundMod,
                  oriTC: oriTC,
                  destTC: destTC,
                  operatorHK: operatorHK,
                  isSearching: false,
                )),
      );
    } else {
      //jointly operated services
      setState(() {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => KMBTabs(
                  route: route,
                  serviceType: serviceType,
                  bound: bound,
                  oriTC: oriTC,
                  destTC: destTC,
                  isSearching: false,
                  isCircular: false)),
        );
      });
    }
  }

  Widget displayDestination(String operatorHK, String destTC) {
    if (operatorHK == "NWFB" || operatorHK == "CTB") {
      return Row(
        children: [
          Text("往: "),
          NWFBStop(stopID: destTC),
        ],
      );
    } else if (operatorHK == 'kmb' || operatorHK == 'lwb') {
      return Text("往: " + destTC);
    } else {
      //TODO: this is just temporary
      return Text("往: " + destTC);
    }
  }

  ////////// TEMPORARY LOCAL VARIABLES ////////////
  String favID;
  String favOperatorHK;
  String favRoute;
  String favBound;
  String favStopCode;
  String favCName;
  String favServiceType;
  String favSeq;
  String favOriTC;
  String favDestTC;
  String favKeyID;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("我的最愛🤩"),
          backgroundColor: Colors.indigo,
        ),
        body: FutureBuilder(
            future: DBProvider.db.getAllFavStops(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return LinearProgressIndicator(
                  backgroundColor: Colors.teal,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                );
              } else {
                if (snapshot.data.length == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "我好空虛啊，即刻轆去隔離將最愛嘅車站加入嚟！",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 30,
                          ),
                        ),
                        Text(
                          "👉🏼",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 80,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      //ASSIGN VALUES TO TEMPORARY VARIABLES
                      favID = snapshot.data[index].id;
                      favOperatorHK = snapshot.data[index].operatorHK;
                      favRoute = snapshot.data[index].route;
                      favBound = snapshot.data[index].bound;
                      favStopCode = snapshot.data[index].stopCode;
                      favCName = snapshot.data[index].cName;
                      favServiceType = snapshot.data[index].serviceType;
                      favSeq = snapshot.data[index].seq;
                      favOriTC = snapshot.data[index].oriTC;
                      favDestTC = snapshot.data[index].destTC;

                      return Card(
                        child: ExpansionTile(
                            leading: Container(
                              width: 60,
                              child: Column(
                                children: [
                                  Image(
                                    image: new AssetImage(
                                        _setImage(favOperatorHK)),
                                    height: 25,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Text(favRoute,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  )
                                ],
                              ),
                            ),
                            title: stopTitle(favOperatorHK, favCName),
                            subtitle:
                                displayDestination(favOperatorHK, favDestTC),
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 75, bottom: 30.0),
                                    child: loadETA(
                                        snapshot.data[index].operatorHK,
                                        snapshot.data[index].stopCode,
                                        snapshot.data[index].route,
                                        snapshot.data[index].bound,
                                        snapshot.data[index].serviceType,
                                        snapshot.data[index].seq),
                                  ),
                                  IconButton(
                                    icon: new Icon(Icons.delete),
                                    onPressed: () {
                                      return showDialog(
                                        context: context,
                                        barrierDismissible:
                                            false, // user must tap button for close dialog!
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('拜拜？😢'),
                                            content:
                                                const Text('我會由「我的最愛」介面消失。'),
                                            actions: <Widget>[
                                              FlatButton(
                                                child: const Text('取消'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              FlatButton(
                                                child: const Text('確認'),
                                                onPressed: () {
                                                  setState(() {
                                                    DBProvider.db
                                                        .deleteFavStop(favID);
                                                  });
                                                  Navigator.of(context).pop();
                                                },
                                              )
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  )
                                ],
                              ),
                            ],
                            trailing: IconButton(
                              icon: Icon(Icons.keyboard_arrow_right),
                              onPressed: () {
                                pushtoListStop(
                                  snapshot.data[index].operatorHK,
                                  snapshot.data[index].stopCode,
                                  snapshot.data[index].route,
                                  snapshot.data[index].bound,
                                  snapshot.data[index].serviceType,
                                  snapshot.data[index].seq,
                                  snapshot.data[index].oriTC,
                                  snapshot.data[index].destTC,
                                );
                              },
                            )),
                      );
                    },
                  );
                }
              }
            }));
  }
}
