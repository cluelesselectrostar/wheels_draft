//import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'dart:convert';
//import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';

class NWFBLSService {
  static LocalStorage storage = new LocalStorage("nwfbRoutes");
  //var stopwatch = new Stopwatch()..start();

  void saveNWFBLS(String route, String bound, String operatorHK, NWFBAPI nwfbLS) async {
    await storage.ready;
    storage.setItem("nwfbroute"+route+"bound"+bound+"operator"+operatorHK, nwfbLS);
    print("saved item as " + "nwfbroute"+route+"bound"+bound+"operator"+operatorHK);
  }

    void deleteNWFBLS() async {
    await storage.ready;
    storage.clear();
    print("deleted all NWFBLS");
  }

  Future<NWFBAPI> getNWFBLS(String route, String bound, String operatorHK) async {
    NWFBAPI nwfbLS = await getNWFBLSFromCache(route, bound, operatorHK);
    if (nwfbLS == null) {
      nwfbLS = await getNWFBLSFromAPI(route, bound, operatorHK);
    }
    return nwfbLS;
    //how bout trying differentiating the 2 variables?
  }

  Future<NWFBAPI> getNWFBLSFromAPI(String route, String bound, String operatorHK) async {
    print("call from nwfbroute api");
    NWFBAPI nwfbLS = await fetchNWFBAPI(route, bound, operatorHK);
    nwfbLS.fromCache = false;
    //Future.delayed(Duration(milliseconds: 100));
    saveNWFBLS(route, bound, operatorHK, nwfbLS);
    return nwfbLS;  
  }

  Future<NWFBAPI> getNWFBLSFromCache(String route, String bound, String operatorHK) async {
    print("call from nwfbroute cache");
    await storage.ready;
    Map <String, dynamic> data = storage.getItem("nwfbroute"+route+"bound"+bound+"operator"+operatorHK);
    print(data);
    if (data == null) {
      return null;
    }
    NWFBAPI nwfbLS = NWFBAPI.fromJson(data);
    nwfbLS.fromCache = true;
    print("loaded item as " + "nwfbroute"+route+"bound"+bound+"operator"+operatorHK);
    return nwfbLS;
  }

  Future<NWFBAPI> fetchNWFBAPI(String route, String bound, String operatorHK) async {
    operatorHK.toUpperCase();
    /*
    String boundMod;
    if (bound == '1') {
      boundMod = "outbound";
    } else if (bound == '2') {
      boundMod = "inbound";
    }
    */
    String link = "https://rt.data.gov.hk/v1/transport/citybus-nwfb/route-stop/" + operatorHK + "/" + route + "/" + bound;
    print(link);
    final response = await http.get(link);

    var jsonresponse = json.decode(response.body);
    if (response.statusCode == 200) {
      print("get response");
      return NWFBAPI.fromJson(jsonresponse);
    } else {
      throw Exception('Failed to load information');
    }
  }
}

class NWFBAPI {
  List<NWFBRouteStops> routeStopsList;
  bool fromCache;

  NWFBAPI({this.routeStopsList, this.fromCache});

  factory NWFBAPI.fromJson(Map<String, dynamic> json) {
    //print("start API");
    var list = json["data"] as List;
    print(list.runtimeType);

    List<NWFBRouteStops> amendedList = list.map((i) =>
      NWFBRouteStops.fromJson(i)). toList();

    return new NWFBAPI(
      routeStopsList: amendedList,
    );
  }

  Map<String, dynamic> toJson() => { 
    "data": new List<dynamic>.from(routeStopsList.map((x) => x.toJson())),
  };

}

class NWFBRouteStops {
  String co;
  String route;
  String dir;
  num seq;
  String stop;
  String dataTimeStamp;

  NWFBRouteStops({this.co, this.route, this.dir, this.seq, this.stop, this.dataTimeStamp});

  NWFBRouteStops.fromJson(Map<String, dynamic> json) {
    co = json["co"];
    route = json["route"];
    dir = json["dir"];
    seq = json["seq"];
    stop = json["stop"];
    dataTimeStamp = json["data_timestamp"];
  }

  Map<String, dynamic> toJson() => {
    "co": co,
    "route": route,
    "dir": dir,
    "seq": seq,
    "stop": stop,
    "data_timestamp": dataTimeStamp,
  };

}
