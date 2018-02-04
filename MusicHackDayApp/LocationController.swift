import UIKit
import MapKit
import CoreLocation
import Alamofire
import Foundation
import SwiftyJSON

class LocationController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet weak var testMapView: MKMapView!
    
    struct neighbour {
        var artist_name: String
        var sound_url: String
        var sound_name: String
        var distance: Int
        var lat: Double
        var lon: Double
        var token: String
        
        init(artist_name: String,
             sound_url: String,
             sound_name: String,
             distance: Int,
             lat: Double,
             lon: Double,
             token: String) {
            self.artist_name = artist_name
            self.sound_url = sound_url
            self.sound_name = sound_name
            self.distance = distance
            self.lat = lat
            self.lon = lon
            self.token = token
        }
    }
    //CLLocationManagerの入れ物を用意
    var locationManager : CLLocationManager!
    var sendPotisionURL = "https://taptappun.net/hackathon/musichackday2018/api/location/notify"
    var annotationArray: [MKAnnotation] = []
    var neighbours = [neighbour]()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        locationManager = CLLocationManager.init()
        locationManager.allowsBackgroundLocationUpdates = true; // バックグランドモードで使用する場合YESにする必要がある
        locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 位置情報取得の精度
        locationManager.distanceFilter = 3; // 位置情報取得する間隔、1m単位とする
        locationManager.delegate = self
        
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

        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(35.659867, 139.705381)
        self.testMapView.addAnnotation(annotation)
        
        if(location.horizontalAccuracy > 0){
//            let headers: HTTPHeaders = [
//                "name": "value"
//            ]
            let parameters: Parameters = [
                "token": "aaaa",
                "lat": location.coordinate.latitude,
                "lon": location.coordinate.longitude
            ]
            
            Alamofire.request(sendPotisionURL,
                              method: .post,
                              parameters: parameters)
                .responseJSON { response in
                    let json = JSON(response.result.value!)
                    print(json)
                    self.neighbours = [neighbour]()
                    json["neighbours"].forEach{(_, data) in

                        
                        self.neighbours.append(
                            neighbour(
                                artist_name: data["artist_name"].string!,
                                      sound_url: data["sound_url"].string!,
                                      sound_name: data["sound_name"].string!,
                                      distance: data["distance"].int!,
                                      lat: data["lat"].double!,
                                      lon: data["lon"].double!,
                                      token: data["token"].string!
                            )
                        )
                    }
                    
                    
                    for neighbour in self.neighbours {
                        print("artist_name" + neighbour.artist_name + ":token" + neighbour.token)
                    }
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


