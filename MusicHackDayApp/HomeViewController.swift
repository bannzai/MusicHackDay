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

class HomeViewController: UIViewController {
    
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
    
    let ownPlayer: AudioPlayerUtil = AudioPlayerUtil()
    let partnerPlayer: AudioPlayerUtil! = AudioPlayerUtil()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ownArtistNameLabel.text = ""
        ownSoundNameLabel.text = ""
        
        partnerSoundNameLabel.text = ""
        partnerArtistNameLabel.text = ""
        
        setupLocation()
        requestAuthorized()
        startFetchLocation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        timer.fire()
        nearistAPITimer.fire()
    }
    
    @IBAction func ownButtonPressed(_ sender: Any) {
        let partnerImageView = PartnerImageView(image: UIImage(named: "sub_btn")!)
        let fakeLocation = CLLocation(latitude: 10, longitude: 10)
        appendNeighbour(imageView: partnerImageView, ownLocation: fakeLocation, lat: 20, lon: 20)
        
//        let url = "https://cdn.fbsbx.com/v/t59.3654-21/27020458_1908094265930315_1875117648384098304_n.m4a/hoge.m4a?oh=cfb1366bc17aa8fb505e96eb59b9a609&oe=5A7871AD&dl=1https://cdn.fbsbx.com/v/t59.3654-21/27020458_1908094265930315_1875117648384098304_n.m4a/hoge.m4a?oh=cfb1366bc17aa8fb505e96eb59b9a609&oe=5A7871AD&dl=1"
//        playSound(mp3URL: url, player: ownPlayer)

//        let viewController = UIStoryboard(name: "SearchViewController", bundle: nil).instantiateInitialViewController() as! SearchViewController
//        viewController.done = { selectedSound in
//            self.selectedSound = selectedSound
//            self.postSound(with: selectedSound.id)
//        }
//        present(viewController, animated: true, completion: nil)
    }
    
    func postSound(with id: Int) {
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            print("necessary token")
            return
        }

        Alamofire
            .request(
                "https://taptappun.net/hackathon/musichackday2018/api/sound/play",
                method: .post,
                parameters: [
                    "user_token": token,
                    "sound_id": id
                ]
            )
            .responseJSON { (response) in
                let json = JSON(response.result.value!)
                let mp3URL = json["sound_file_url"].string ?? "https://maoudamashii.jokersounds.com/music/bgm/mp3/bgm_maoudamashii_orchestra26.mp3"
                self.selectedSound?.mp3URL = mp3URL
                self.configureOwnSound()
                self.playSound(mp3URL: mp3URL, player: self.ownPlayer)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    func configureOwnSound() {
        guard
            let selectedSound = selectedSound
            else {
            return
        }
       
        
        let url = URL(string: selectedSound.imageUrl)!
        Manager.shared.loadImage(with: url, into: ownImageView)
        ownSoundNameLabel.text = selectedSound.name
        ownArtistNameLabel.text = selectedSound.artistName
    }
    
    func playSound(mp3URL: String, player: AudioPlayerUtil) {
        // ダウンロード先のURLからリクエストを生成
        let myURL:URL = URL(string: mp3URL)!;
        let myRequest:URLRequest = URLRequest(url: myURL);
        
        // ダウンロードタスクを生成
        let myTask: URLSessionDownloadTask = URLSession.shared.downloadTask(with: myRequest) { (url, response, error) in
            guard let url = url else {
                return
            }
            
            if !player.isExists(url: url) {
                player.setValue(url: url)
            }
            
            if player.isPlaying == 1 {
                player.stop()
            }
            
            player.play()
        }
        
        // タスクを実行
        myTask.resume();
    }
    
    func resetPartnerImageViews(ownLocation: CLLocation) {
        view.subviews.flatMap { $0 as? PartnerImageView }.forEach { $0.removeFromSuperview() }
        
        let imageViews = neighbours.map { (neighbour) -> PartnerImageView in
            let partnerImageView = PartnerImageView(image: UIImage(named: "sub_btn")!)
            return partnerImageView
        }
        
        zip(imageViews, neighbours).forEach { (imageView, neighbour) in
            
            view.insertSubview(imageView, aboveSubview: backgroundImageView)
            appendNeighbour(imageView: imageView, ownLocation: ownLocation, lat: neighbour.lat, lon: neighbour.lon)
        }
    }
    
    func appendNeighbour(imageView: UIImageView, ownLocation: CLLocation, lat: Double, lon: Double) {
        let distanceX = ((lat - ownLocation.coordinate.latitude) / Double(UIScreen.main.bounds.width)) * Double(ownButton.center.x)
        let distanceY = ((lon - ownLocation.coordinate.longitude) / Double(UIScreen.main.bounds.height)) * Double(ownButton.center.y)
        
        imageView.frame.size = CGSize(width: 60, height: 60)
        imageView.center = CGPoint(x: distanceX, y: distanceY)
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
        guard let location = lastRecognizedLocation else {
            return
        }
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            print("necessary token")
            return
        }
        
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
                
                self.resetPartnerImageViews(ownLocation: location)
        }
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
