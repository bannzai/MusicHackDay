//
//  ViewController.swift
//
import UIKit
import AVFoundation
import AVKit

///////////////////////////////////////////////////////////////////////////////////////////////
class AVAudioPlayerUtil {
    
    var audioPlayer:AVAudioPlayer = AVAudioPlayer();
    var sound_data:NSURL = NSURL();
    var isPlaying = 0;
    
    func setValue(nsurl:NSURL){
        self.sound_data = nsurl;
        self.audioPlayer = try! AVAudioPlayer(contentsOfURL: self.sound_data);
        self.audioPlayer.prepareToPlay();
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
///////////////////////////////////////////////////////////////////////////////////////////////

class ViewController: UIViewController,NSURLSessionDownloadDelegate {
//ymiya[
// - local test
//    var player:AVAudioPlayer!
//    var player2:AVAudioPlayer!
//    let url = NSBundle.mainBundle().bundleURL.URLByAppendingPathComponent("sample_sound.mp3")
//    let url2 = NSBundle.mainBundle().bundleURL.URLByAppendingPathComponent("sample_sound2.mp3")
//ymiya]
    
    var mPlayerA:AVAudioPlayerUtil!;
    var mPlayerB:AVAudioPlayerUtil!;
    var mPlayerSel = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad();
//ymiya[
// - local test
//      do {
//          try player = AVAudioPlayer(contentsOfURL:url)
//          try player2 = AVAudioPlayer(contentsOfURL:url2)
//
//          //音楽をバッファに読み込んでおく
//          player.prepareToPlay()
//          player2.prepareToPlay()
//      } catch {
//          print(error)
//       }
//ymiya]
        
        mPlayerA = AVAudioPlayerUtil();
        mPlayerB = AVAudioPlayerUtil();
    }
    
 //   @IBAction func changeVolume(sender: UISlider) {
 //       let test = sender.value
 //   }
    
    @IBAction func changeVolume(sender: UISlider) {
        let vol = sender.value;
        mPlayerA.changeVolume(vol);
        mPlayerB.changeVolume(1.0-vol);
    }
    
    // player 1
    @IBAction func pushButton1(sender: UIButton) {
        mPlayerSel = 0;
        
        // 通信のコンフィグを用意
        let myConfig:NSURLSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("backgroundSession");
        
        // Sessionを作成する
        let mySession:NSURLSession = NSURLSession(
            configuration: myConfig,
            delegate: self,
            delegateQueue: nil);
        
        // ダウンロード先のURLからリクエストを生成
        let myURL:NSURL = NSURL(string: "https://maoudamashii.jokersounds.com/music/bgm/mp3/bgm_maoudamashii_orchestra26.mp3")!;
        let myRequest:NSURLRequest = NSURLRequest(URL: myURL);
        
        // ダウンロードタスクを生成
        let myTask:NSURLSessionDownloadTask = mySession.downloadTaskWithRequest(myRequest);
        
        // タスクを実行
        myTask.resume();
    }
    
    //再生ボタン2押下時の呼び出しメソッド
    @IBAction func pushButton2(sender: UIButton) {
        mPlayerSel = 1;
        // 通信のコンフィグを用意
        let myConfig:NSURLSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("backgroundSession");
        
        // Sessionを作成する
        let mySession:NSURLSession = NSURLSession(
            configuration: myConfig,
            delegate: self,
            delegateQueue: nil);
        
        // ダウンロード先のURLからリクエストを生成
        let myURL:NSURL = NSURL(string: "https://maoudamashii.jokersounds.com/music/bgm/mp3/bgm_maoudamashii_healing17.mp3")!;
        let myRequest:NSURLRequest = NSURLRequest(URL: myURL);
        
        // ダウンロードタスクを生成
        let myTask:NSURLSessionDownloadTask = mySession.downloadTaskWithRequest(myRequest);
        
        // タスクを実行
        myTask.resume();
    }
    
    /*
     ダウンロード終了時に呼び出されるデリゲート
     */
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        if (mPlayerSel==0) {
            mPlayerA.setValue(location);
            if (mPlayerA.isPlaying == 1) {
                mPlayerA.stop();
            } else {
                mPlayerA.play();
            }
        } else {
            mPlayerB.setValue(location);
            if (mPlayerB.isPlaying == 1) {
                mPlayerB.stop();
            } else {
                mPlayerB.play();
            }
        }
    }
    
    /*
     タスク終了時に呼び出されるデリゲート
     */
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
        // Dispose of any resources that can be recreated.
    }
}

