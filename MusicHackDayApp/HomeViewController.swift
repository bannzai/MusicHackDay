//
//  HomeViewController.swift
//  MusicHackDayApp
//
//  Created by Yudai.Hirose on 2018/02/03.
//  Copyright © 2018年 廣瀬雄大. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

struct Neighbour {
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

class HomeViewController: UIViewController {
    
    @IBOutlet weak var ownButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var locationManager : CLLocationManager!
    var neighbours = [Neighbour]()

    lazy var timer: Timer = {
        return Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(animateForhHamon),
            userInfo: nil,
            repeats: true
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        timer.fire()
        logginLocation()
    }
    
    @IBAction func ownButtonPressed(_ sender: Any) {
        let viewController = UIStoryboard(name: "LocationViewController", bundle: nil).instantiateInitialViewController()!
        navigationController?.pushViewController(viewController, animated: true)
    }
}

private extension HomeViewController {
    @objc func animateForhHamon() {
        let hamon = UIImageView(image: UIImage(named: "hamon")!)
        hamon.frame = ownButton.frame
        
        view.insertSubview(hamon, aboveSubview: backgroundImageView)

        UIView.animate(
            withDuration: 4.0,
            delay: 0,
            options: .curveLinear,
            animations: {
                let scale = 1 / (hamon.bounds.height / UIScreen.main.bounds.height) + 1
                hamon.transform = CGAffineTransform(scaleX: scale, y: scale)
        },
            completion: { (_) in
                hamon.removeFromSuperview()
        })
    }
}


// MARK: - Location
extension HomeViewController {
    func setupLocation() {
        locationManager = CLLocationManager.init()
        locationManager.allowsBackgroundLocationUpdates = true; // バックグランドモードで使用する場合YESにする必要がある
        locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 位置情報取得の精度
        locationManager.distanceFilter = 3; // 位置情報取得する間隔、1m単位とする
        locationManager.delegate = self
    }
    
    func logginLocation() {
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
    
}

extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }
    
    // 位置情報が取得されると呼ばれる
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            print("necessary token")
            return
        }
        // 最新の位置情報を取得 locationsに配列で入っている位置情報の最後が最新となる
        let location : CLLocation = locations.last!;
        
        if(location.horizontalAccuracy > 0){
            let parameters: Parameters = [
                "user_token": token,
                "lat": location.coordinate.latitude,
                "lon": location.coordinate.longitude
            ]
            
            let sendPotisionURL = "https://taptappun.net/hackathon/musichackday2018/api/location/notify"
            Alamofire.request(sendPotisionURL,
                              method: .post,
                              parameters: parameters)
                .responseJSON { response in
                    let json = JSON(response.result.value!)
                    self.neighbours = [Neighbour]()
                    json["neighbours"].forEach{(_, data) in
                        self.neighbours.append(
                            Neighbour(
                                artist_name: data["artist_name"].string!,
                                sound_url: data["sound_url"].string!,
                                sound_name: data["sound_name"].string!,
                                distance: data["distance"].int!,
                                lat: data["lat"].double!,
                                lon: data["lon"].double!,
                                user_token: data["user_token"].string!
                            )
                        )
                    }
                    
                    
                    for neighbour in self.neighbours {
                        print(
                            "artist_name: "
                                + neighbour.artist_name
                                + ", user_token: "
                                + neighbour.user_token
                        )
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
}
