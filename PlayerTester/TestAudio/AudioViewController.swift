//
//  ViewController.swift
//
import UIKit
import AVFoundation
import AVKit

class AudioPlayerUtil {
    
    var audioPlayer:AVAudioPlayer = AVAudioPlayer();
    var isPlaying = 0;
    
    func setValue(url: URL){
        self.audioPlayer = try! AVAudioPlayer(contentsOf: url)
        self.audioPlayer.prepareToPlay();
    }
    
    func isExists(url: URL)  -> Bool {
        let value = try? AVAudioPlayer(contentsOf: url)
        return value == nil
    }
    
    func play(){
        self.audioPlayer.volume = 0.3
        self.audioPlayer.play();
        isPlaying = 1;
    }
    func stop(){
        self.audioPlayer.stop();
        isPlaying = 0;
    }
    func changeVolume(volume : Float) {
        self.audioPlayer.volume = volume;
    }
}

class AudioViewController: UIViewController,URLSessionDownloadDelegate {
    var ownPlayer: AudioPlayerUtil!;
    var partnerPlayer: AudioPlayerUtil!;
    var mPlayerSel = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        ownPlayer = AudioPlayerUtil();
        partnerPlayer = AudioPlayerUtil();
    }
    
    @IBAction func changeVolume(sender: UISlider) {
        let vol = sender.value;
        ownPlayer.changeVolume(volume: vol)
        partnerPlayer.changeVolume(volume: vol)
    }
    
    // player 1
    @IBAction func pushButton1(sender: UIButton) {
        mPlayerSel = 0;
        
        // 通信のコンフィグを用意
        let myConfig:URLSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession");
        
        let mySession = URLSession(configuration: myConfig, delegate: self, delegateQueue: nil)
        
        // ダウンロード先のURLからリクエストを生成
        let myURL:URL = URL(string: "https://maoudamashii.jokersounds.com/music/bgm/mp3/bgm_maoudamashii_orchestra26.mp3")!;
        let myRequest:URLRequest = URLRequest(url: myURL);
        
        // ダウンロードタスクを生成
        let myTask:URLSessionDownloadTask = mySession.downloadTask(with: myRequest)
        
        // タスクを実行
        myTask.resume();
    }
    
    //再生ボタン2押下時の呼び出しメソッド
    @IBAction func pushButton2(sender: UIButton) {
        mPlayerSel = 1;
        // 通信のコンフィグを用意
        
        let myConfig: URLSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        
        // Sessionを作成する
        let mySession: URLSession = URLSession(
            configuration: myConfig,
            delegate: self,
            delegateQueue: nil
        );
        
        
        
        // ダウンロード先のURLからリクエストを生成
        let myURL:URL = URL(string: "https://maoudamashii.jokersounds.com/music/bgm/mp3/bgm_maoudamashii_healing17.mp3")!;
        let myRequest:URLRequest = URLRequest(url: myURL);
        
        // ダウンロードタスクを生成
        let myTask:URLSessionDownloadTask = mySession.downloadTask(with: myRequest)
        
        // タスクを実行
        myTask.resume();
    }
    
    /*
     ダウンロード終了時に呼び出されるデリゲート
     */
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if (mPlayerSel==0) {
            ownPlayer.setValue(url: location)
            if (ownPlayer.isPlaying == 1) {
                ownPlayer.stop();
            } else {
                ownPlayer.play();
            }
        } else {
            partnerPlayer.setValue(url: location)
            if (partnerPlayer.isPlaying == 1) {
                partnerPlayer.stop();
            } else {
                partnerPlayer.play();
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
        // Dispose of any resources that can be recreated.
    }
}

