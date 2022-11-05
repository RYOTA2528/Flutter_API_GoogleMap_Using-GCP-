import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
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
  String? errorTxt; //errorハンドリング用に追加

  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('1'),
      position: LatLng(35.32504120390358, 139.55600562500453),
      infoWindow: InfoWindow(title: '鶴岡八幡宮', snippet: '鶴岡八幡宮の場所はこちらです')
    )
  };

  //住所検索用のメソッド
  Future<CameraPosition> searchLatLng(String address) async {
    List<Location> locations = await locationFromAddress(address); //入力された住所から緯度・経度ど取得できる
    return CameraPosition(target: LatLng(locations[0].latitude, locations[0].longitude), zoom: 16); //とってきた値の緯度・経度を格納したものを返り値
  }

  late final CameraPosition currentPosition;
  //現在地を取得するメソッド
  Future<void> getCurrentPosition() async {
    //現在地を取得する許可があるかの確認
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission(); //まだ権限が付与されてない分岐のため付与のrequest
      if(permission == LocationPermission.denied) {
        Future.error('現在地を取得は出来ません。'); //requestを送ってもエラーならerrorメッセージを表示
      }
      final Position _currentPosition = await Geolocator.getCurrentPosition(); //現在地を取得
      currentPosition = CameraPosition(target: LatLng(_currentPosition.latitude, _currentPosition.longitude), zoom: 16); //カメラの位置を記載
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
        child: SafeArea(
          child: Column(
            children: [
                 TextField(
                   decoration: const InputDecoration(
                     border: OutlineInputBorder()
                   ),
                   onSubmitted: (value) async{ //(value)にはこのボタンを押した際TextFiledで入力された情報が入ってくる。
                     try {
                       CameraPosition result = await searchLatLng(value); //value（住所）から取得したカメラポジションをresult変数へ格納
                       _controller.animateCamera(CameraUpdate.newCameraPosition(result)); //これで実際に住所の位置へカメラを移動
                     } catch(e) {
                       print(e);
                       setState(() {
                         errorTxt = '正しい住所を入力してください';
                       });
                     }
                   },
                 ),
              errorTxt == null ? Container() : Text(errorTxt!),
              Expanded(
                child: GoogleMap(
                  markers: _markers,
                  initialCameraPosition: _initialPosition, //初期値の座標
                  onMapCreated: (GoogleMapController controller) async{
                    await getCurrentPosition(); //カメラに位置情報を取得させる（メソッド内で現在地取得にしてる）
                    _controller = controller; //Mapが作成されたタイミングでGoogleMapController controllerを入れMapの制御を行えるようにする。
                    setState(() {
                      _markers.add(Marker(
                          markerId: const MarkerId('2'),
                          position: currentPosition.target,
                          infoWindow: const InfoWindow(title: '現在地')
                      ));
                    });
                    //実際にanimateCameraメソッドでカメラの位置を現在地に動かすメソッドを記載。
                    _controller.animateCamera(CameraUpdate.newCameraPosition(currentPosition));
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}
