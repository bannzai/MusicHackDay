//
//  ViewController.swift
//  MusicHackDayApp
//
//  Created by Yudai.Hirose on 2018/02/03.
//  Copyright © 2018年 廣瀬雄大. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonPressed(_ sender: Any) {
//        let urlSession = URLSession(configuration: .default)
        let url = URL(string: "https://taptappun.net/hackathon/musichackday2018/authentication/signin")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data, let response = response {
                print(response)
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                    print(json)
                } catch {
                    print("Serialize Error")
                }
            } else {
                print(error ?? "Error")
            }
        }
        
        task.resume()
    }
}

