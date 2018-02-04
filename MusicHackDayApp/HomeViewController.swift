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
import Nuke
import AVFoundation

class HomeViewController: AudioViewController {
    
    @IBOutlet weak var ownButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var locationManager : CLLocationManager!
    var neighbours = [Neighbour]()
    var lastRecognizedLocation : CLLocation?
    
    var selectedSound: Sound?

    @IBOutlet weak var ownSoundNameLabel: UILabel!
    @IBOutlet weak var ownArtistNameLabel: UILabel!
    @IBOutlet weak var ownImageView: UIImageView!

    @IBOutlet weak var partnerSoundNameLabel: UILabel!
    @IBOutlet weak var partnerArtistNameLabel: UILabel!

    lazy var timer: Timer = {
        return Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(animateForhHamon),
            userInfo: nil,
            repeats: true
        )
    }()
    
    lazy var nearistAPITimer: Timer = {
        return Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(callLocationAPI),
            userInfo: nil,
            repeats: true
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ownArtistNameLabel.text = ""
        ownSoundNameLabel.text = ""
        
        partnerSoundNameLabel.text = ""
        partnerArtistNameLabel.text = ""
        
        ownImageView.layer.cornerRadius = 4
        
        setupLocation()
        requestAuthorized()
        startFetchLocation()
        
        let partnerImageView = PartnerImageView(image: UIImage(named: "sub_btn")!)
        appendNeighbour(imageView: partnerImageView, lat: 10, lon: 10)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        timer.fire()
    }
    
    @IBAction func ownButtonPressed(_ sender: Any) {
        let viewController = UIStoryboard(name: "SearchViewController", bundle: nil).instantiateInitialViewController() as! SearchViewController
        viewController.done = { selectedSound in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.pushButtonB(UIButton())
                self.configureOwnSound()
            })
            self.PushButtonA(UIButton())
            self.configurePartner()
            self.dismiss(animated: true, completion: nil)
        }
        present(viewController, animated: true, completion: nil)
    }
    
//    func postSound(with id: Int) {
//        guard let token = UserDefaults.standard.string(forKey: "token") else {
//            print("necessary token")
//            return
//        }
//
//        Alamofire
//            .request(
//                "https://taptappun.net/hackathon/musichackday2018/api/sound/play",
//                method: .post,
//                parameters: [
//                    "token": token,
//                    "sound_id": id
//                ]
//            )
//            .responseJSON { (response) in
//                let json = JSON(response.result.value!)
//                self.configureOwnSound()
//        }
//
//    }
    
    func configurePartner() {
        partnerSoundNameLabel.text = "Sekai no owari"
        partnerArtistNameLabel.text = "RPG"
    }

    func configureOwnSound() {
        let url = URL(string: "https://img.youtube.com/vi/Ujb-ZeX7Mo8/default.jpg")!
        Manager.shared.loadImage(with: url, into: ownImageView)
        ownSoundNameLabel.text = "Ultra Soul!"
        ownArtistNameLabel.text = "B'z"
    }
    
//    func playSound(mp3URL: String, player: AVAVAudioPlayerUtil) {
//        // ダウンロード先のURLからリクエストを生成
//        let myURL:URL = URL(string: mp3URL)!;
//        let myRequest:URLRequest = URLRequest(url: myURL);
//
//        // ダウンロードタスクを生成
//        let myTask: URLSessionDownloadTask = URLSession.shared.downloadTask(with: myRequest) { (location, response, error) in
//            DispatchQueue.main.async {
//                guard let location = location else {
//                    return
//                }
//
//                let audioUrl = myURL
//                let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//
//                let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
//                print(destinationUrl)
//
//                player.setValue(url: location)
//                player.play()
//            }
//        }
//
//        // タスクを実行
//        myTask.resume();
//    }
    
    func resetPartnerImageViews() {
        view.subviews.flatMap { $0 as? PartnerImageView }.forEach { $0.removeFromSuperview() }
        
        let imageViews = neighbours.map { (neighbour) -> PartnerImageView in
            let partnerImageView = PartnerImageView(image: UIImage(named: "sub_btn")!)
            return partnerImageView
        }
        
        zip(imageViews, neighbours).forEach { (imageView, neighbour) in
            view.insertSubview(imageView, aboveSubview: backgroundImageView)
            appendNeighbour(imageView: imageView, lat: neighbour.lat, lon: neighbour.lon)
        }
    }
    
    func appendNeighbour(imageView: UIImageView,  lat: Double, lon: Double) {
        view.insertSubview(imageView, aboveSubview: backgroundImageView)
        imageView.frame.size = CGSize(width: 60, height: 60)
        let x = UIScreen.main.bounds.width - 120
        let y = CGFloat(100)
        imageView.center = CGPoint(x: x, y: y)
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
    
    func requestAuthorized() {
        // 位置情報の認証チェック
        let status = CLLocationManager.authorizationStatus()
        if status != .notDetermined {
            return
        }
        
        locationManager.requestAlwaysAuthorization();
    }
    
    func startFetchLocation() {
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation();
        }
    }
    
    @objc func callLocationAPI() {
//        guard let location = lastRecognizedLocation else {
//            return
//        }
//
//        guard let token = UserDefaults.standard.string(forKey: "token") else {
//            print("necessary token")
//            return
//        }
//
//        let parameters: Parameters = [
//            "token": token,
//            "lat": location.coordinate.latitude,
//            "lon": location.coordinate.longitude
//        ]
//
//        let sendPotisionURL = "https://taptappun.net/hackathon/musichackday2018/api/location/notify"
//        Alamofire.request(sendPotisionURL,
//                          method: .post,
//                          parameters: parameters)
//            .responseJSON { response in
//                guard let value = response.result.value else {
//                    return
//                }
//                let json = JSON(value)
//                self.neighbours = [Neighbour]()
//                json["neighbours"].forEach{(_, data) in
//                    self.neighbours.append(
//                        Neighbour(
//                            artist_name: data["artist_name"].string!,
//                            sound_url: data["sound_url"].string!,
//                            sound_name: data["sound_name"].string!,
//                            distance: data["distance"].int!,
//                            lat: data["lat"].double!,
//                            lon: data["lon"].double!,
//                            token: data["user_token"].string!
//                        )
//                    )
//                }
//
//                for neighbour in self.neighbours {
//                    print(
//                        "artist_name: "
//                            + neighbour.artist_name
//                            + ", token: "
//                            + neighbour.token
//                    )
//                }
//
//        }
                self.resetPartnerImageViews()
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }
    
    // 位置情報が取得されると呼ばれる
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 最新の位置情報を取得 locationsに配列で入っている位置情報の最後が最新となる
        lastRecognizedLocation = locations.last!;
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
