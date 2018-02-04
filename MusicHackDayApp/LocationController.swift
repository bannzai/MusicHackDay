import UIKit
import MapKit
import CoreLocation
import Alamofire
import Foundation
import SwiftyJSON

class LOcationController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet weak var testMapView: MKMapView!
    
    struct neighbour {
        var artist_name: String
        var sound_url: String
        var sound_name: String
        var distance: Int
        var lat: Double
        var lon: Double
        var user_token: String
        
        init(artist_name: String,
             sound_url: String,
             sound_name: String,
             distance: Int,
             lat: Double,
             lon: Double,
             user_token: String) {
            self.artist_name = artist_name
            self.sound_url = sound_url
            self.sound_name = sound_name
            self.distance = distance
            self.lat = lat
            self.lon = lon
            self.user_token = user_token
        }
    }
    //CLLocationManagerの入れ物を用意
    var myLocationManager:CLLocationManager!
    var locationManager : CLLocationManager!
    var sendPotisionURL = "https://taptappun.net/hackathon/musichackday2018/api/location/notify"
    var annotationArray: [MKAnnotation] = []
    var neighbours = [neighbour]()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //CLLocationManagerをインスタンス化
        //myLocationManager = CLLocationManager()
        //位置情報使用許可のリクエストを表示するメソッドの呼び出し
        //myLocationManager.requestWhenInUseAuthorization()
        
        //getArticles()
        
        locationManager = CLLocationManager.init()
        locationManager.allowsBackgroundLocationUpdates = true; // バックグランドモードで使用する場合YESにする必要がある
        locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 位置情報取得の精度
        locationManager.distanceFilter = 3; // 位置情報取得する間隔、1m単位とする
        locationManager.delegate = self as? CLLocationManagerDelegate;
        
        // 位置情報の認証チェック
        let status = CLLocationManager.authorizationStatus()
        if (status == .notDetermined) {
            print("許可、不許可を選択してない");
            // 常に許可するように求める
            locationManager.requestAlwaysAuthorization();
        }
        else if (status == .restricted) {
            print("機能制限している");
        }
        else if (status == .denied) {
            print("許可していない");
        }
        else if (status == .authorizedWhenInUse) {
            print("このアプリ使用中のみ許可している");
            locationManager.startUpdatingLocation();
        }
        else if (status == .authorizedAlways) {
            print("常に許可している");
            locationManager.startUpdatingLocation();
        }
        
    }
    
    //位置情報取得に失敗したときに呼び出されるメソッド
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }
    
    // 位置情報が取得されると呼ばれる
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 最新の位置情報を取得 locationsに配列で入っている位置情報の最後が最新となる
        let location : CLLocation = locations.last!;
        print("位置取得したよ！")
        print(location)
        
        //
        //        for coordinate in coordinateArray! {
        //            　　　　　　　　let annotation = MKPointAnnotation()
        //            annotation.coordinate = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        //            annotationArray.append(annotation)
        //        }
        //        self.mapView.addAnnotations(annotationArray)
        //
        //
        
        //        let str = """
        //            [{id:"12345678",latitude":"35.659867","longitude":"139.705381"},{id:"2345678",latitude":"35.659367","longitude":"139.705181"}]
        //        """
        //
        //        struct coordinateArray: Codable {
        //            var id: String
        //            var latitude: String
        //            var longitude: String
        //        }
        //
        //        do{
        //            let location = try JSONDecoder().decode([coordinateArray].self, from: str.data(using: .utf8)!)
        //
        //            for coordinateArray in location {
        //                let id = coordinateArray.id
        //                let latitude = coordinateArray.latitude
        //                let longitude = coordinateArray.longitude
        //
        //                print("\(id) (\(latitude)) (\(longitude))")
        //            }
        //        }catch{
        //            for symbol in Thread.callStackSymbols {
        //                print(symbol)
        //            }
        //        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(35.659867, 139.705381)
        self.testMapView.addAnnotation(annotation)
        
        // HTTP body: {"foo": [1, 2, 3], "bar": {"baz": "qux"}}
        //horizontalAccuracyが負の場合は、経度、緯度は有効でない。
        if(location.horizontalAccuracy > 0){
            let headers: HTTPHeaders = [
                "name": "value"
            ]
            let parameters: Parameters = [
                "user_token": "aaaa",
                "lat": location.coordinate.latitude,
                "lon": location.coordinate.longitude
            ]
            
            Alamofire.request(sendPotisionURL,
                              method: .post,
                              parameters: parameters)
                .responseJSON { response in
                    let json = JSON(response.result.value)
                    print(json)
                    self.neighbours = [neighbour]()
                    json["neighbours"].forEach{(_, data) in
                        //                        print(data["artist_name"].string!)
                        //                        print(data["sound_url"].string!)
                        //                        print(data["sound_name"].string!)
                        //                        print(data["distance"].int!)
                        //                        print(data["lat"].double!)
                        //                        print(data["lon"].double!)
                        //                        print(data["user_token"].string!)
                        
                        
                        self.neighbours.append(neighbour(artist_name: data["artist_name"].string!, sound_url: data["sound_url"].string!, sound_name: data["sound_name"].string!, distance: data["distance"].int!, lat: data["lat"].double!, lon: data["lon"].double!, user_token: data["user_token"].string!))
                        //                        let type = data["distance"]
                        //                        print(type) // foo or bar
                    }
                    
                    
                    for neighbour in self.neighbours {
                        print("artist_name" + neighbour.artist_name + ":user_token" + neighbour.user_token)
                    }
                    //                    if
                    //                        let json = response.result.value as? [String: Any],
                    //                        let neighbours = json["neighbours"] as? String
                    //                    {
                    //                        debugPrint(neighbours)
                    //                    }
                    //                    debugPrint(response)
            }
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .restricted) {
            print("機能制限している");
        }
        else if (status == .denied) {
            print("許可していない");
        }
        else if (status == .authorizedWhenInUse) {
            print("このアプリ使用中のみ許可している");
            locationManager.startUpdatingLocation();
        }
        else if (status == .authorizedAlways) {
            print("常に許可している");
            locationManager.startUpdatingLocation();
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


