// //  ViewController.swift
//  MusicHackDayApp
//
//  Created by Yudai.Hirose on 2018/02/03.
//  Copyright © 2018年 廣瀬雄大. All rights reserved.
//

import UIKit

enum Result {
    case success([String: Any]) // json
    case failure(String) // error message
}

struct API {
    static func request(url: String, completion: @escaping (Result) -> Void) {
        let url = URL(string: url)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let data = data, let response = response {
                    print("response: \(response)")
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] else {
                            completion(.failure("Can't convert json"))
                            return
                        }
                        completion(.success(json))
                        print("json: \(json)")
                    } catch {
                        
                        completion(.failure("Serialize Error"))
                    }
                } else {
                    completion(.failure(error?.localizedDescription ?? "Unknown response error"))
                }
            }
        }
        task.resume()
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        API.request(url:  "https://taptappun.net/hackathon/musichackday2018/authentication/signin") { (result) in
            switch result {
            case .success(_):
                let viewController = UIStoryboard(name: "HomeViewController", bundle: nil).instantiateInitialViewController()!
                self.navigationController?.pushViewController(viewController, animated: true)
            case .failure(let errorMessage):
                print("error: \(errorMessage)")
            }
        }
    }
}

