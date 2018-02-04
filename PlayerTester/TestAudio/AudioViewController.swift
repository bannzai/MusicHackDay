//
//  ViewController.swift
//
import UIKit
import AVFoundation
import AVKit

class AVAudioPlayerUtil {
    
    var audioPlayer:AVAudioPlayer!
    var isPlaying = 0;
    
    func setValue(url: URL) {
        var audioError:NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch let error as NSError {
            audioError = error
            audioPlayer = nil
        }
        // エラーが起きたとき
        if let error = audioError {
            print("Error \(error.localizedDescription)")
        }
        self.audioPlayer.prepareToPlay();
    }
    func play() {
        self.audioPlayer.enableRate = true;
        self.audioPlayer.play();
        isPlaying = 1;
    }
    func stop(){
        self.audioPlayer.stop();
        isPlaying = 0;
    }
    func changeVolume(volume : Float) {
        if ( isPlaying == 1 ) {
            self.audioPlayer.volume = volume;
        }
    }
    func changeTempo(tempo : Float) {
        if ( isPlaying == 1 ) {
            self.audioPlayer.rate = tempo;
        }
    }
    func changeTime(time : TimeInterval) {
        if ( isPlaying == 1 ) {
            let duration = self.audioPlayer.duration;
            self.audioPlayer.currentTime = duration * time;
        }
    }
}

class AudioViewController: UIViewController, URLSessionDownloadDelegate {
    var mPlayerA: AVAudioPlayerUtil!;
    var mPlayerB: AVAudioPlayerUtil!;
    var mPlayerUrlA : String!;
    var mPlayerUrlB : String!;
    var mPlayerSel = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        mPlayerA = AVAudioPlayerUtil();
        mPlayerB = AVAudioPlayerUtil();
    }
    
    @IBAction func changeVolume(sender: UISlider) {
        let vol = sender.value;
        mPlayerA.changeVolume(volume: vol);
        mPlayerB.changeVolume(volume: 1.0 - vol);
    }
    
    @IBAction func ChangeTime(_ sender: UISlider) {
        let time = Double(sender.value);
        mPlayerA.changeTime(time: time);
    }
    
    @IBAction func ChangeTempoA(_ sender: UISlider) {
        let tempo = sender.value;
        mPlayerA.changeTempo(tempo: tempo);
    }
    
    @IBAction func PushButtonA(_ sender: UIButton) {
        mPlayerSel = 0;
        
        // 通信のコンフィグを用意
        let myConfig:URLSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession");
        
        let mySession = URLSession(configuration: myConfig, delegate: self, delegateQueue: nil)
        
        // ダウンロード先のURLからリクエストを生成
//ymiya[
        mPlayerUrlA = "https://maoudamashii.jokersounds.com/music/bgm/mp3/bgm_maoudamashii_orchestra26.mp3"
//ymiya]
        let myURL:URL = URL(string: mPlayerUrlA)!;
        let myRequest:URLRequest = URLRequest(url: myURL);
        
        // ダウンロードタスクを生成
        let myTask:URLSessionDownloadTask = mySession.downloadTask(with: myRequest)
        
        // タスクを実行
        myTask.resume();
    
    }
    
    @IBAction func pushButtonB(_ sender: UIButton) {
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
//ymiya[
        mPlayerUrlB = "https://maoudamashii.jokersounds.com/music/bgm/mp3/bgm_maoudamashii_healing17.mp3"
//ymiya]
        
        let myURL:URL = URL(string: mPlayerUrlB)!;
        let myRequest:URLRequest = URLRequest(url: myURL);
        
        // ダウンロードタスクを生成
        let myTask:URLSessionDownloadTask = mySession.downloadTask(with: myRequest)
        
        // タスクを実行
        myTask.resume();
    }
    
    func setUrlA(url: String) {
        mPlayerUrlA = url;

    }
    
    func setUrlB(url: String) {
        mPlayerUrlB = url;
    }
    
    /*
     ダウンロード終了時に呼び出されるデリゲート
    */
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if (mPlayerSel==0) {
            mPlayerA.setValue(url: location)
            if (mPlayerA.isPlaying == 1) {
                mPlayerA.stop();
            } else {
                mPlayerA.play();
            }
        } else {
            mPlayerB.setValue(url: location)
            if (mPlayerB.isPlaying == 1) {
                mPlayerB.stop();
            } else {
                mPlayerB.play();
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
        // Dispose of any resources that can be recreated.
    }
}

