//
//  NotificationViewController.swift
//  DataPractice
//
//  Created by Hannah Li on 8/23/18.
//  Copyright © 2018 Hannah Li. All rights reserved.
//

import UIKit

class NewFollowers: UICollectionViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
}

class NewNotifications: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
}

class NotificationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var newNotificationsTV: UITableView!
    @IBOutlet weak var newFollowersCV: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newFollowersCV.dataSource = self
        newFollowersCV.delegate = self
        newNotificationsTV.dataSource = self
        newNotificationsTV.delegate = self
    }
    
    //TABLEVIEW
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = newNotificationsTV.dequeueReusableCell(withIdentifier: "notificationCell") as! NewNotifications
        self.newNotificationsTV.rowHeight = 53
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width/2
        cell.profileImage.clipsToBounds = true
        cell.profileImage.layer.borderColor = (UIColor.gray).cgColor
        cell.profileImage.layer.borderWidth = 1.0
        return cell
    }
    
    //COLLECTION VIEW
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = newFollowersCV.dequeueReusableCell(withReuseIdentifier: "followersCell", for: indexPath) as! NewFollowers
        cell.nameLabel.text = "Hannah Li"
        cell.usernameLabel.text = "@hannahli"
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width/2
        cell.profileImage.clipsToBounds = true
        cell.profileImage.layer.borderColor = (UIColor.gray).cgColor
        cell.profileImage.layer.borderWidth = 1.0
        return cell
    }
    
}
