//
//  segueViewController.swift
//  DataPractice
//
//  Created by Hannah Li on 7/31/18.
//  Copyright © 2018 Hannah Li. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class postCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
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

class Post {
    var caption:String!
    var user:String!
    var timeStamp:String!
    let formatter = DateFormatter()
    init(captionText:String, userText:String, timeText:String){
        caption = captionText
        user = userText
        timeStamp = timeText
    }
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
 
    @IBOutlet weak var playlistLabel: UILabel!
    @IBOutlet weak var newPostButton: UIButton!
    @IBOutlet weak var feedTV: UITableView!
    @IBOutlet weak var hideFeedView: UIView!
    var refresher: UIRefreshControl!
    var activityIndicator:UIActivityIndicatorView!
    var userIDArray = [String]()
    var posts = [Post]()
    var currentUser = Auth.auth().currentUser?.uid
    let databaseRef = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        //self.navigationController?.navigationBar.shadowImage = UIImage()
        //self.navigationController?.navigationBar.isTranslucent = true
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString()
        refresher.addTarget(self, action: #selector(HomeViewController.reloadPage), for: UIControlEvents.valueChanged)
        feedTV.addSubview(refresher)
        feedTV.dataSource = self
        feedTV.delegate = self
        feedTV.rowHeight = UITableViewAutomaticDimension
        feedTV.estimatedRowHeight = 262
        feedTV.layoutMargins = UIEdgeInsets.zero
        feedTV.separatorInset = UIEdgeInsets.zero
        feedTV.separatorColor = UIColor.darkGray
        playlistLabel.isHidden = false
        newPostButton.isHidden = false
        if(Auth.auth().currentUser != nil){
            databaseRef.child("users").child(currentUser!).child("following").observe(.value) { (snapshot) in
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    let value = snap.value
                    self.userIDArray.append(value as! String)
                }
            }
            perform(#selector(loadPosts), with: nil, afterDelay: 1)
        }
    }

    /*func updateState(user: String){
        print("User \(user)")
        var i=0
        while(user != userIDArray[i]){
            i = i+1
        }
        userIDArray.remove(at: i)
        while(i <= posts.count){
            if(user == posts[i].user){
                posts.remove(at: i)
            }
        }
        feedTV.reloadData()
    }*/
    
    @objc func loadPosts() {
        databaseRef.child("posts").observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let captionText = dict["caption"] as! String
                let userID = dict["user"] as! String
                let timestamp = dict["time"] as! Double
                let converted = NSDate(timeIntervalSince1970: timestamp / 1000) as Date
                let newTime = converted.timeAgoDisplay()
                print("NEW TIME \(newTime)")
                //print("Array \(self.userIDArray)")
                print(userID)
                if ((self.userIDArray.contains(userID) || userID == self.currentUser!)) {
                    let post = Post(captionText: captionText, userText: userID, timeText: newTime)
                    self.posts.insert(post, at: 0)
                    //print(self.posts)
                }
                self.feedTV.reloadData()
            }
        }
    }
    
    @objc func reloadPage() {
        //refresh time and add new posts HERE
        refresher.endRefreshing()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(posts.count == 0){
            hideFeedView.isHidden = false
        } else if(posts.count > 0){
            hideFeedView.isHidden = true
        }
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "post") as! postCell
        let id = posts[indexPath.row].user
        databaseRef.child("users").child(id!).observe(.value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let username = value?["Username"] as? String ?? ""
            cell.userLabel.text = username
        }
        //getting profile picture from Firebase Storage for user
        let reference = Storage.storage().reference(forURL: "gs://data-practice-b6f99.appspot.com")
        let imageName: String = "profileImage\(id!).jpg"
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
        cell.userImage.layer.cornerRadius = cell.userImage.frame.size.width/2
        cell.userImage.clipsToBounds = true
        cell.userImage.layer.borderColor = (UIColor.gray).cgColor
        cell.userImage.layer.borderWidth = 0.5
        
        cell.caption.text = posts[indexPath.row].caption
        cell.songView.layer.cornerRadius = 12
        cell.songView.layer.borderColor = UIColor(red: 255/255, green: 147/255, blue: 0/255, alpha: 1).cgColor
        cell.songView.layer.borderWidth = 2.0
        cell.layoutMargins = UIEdgeInsets.zero
        cell.timeLabel.text = posts[indexPath.row].timeStamp
        
        return cell
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
    
    @IBAction func unwindToHomeVC(segue:UIStoryboardSegue) {
       
    }
}

extension Date {
    func timeAgoDisplay() -> String {
    
        let secondsAgo = Int(Date().timeIntervalSince(self))
        print(self)
        print(secondsAgo)
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        
        if secondsAgo == 0 {
            return "Just now"
        } else if secondsAgo < minute {
            return "\(secondsAgo) seconds ago"
        } else if secondsAgo < hour {
            if((secondsAgo/minute) == 1){
                return "\(secondsAgo/minute) minute ago"
            } else {
                return "\(secondsAgo/minute) minutes ago"
            }
        } else if secondsAgo < day {
            if((secondsAgo/hour) == 1){
                return "\(secondsAgo/hour) hour ago"
            } else {
                return "\(secondsAgo/hour) hours ago"
            }
        } else if secondsAgo < week {
            if((secondsAgo/day) == 1){
                return "\(secondsAgo/day) day ago"
            } else {
                return "\(secondsAgo/day) days ago"
            }
        } else if (secondsAgo/week) < 5 {
            if (secondsAgo/week) == 1{
                return "\(secondsAgo/week) week ago"
            } else {
                return "\(secondsAgo/week) weeks ago"
            }
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            let newTime = formatter.string(from: self)
            return newTime
        }
    }
}

extension UIImage {
}
