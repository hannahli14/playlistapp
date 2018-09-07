//
//  SettingsViewController.swift
//  DataPractice
//
//  Created by Hannah Li on 8/23/18.
//  Copyright © 2018 Hannah Li. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class AccountCell: UITableViewCell {
    @IBOutlet weak var privateAccountSwitch: UISwitch!
    let ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!)
    
    @IBAction func privateAccountSwitched(_ sender: Any) {
        if(privateAccountSwitch.isOn == true){
            print("private account")
            ref.updateChildValues([
                "Private Account" : true])
        } else {
            print("public account")
            ref.updateChildValues([
                "Private Account" : false])
        }
    }
}

class StreamCell: UITableViewCell {
    @IBOutlet weak var musicIcon: UIImageView!
    @IBOutlet weak var musicLabel: UILabel!
}

class ConnectCell: UITableViewCell {
    @IBOutlet weak var socialIcon: UIImageView!
    @IBOutlet weak var socialLabel: UILabel!
    
}

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var myAccountTV: UITableView!
    @IBOutlet weak var streamingTV: UITableView!
    @IBOutlet weak var connectTV: UITableView!
    var providers = ["Apple Music", "Spotify"] //add soundcloud and youtube later
    var musicIcons = [#imageLiteral(resourceName: "Apple_Music.png"), #imageLiteral(resourceName: "Spotify.png")]
    var connect = ["Facebook", "Instagram", "Snapchat", "Twitter"]
    var connectIcons = [#imageLiteral(resourceName: "Facebook.png"), #imageLiteral(resourceName: "Instagram.png"), #imageLiteral(resourceName: "Snapchat.png"), #imageLiteral(resourceName: "Twitter.png")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myAccountTV.dataSource = self
        self.myAccountTV.delegate = self
        self.streamingTV.dataSource = self
        self.streamingTV.delegate = self
        self.connectTV.dataSource = self
        self.connectTV.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == myAccountTV){
            return 2
        } else if(tableView == streamingTV){
            return providers.count
        } else{
            return connect.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == myAccountTV){
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "savedPosts") as! AccountCell
                //small arrow at the right end of the cell
                cell.accessoryType = .disclosureIndicator
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "privateAccount") as! AccountCell
                return cell
            }
        }
        else if(tableView == streamingTV){
            let cell = tableView.dequeueReusableCell(withIdentifier: "streamCell", for: indexPath) as! StreamCell
            cell.musicLabel.text = providers[indexPath.row]
            cell.musicIcon.image = musicIcons[indexPath.row]
            return cell
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "connectCell", for: indexPath) as! ConnectCell
            cell.socialLabel.text = connect[indexPath.row]
            cell.socialIcon.image = connectIcons[indexPath.row]
            return cell
        }
    }
    
    @IBAction func signOutPressed(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("Signed out!")
            performSegue(withIdentifier: "unwindToVC1", sender: self)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
