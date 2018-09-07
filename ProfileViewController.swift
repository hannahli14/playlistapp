//
//  HomeViewController.swift
//  DataPractice
//
//  Created by Hannah Li on 7/30/18.
//  Copyright © 2018 Hannah Li. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SDWebImage

class ProfileCell: UITableViewCell {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var songView: UIView!
    @IBOutlet weak var heartButton: UIButton!
    @IBAction func heartPressed(_ sender: Any) {
        if(heartButton.currentImage?.isEqual(UIImage(named: "heart")))! {
            let image = UIImage(named: "heart filled")
            heartButton.setImage(image, for: .normal)
        } else if(heartButton.currentImage?.isEqual(UIImage(named: "heart filled")))! {
            let image = UIImage(named: "heart")
            heartButton.setImage(image, for: .normal)
        }
    }
    @IBOutlet weak var chatButton: UIButton!
    @IBAction func chatPressed(_ sender: Any) {
    }
    @IBOutlet weak var starButton: UIButton!
    @IBAction func starPressed(_ sender: Any) {
    }
}

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EditProfileDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var followingsButton: UIButton!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var feedTV: UITableView!
    
    var getConfirmPW:String!
    var getEmail:String!
    var getPassword:String!
    var getImage:UIImage!
    var followerCount:Int = 0
    var followingCount:Int = 0
    var posts = [Post]()
    var followerVC: FollowersViewController? = nil
    var followingVC: FollowingsViewController? = nil
    var vc:EditProfileViewController? = nil
    var ref = Database.database().reference()
    let userID = (Auth.auth().currentUser?.uid)!
    
    func sendData(image: UIImage, name: String, handle: String) {
        self.profileImage.image = image
        self.nameLabel.text = name
        self.usernameLabel.text = handle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        profileImage.layer.borderColor = (UIColor.gray).cgColor
        profileImage.layer.borderWidth = 1.0
        editProfile()
        gradientCalled()
        feedTV.delegate = self
        feedTV.dataSource = self
        feedTV.rowHeight = UITableViewAutomaticDimension
        feedTV.estimatedRowHeight = 262
        feedTV.layoutMargins = UIEdgeInsets.zero
        feedTV.separatorInset = UIEdgeInsets.zero
        feedTV.separatorColor = UIColor.darkGray
        ref.child("users").child(userID).observe(.value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let email = value?["Email"] as? String ?? ""
            let name = value?["Name"] as? String ?? ""
            let username = value?["Username"] as? String ?? ""
            let password = value?["Password"] as? String ?? ""
            let confirmPW = value?["Confirm Password"] as? String ?? ""
            self.getConfirmPW = confirmPW
            self.getEmail = email
            self.getPassword = password
            self.nameLabel.text = name
            self.usernameLabel.text = username
        }
        //getting profile picture from Firebase Storage for user
        let reference = Storage.storage().reference(forURL: "gs://data-practice-b6f99.appspot.com")
        let imageName: String = "profileImage\((Auth.auth().currentUser?.uid)!).jpg"
        let imageURL = reference.child(imageName)
        var tempImage: UIImage!
        imageURL.downloadURL { (url, error) in
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error)
                    return
                }
                guard let imageData = UIImage(data: data!) else {return}
                DispatchQueue.main.async {
                    tempImage = imageData
                    self.profileImage.image = self.resizeImage(image: tempImage, targetSize: CGSize(width: 210, height: 210))
                }
            }).resume()
        }
        loadPosts()
    }//end viewDidLoad
    
    func loadPosts() {
        ref.child("posts").queryOrdered(byChild: "user").queryEqual(toValue: userID).observe(.childAdded) { (snapshot) in
            //print(snapshot)
            if let dict = snapshot.value as? [String: Any] {
                let captionText = dict["caption"] as! String
                let userID = dict["user"] as! String
                let timestamp = dict["time"] as! Double
                let username = dict["username"] as! String
                let converted = NSDate(timeIntervalSince1970: timestamp / 1000) as Date
                let newTime = converted.timeAgoDisplay()
                //print("NEW TIME \(newTime)")
                let post = Post(captionText: captionText, userText: userID, timeText: newTime, userLabel: username)
                self.posts.insert(post, at: 0)
                self.feedTV.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ref.child("users").child("\((Auth.auth().currentUser?.uid)!)").child("followers").observe(.value) { (snapshot) in
            self.followerCount = Int(snapshot.childrenCount)
            self.followButtonCalled(button: self.followersButton, text: "\(self.followerCount)\nFollowers" as NSString)
        }
        ref.child("users").child("\((Auth.auth().currentUser?.uid)!)").child("following").observe(.value) { (snapshot) in
            self.followingCount = Int(snapshot.childrenCount)
            self.followButtonCalled(button: self.followingsButton, text: "\(self.followingCount)\nFollowing" as NSString)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell") as! ProfileCell
        
        let reference = Storage.storage().reference(forURL: "gs://data-practice-b6f99.appspot.com")
        let imageName: String = "profileImage\(userID).jpg"
        let imageURL = reference.child(imageName)
        var tempImage: UIImage!
        imageURL.downloadURL { (url, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
                return
            }
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error as Any)
                    return
                }
                guard let imageData = UIImage(data: data!) else {return}
                DispatchQueue.main.async {
                    tempImage = imageData
                    cell.userImage?.image = self.resizeImage(image: tempImage, targetSize: CGSize(width: 100, height: 100))
                }
            }).resume()
        }
        cell.userLabel.text = posts[indexPath.row].username
        cell.userImage.layer.cornerRadius = cell.userImage.frame.size.width/2
        cell.userImage.clipsToBounds = true
        cell.userImage.layer.borderColor = (UIColor.gray).cgColor
        cell.userImage.layer.borderWidth = 0.5
        cell.caption.text = posts[indexPath.row].caption
        cell.timeLabel.text = posts[indexPath.row].timeStamp
        cell.songView.layer.cornerRadius = 12
        cell.songView.layer.borderColor = UIColor(red: 255/255, green: 147/255, blue: 0/255, alpha: 1).cgColor
        cell.songView.layer.borderWidth = 2.0
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }

    @IBAction func editProfilePressed(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is EditProfileViewController {
            let destVC = segue.destination as? EditProfileViewController
            destVC?.delegate = self
        
            vc = segue.destination as? EditProfileViewController
            vc?.getImage = self.profileImage.image!
            vc?.getName = self.nameLabel.text!
            vc?.getEmail = getEmail
            vc?.getPassword = getPassword
            vc?.getConfirmPW = getConfirmPW
            vc?.getUsername = self.usernameLabel.text!
        } else if segue.destination is FollowersViewController {
            print("2")
            followerVC = segue.destination as? FollowersViewController
            followerVC?.getUserID = (Auth.auth().currentUser?.uid)!
        } else if segue.destination is FollowingsViewController {
            followingVC = segue.destination as? FollowingsViewController
            followingVC?.getUserID = (Auth.auth().currentUser?.uid)!
        }
    }
    
    func editProfile() {
        editProfileButton.layer.cornerRadius = editProfileButton.frame.height / 2
        editProfileButton.layer.borderWidth = 1.0
        editProfileButton.backgroundColor = UIColor.clear
        editProfileButton.clipsToBounds = true
        editProfileButton.tintColor = UIColor.darkGray
        editProfileButton.setTitle("Edit Profile", for: .normal)
    }
    
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
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: newSize.width, height: newSize.height))
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
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

extension UIViewController {
    func reloadViewFromNib() {
        let parent = view.superview
        view.removeFromSuperview()
        view = nil
        parent?.addSubview(view) // This line causes the view to be reloaded
    }
}
