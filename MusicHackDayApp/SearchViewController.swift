//
//  SearchViewController.swift
//  MusicHackDayApp
//
//  Created by Yudai.Hirose on 2018/02/04.
//  Copyright © 2018年 廣瀬雄大. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Nuke

class SearchViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    var list: [Sound] = []
    
    var done: ((Sound) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = UIImageView(image: UIImage(named: "search_background")!)
        tableView.separatorStyle = .none
        
        tableView.delegate = self
        tableView.dataSource = self
        
        textField.delegate = self
        textField.returnKeyType = .done

        let nib = UINib(nibName: "SearchTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            print("necessary token")
            return
        }
        let word = textField.text ?? ""
        Alamofire.request(
            "https://taptappun.net/hackathon/musichackday2018/api/sound/search_one",
            method: .get,
            parameters: [
                "token": token,
                "keyword": word
            ])
            .responseJSON { (response) in
                let json = JSON(response.result.value!)
                self.list = json["results"].arrayValue.map({ (json) in
                    return Sound(json: json)
                })
                self.tableView.reloadData()
        }
        
        view.endEditing(true)
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        done?(list[indexPath.row])
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SearchTableViewCell
        
        let sound = list[indexPath.row]
        let url = URL(string: sound.imageUrl)!
        Manager.shared.loadImage(with: url, into: cell.iconImageView)
        cell.soundNameLabel.text = sound.name
        cell.artistNameLabel.text = sound.artistName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }

}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchButtonPressed("")
        textField.resignFirstResponder()
        return true
    }
}
