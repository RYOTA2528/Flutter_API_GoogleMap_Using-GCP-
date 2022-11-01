import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _controller; //GoogleMapController controllerを格納するための変数
  //初期値(最初の座標)
  static const CameraPosition _initialPosition = CameraPosition(
      target: LatLng(35.32504120390358, 139.55600562500453),
      zoom: 16
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: _initialPosition, //初期値の座標
        onMapCreated: (GoogleMapController controller) {
          _controller = controller; //Mapが作成されたタイミングでGoogleMapController controllerを入れMapの制御を行えるようにする。
        },
      )
    );
  }
}
