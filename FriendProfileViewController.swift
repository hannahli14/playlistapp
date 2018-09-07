//
//  FriendProfileViewController.swift
//  DataPractice
//
//  Created by Hannah Li on 8/6/18.
//  Copyright © 2018 Hannah Li. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class FriendProfileViewController: UIViewController{
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var followingsButton: UIButton!
    @IBOutlet weak var followStatusButton: UIButton!
    @IBOutlet weak var privateAccountView: UIView!
    
    var getUserID:String = ""
    var currentPageID:String!
    var getUser: String = "janevillanueva"
    var currentItem: String = ""
    var getImage: UIImage!
    var currentImage: UIImage!
    var followerCount:Int = 0
    var followingCount:Int = 0
    var followerVC: FollowersViewController? = nil
    var followingVC: FollowingsViewController? = nil
    var databaseRef = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentItem = getUser
        currentImage = getImage
        currentPageID = getUserID
        print("Current Item: \(currentItem)")
        self.navigationController?.navigationBar.isTranslucent = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        profileImage.layer.borderColor = (UIColor.gray).cgColor
        profileImage.layer.borderWidth = 1.0
        profileImage.image = currentImage
        gradientCalled()
        databaseRef.child("users").queryOrdered(byChild: "Username").queryEqual(toValue: currentItem).observe(.value) { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let dict = snap.value as! [String: Any]
                let email = dict["Email"] as! String
                let name = dict["Name"] as! String
                let username = dict["Username"] as! String
                let uid = dict["UID"] as! String
                self.nameLabel.text! = name
                self.usernameLabel.text! = username
            } //end for child in snapshot.children brace
        } //end databaseRef.child function
    } //end viewDidLoad()

    override func viewWillAppear(_ animated: Bool) {
        followStatus()
        print("CURRENT PAGE ID: \(currentPageID!)")
        databaseRef.child("users").child(currentPageID!).child("followers").observe(.value) { (snapshot) in
            self.followerCount = Int(snapshot.childrenCount)
            self.followButtonCalled(button: self.followersButton, text: "\(self.followerCount)\nFollowers" as NSString)
        }
        databaseRef.child("users").child(currentPageID!).child("following").observe(.value) { (snapshot) in
            self.followingCount = Int(snapshot.childrenCount)
            self.followButtonCalled(button: self.followingsButton, text: "\(self.followingCount)\nFollowing" as NSString)
        }
    }
    
    @IBAction func statusButtonPressed(_ sender: Any) {
        let ref1 = databaseRef.child("users").child((Auth.auth().currentUser?.uid)!).child("following")
        let ref2 = databaseRef.child("users").child(currentPageID!).child("followers")
        if followStatusButton.backgroundColor == UIColor.white {
            followStatusButton.backgroundColor = UIColor.darkGray
            followStatusButton.tintColor = UIColor.white
            followStatusButton.setTitle("Follow", for: .normal)
            ref1.child("Following \(currentPageID!)").removeValue()
            ref2.child("Follows \((Auth.auth().currentUser?.uid)!)").removeValue()
        } else if followStatusButton.backgroundColor == UIColor.darkGray {
            followStatusButton.backgroundColor = UIColor.white
            followStatusButton.tintColor = UIColor.darkGray
            followStatusButton.setTitle("Following", for: .normal)
            ref1.updateChildValues(["Following \(currentPageID!)" : currentPageID!])
            ref2.updateChildValues(["Follows \((Auth.auth().currentUser?.uid)!)" : (Auth.auth().currentUser?.uid)!])
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is FollowersViewController {
            print("2")
            followerVC = segue.destination as? FollowersViewController
            followerVC?.getUserID = getUserID
        } else if segue.destination is FollowingsViewController {
            followingVC = segue.destination as? FollowingsViewController
            followingVC?.getUserID = getUserID
        }
    }

    ////////////////////DESIGN FUNCTIONS/////////////////////////

    func gradientCalled() {
        let topColor = UIColor(red: (255/255), green: (147/255), blue: (0/255), alpha: 1)
        let bottomColor = UIColor(red: (255/255), green: (255/255), blue: (255/255), alpha: 1)
        let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        let gradientLocation: [Float] = [0.0, 0.26]
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocation as [NSNumber]
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func followStatus(){
        followStatusButton.layer.cornerRadius = followStatusButton.frame.height / 2
        followStatusButton.layer.borderWidth = 1.0
        followStatusButton.clipsToBounds = true
        databaseRef.child("users").child(currentPageID!).child("followers").observe(.value) { (snapshot) in
            if(snapshot.hasChild("Follows \((Auth.auth().currentUser?.uid)!)")){
                self.followStatusButton.backgroundColor = UIColor.white
                self.followStatusButton.tintColor = UIColor.darkGray
                self.followStatusButton.setTitle("Following", for: .normal)
            } else {
                self.followStatusButton.backgroundColor = UIColor.darkGray
                self.followStatusButton.tintColor = UIColor.white
                self.followStatusButton.setTitle("Follow", for: .normal)
            }
        }
    }
    
    func followButtonCalled(button: UIButton!, text: NSString){
        button?.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        let buttonText: NSString = text
        let newlineRange: NSRange = buttonText.range(of: "\n")
        var substring1: NSString = ""
        var substring2: NSString = ""
        if(newlineRange.location != NSNotFound) {
            substring1 = buttonText.substring(to: newlineRange.location) as NSString
            substring2 = buttonText.substring(from: newlineRange.location) as NSString
        }
        var font:UIFont? = UIFont(name: "Helvetica Neue", size: 16)
        font = .boldSystemFont(ofSize: 16)
        let attrString = NSMutableAttributedString(string: (substring1 as String), attributes: ((NSDictionary(object: font!, forKey: NSAttributedStringKey.font as NSCopying) as! [NSAttributedStringKey : Any])))
        attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black, range: NSMakeRange(0, attrString.length))
        let font1:UIFont? = UIFont(name: "Helvetica Neue", size: 11)
        let attrString1 = NSMutableAttributedString(string: (substring2 as String), attributes: ((NSDictionary(object: font1!, forKey: NSAttributedStringKey.font as NSCopying) as! [NSAttributedStringKey: Any])))
        attrString1.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.gray, range: NSMakeRange(0, attrString1.length))
        attrString.append(attrString1)
        button?.setAttributedTitle(attrString, for: UIControlState.normal)
        button?.titleLabel?.textAlignment = NSTextAlignment.center
    }
}
