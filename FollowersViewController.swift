//
//  FollowersViewController.swift
//  DataPractice
//
//  Created by Hannah Li on 8/12/18.
//  Copyright © 2018 Hannah Li. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class FollowersCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userUsername: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    @IBAction func buttonPressed(_ sender: UIButton) {
        print("button pressed")
    }
}

class FollowersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var followersTableView: UITableView!
    var currentItem: String!
    var currentPageID:String!
    var getUserID:String = ""
    var selectedUID:String!
    var currentImage: UIImage!
    var value: NSDictionary!
    var statusPressed:Bool = false
    var userIDArray = [String]()
    var getUserIDArray = [String]()
    var fvc: FriendProfileViewController? = nil
    var databaseRef = Database.database().reference()
    let reference = Storage.storage().reference(forURL: "gs://data-practice-b6f99.appspot.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentPageID = getUserID
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.followersTableView.dataSource = self
        self.followersTableView.delegate = self
        self.followersTableView.rowHeight = 55
        databaseRef.child("users").child(currentPageID!).child("followers").observe(.value) { (snapshot) in
            print("Hello")
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let value = snap.value
                self.userIDArray.append(value as! String)
                self.followersTableView.insertRows(at: [IndexPath(row:self.userIDArray.count-1, section:0)], with: .automatic)
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userIDArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = userIDArray[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: "followersCell", for: indexPath) as! FollowersCell
        if id == Auth.auth().currentUser?.uid {
            cell = tableView.dequeueReusableCell(withIdentifier: "currentUser", for: indexPath) as!  FollowersCell
        }
        let ref = databaseRef.child("users").child(id)
        ref.observe(.value) { (snapshot) in
            self.value = snapshot.value as? NSDictionary
            let username = self.value?["Username"] as? String
            let name = self.value?["Name"] as? String
            let uid = self.value?["UID"] as? String
            self.getUserIDArray.append(uid!)
            cell.userName.text = name
            cell.userUsername.text = username
        }
        if(id == (Auth.auth().currentUser?.uid)!){
            cell.statusButton.isEnabled = false
        } else {
            cell.statusButton.layer.cornerRadius = cell.statusButton.frame.height / 2
            cell.statusButton.layer.borderWidth = 1.0
            cell.statusButton.clipsToBounds = true
            ref.child("followers").observe(.value) { (snapshot) in
                if(snapshot.hasChild("Follows \((Auth.auth().currentUser?.uid)!)")){
                    cell.statusButton.backgroundColor = UIColor.white
                    cell.statusButton.tintColor = UIColor.darkGray
                    cell.statusButton.setTitle("Following", for: .normal)
                } else {
                    cell.statusButton.backgroundColor = UIColor.darkGray
                    cell.statusButton.tintColor = UIColor.white
                    cell.statusButton.setTitle("Follow", for: .normal)
                }
            }
        }
        cell.statusButton.tag = indexPath.row
        cell.statusButton.addTarget(self, action: #selector(buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        
        //getting profile picture from Firebase Storage for user
        let imageName: String = "profileImage\(id).jpg"
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
                    cell.profileImage?.image = self.resizeImage(image: tempImage, targetSize: CGSize(width: 210, height: 210))
                }
            }).resume()
        }
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width/2
        cell.profileImage.clipsToBounds = true
        cell.profileImage.layer.borderColor = (UIColor.gray).cgColor
        cell.profileImage.layer.borderWidth = 1.0
        return cell
    } //end cellForRowAt

    //currentPageID is only being set to the last added value
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        selectedUID = self.getUserIDArray[(indexPath?.row)!]
        //print("NEW USER \(selectedUID)")
        let currentCell = tableView.cellForRow(at: indexPath!)! as! FollowersCell
        currentItem = currentCell.userUsername.text!
        currentImage = currentCell.profileImage.image!
        fvc?.getUser = currentItem
        fvc?.getImage = currentImage
        fvc?.getUserID = selectedUID
    }
    
    @objc func buttonClicked(sender:UIButton) {
        let buttonRow = sender.tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
        let cell = followersTableView.cellForRow(at: indexPath) as! FollowersCell
        print ("\(userIDArray[buttonRow]) tagged")
        let currentID = userIDArray[buttonRow]
        let ref1 = databaseRef.child("users").child((Auth.auth().currentUser?.uid)!).child("following")
        let ref2 = databaseRef.child("users").child(currentID).child("followers")
        if cell.statusButton.backgroundColor == UIColor.white {
            cell.statusButton.backgroundColor = UIColor.darkGray
            cell.statusButton.tintColor = UIColor.white
            cell.statusButton.setTitle("Follow", for: .normal)
            ref1.child("Following \(currentID)").removeValue()
            ref2.child("Follows \((Auth.auth().currentUser?.uid)!)").removeValue()
        } else if cell.statusButton.backgroundColor == UIColor.darkGray {
            cell.statusButton.backgroundColor = UIColor.white
            cell.statusButton.tintColor = UIColor.darkGray
            cell.statusButton.setTitle("Following", for: .normal)
            ref1.updateChildValues(["Following \(currentID)" : currentID])
            ref2.updateChildValues(["Follows \((Auth.auth().currentUser?.uid)!)" : (Auth.auth().currentUser?.uid)!])
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is FriendProfileViewController {
            print("2")
            fvc = segue.destination as? FriendProfileViewController
        }
    }
    
    //DESIGN FUNCTIONS
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
    
}
