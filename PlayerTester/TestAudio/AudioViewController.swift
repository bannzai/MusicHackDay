//
//  ViewController.swift
//
import UIKit
import AVFoundation
import AVKit

class AVAVAudioPlayerUtil {
    
    var audioPlayer:AVAudioPlayer!
    
    var engine = AVAudioEngine();
    var player = AVAudioPlayerNode();
    var eq = AVAudioUnitEQ(numberOfBands: 3);
    var timePitch = AVAudioUnitTimePitch();
    var delay = AVAudioUnitDelay();
    var file:AVAudioFile!;
    
    var sampleRate = 44100.0;
    var duration = 0.0;
    var isPlaying = 0;
    
    func initPlayer() {
        let mixer = engine.mainMixerNode;
        eq.bands[0].bypass = false;
        eq.bands[0].filterType = .lowPass;
        eq.bands[0].bandwidth = 1.0;
        eq.bands[0].frequency = 20000.0;
        eq.bands[0].gain = -6.0;
        eq.globalGain = 0.0;
        engine.attach(eq);
        
        timePitch.rate = 1.0;
        delay.delayTime = 0.5;
        delay.feedback = 0;
        delay.wetDryMix = 0;
        engine.attach(timePitch);
        engine.attach(player);
        engine.attach(delay);
    }
    func setValue(url: URL) {
        
        do {
            try file = AVAudioFile(forReading: url);
        } catch {
        }
        
        
        if ((file) != nil) {
            let mixer = engine.mainMixerNode;
            engine.connect(player, to: eq, format: file.processingFormat)
            engine.connect(eq, to: delay, format: file.processingFormat)
            engine.connect(delay, to: timePitch, format: file.processingFormat)
            engine.connect(timePitch, to: mixer, format: file.processingFormat)
            
            player.scheduleFile(file, at: nil, completionHandler: nil)
            try? engine.start()
            sampleRate = file.fileFormat.sampleRate;
            duration = Double(file.length) / sampleRate;
        }
    }
    func play() {
        player.play();
        isPlaying = 1;
    }
    func stop(){
        player.stop();
        isPlaying = 0;
    }
    func changeVolume(volume : Float) {
        if ( isPlaying == 1 ) {
            let mixer = engine.mainMixerNode;
            mixer.outputVolume = volume;
        }
    }
    func changeTempo(tempo : Float) {
        if ( isPlaying == 1 ) {
            timePitch.rate = tempo;
        }
    }
    func changeTime(pos : TimeInterval) {
        if ( isPlaying == 1 ) {
            let time = pos * duration;
            let newsampletime = AVAudioFramePosition(sampleRate * time);
            let length = self.duration - time;
            let framestoplay = AVAudioFrameCount(sampleRate * length)
            player.stop()
            if (framestoplay > 100) {
                player.scheduleSegment(file,
                                       startingFrame: newsampletime,
                                       frameCount: framestoplay,
                                       at: nil,
                                       completionHandler: nil
                )
            }
            player.play()
        }
    }
    func changePan(pan : Float) {
        if ( isPlaying == 1 ) {
            let mixer = engine.mainMixerNode;
            mixer.pan = pan;
        }
    }
    func changeCutoff(freq : Float) {
        eq.bands[0].frequency = freq;
    }
    func changeDelayLevel(level : Float) {
        delay.feedback  = level;
        if ( level > 0 ) {
            delay.wetDryMix = level;
        }
    }
}

class AudioViewController: UIViewController, URLSessionDownloadDelegate {
    var mPlayerA: AVAVAudioPlayerUtil!;
    var mPlayerB: AVAVAudioPlayerUtil!;
    var mPlayerUrlA : String!;
    var mPlayerUrlB : String!;
    var mPlayerSel = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        mPlayerA = AVAVAudioPlayerUtil();
        mPlayerA.initPlayer();
        mPlayerB = AVAVAudioPlayerUtil();
        mPlayerB.initPlayer();
    }
    
    @IBAction func ChangeSelecter(_ sender: UISlider) {
        let vol = sender.value;
        mPlayerA.changeVolume(volume: vol);
        mPlayerB.changeVolume(volume: 1.0 - vol);
    }
    
    @IBAction func changeVolume(sender: UISlider) {
        let vol = sender.value;
        mPlayerA.changeVolume(volume: vol);
        mPlayerB.changeVolume(volume: 1.0 - vol);
    }
    
    @IBAction func ChangeTime(_ sender: UISlider) {
        let pos = Double(sender.value);
        mPlayerA.changeTime(pos: pos);
    }
    
    @IBAction func ChangeTempoA(_ sender: UISlider) {
        let tempo = sender.value;
        mPlayerA.changeTempo(tempo: tempo);
    }
    
    @IBAction func ChangePan(_ sender: UISlider) {
        let pan = sender.value;
        mPlayerA.changePan(pan: pan);
    }
    
    @IBAction func ChangeCutoff(_ sender: UISlider) {
        let cf = sender.value;
        mPlayerA.changeCutoff(freq: cf);
    }
    
    @IBAction func ChangeDelayLevel(_ sender: UISlider) {
        let level = sender.value;
        mPlayerB.changeDelayLevel(level: level);
    }
    
    
    @IBAction func PushButtonA(_ sender: UIButton) {
        mPlayerSel = 0;
        if (mPlayerA.isPlaying == 1) {
            mPlayerA.stop();
            return;
        }
        downloadFile(url:"https://s3-ap-northeast-1.amazonaws.com/taptappun/project/crawler/audios/SEKAINOOWARIRPG.mp3");
    }
    
    @IBAction func pushButtonB(_ sender: UIButton) {
        mPlayerSel = 1;
        if (mPlayerB.isPlaying == 1) {
            mPlayerB.stop();
            return;
        }
        downloadFile(url:"https://s3-ap-northeast-1.amazonaws.com/taptappun/project/crawler/audios/BzUltraSoul.mp3");
    }
    
    func downloadFile(url: String) {
        // 通信のコンフィグを用意
        let myConfig: URLSessionConfiguration = URLSessionConfiguration.background(withIdentifier: url)
        // Sessionを作成する
        let mySession: URLSession = URLSession(
            configuration: myConfig,
            delegate: self,
            delegateQueue: nil
        );
        // url 設定
        let myURL:URL = URL(string: url)!;
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
    
    func play2(with location: URL) {
        mPlayerB.setValue(url: location)
        if (mPlayerB.isPlaying == 1) {
            mPlayerB.stop();
        } else {
            mPlayerB.play();
        }
    }

    func play(with location: URL) {
            mPlayerA.setValue(url: location)
            if (mPlayerA.isPlaying == 1) {
                mPlayerA.stop();
            } else {
                mPlayerA.play();
            }
    }
    
    /*
     ダウンロード終了時に呼び出されるデリゲート
     */
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        DispatchQueue.main.async {
            if session.configuration.identifier == "https://s3-ap-northeast-1.amazonaws.com/taptappun/project/crawler/audios/BzUltraSoul.mp3" {
                print(" ---- A ----")
                self.play2(with: location)
            } else if (session.configuration.identifier == "https://s3-ap-northeast-1.amazonaws.com/taptappun/project/crawler/audios/SEKAINOOWARIRPG.mp3") {
                print(" ---- B ----")
                self.play(with: location)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
        // Dispose of any resources that can be recreated.
    }
}

