//
//  ConnectViewController.swift
//  DataPractice
//
//  Created by Hannah Li on 8/22/18.
//  Copyright © 2018 Hannah Li. All rights reserved.
//

import UIKit

class musicProvider: UITableViewCell {
    @IBOutlet weak var musicIcon: UIImageView!
    @IBOutlet weak var musicLabel: UILabel!
    @IBAction func musicSwitchPressed(_ sender: Any) {
        print("music switch pressed")
    }
}

class socialProvider: UITableViewCell {
    @IBOutlet weak var socialIcon: UIImageView!
    @IBOutlet weak var socialLabel: UILabel!
    @IBAction func socialSwitchPressed(_ sender: Any) {
        print("social switch pressed")
    }
}

class ConnectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var musicTV: UITableView!
    @IBOutlet weak var socialTV: UITableView!
    var providers = ["Apple Music", "Spotify"] //add soundcloud and youtube later
    var socials = ["Facebook", "Instagram", "Snapchat", "Twitter"]
    var musicIcons = [#imageLiteral(resourceName: "Apple_Music.png"), #imageLiteral(resourceName: "Spotify.png")]
    var socialIcons = [#imageLiteral(resourceName: "Facebook.png"), #imageLiteral(resourceName: "Instagram.png"), #imageLiteral(resourceName: "Snapchat.png"), #imageLiteral(resourceName: "Twitter.png")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        musicTV.delegate = self
        musicTV.dataSource = self
        socialTV.delegate = self
        socialTV.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == musicTV){
            return providers.count
        } else{
            return socials.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == musicTV){
            let cell = tableView.dequeueReusableCell(withIdentifier: "musicCell", for: indexPath) as! musicProvider
            cell.musicLabel.text = providers[indexPath.row]
            cell.musicIcon.image = musicIcons[indexPath.row]
            return cell
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "socialCell", for: indexPath) as! socialProvider
            cell.socialLabel.text = socials[indexPath.row]
            cell.socialIcon.image = socialIcons[indexPath.row]
            return cell
        }
    }
    
    @IBAction func donePressed(_ sender: Any) {
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
