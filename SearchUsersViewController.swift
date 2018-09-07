//
//  SearchUsersViewController.swift
//  DataPractice
//
//  Created by Hannah Li on 8/2/18.
//  Copyright © 2018 Hannah Li. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class userCell: UITableViewCell {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userUsername: UILabel!
}

class SearchUsersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var searchTableView: UITableView!
    
    var currentItem: String!
    var currentImage: UIImage!
    var userIDArray = [String]()
    var usersArray = [NSDictionary?]()
    var filteredUsers = [NSDictionary?]()
    let searchController = UISearchController(searchResultsController: nil)
    var vc: FriendProfileViewController? = nil
    
    var databaseRef = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //make navigation bar invisible
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        //prevents search bar from moving up when pressed
        self.searchController.hidesNavigationBarDuringPresentation = false
        //update results while searching
        searchController.searchResultsUpdater = self as UISearchResultsUpdating
        searchController.dimsBackgroundDuringPresentation = false
        searchController.definesPresentationContext = true
        self.definesPresentationContext = true
        //place search bar
        searchTableView.tableHeaderView = searchController.searchBar
        
        //design/UX
        searchController.searchBar.searchBarStyle = .default
        searchController.searchBar.barTintColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        searchController.searchBar.isTranslucent = false
        self.searchTableView.dataSource = self
        self.searchTableView.delegate = self
        self.searchTableView.rowHeight = 55
        
        databaseRef.child("users").queryOrdered(byChild: "UID").observe(.childAdded) { (snapshot) in
            //print(snapshot.value)
            self.usersArray.append(snapshot.value as? NSDictionary)
            self.searchTableView.insertRows(at: [IndexPath(row:self.usersArray.count-1, section:0)], with: UITableViewRowAnimation.automatic)
            let dict = snapshot.value as! [String: Any]
            let userID = dict["UID"] as! String
            //this holds all the userID's in an array
            self.userIDArray.append(userID)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchTableView.reloadData()
        databaseRef.child("users").queryOrdered(byChild: "UID").observe(.childChanged) { (snapshot) in
            let dict = snapshot.value as! [String: Any]
            //get index for current user to remove
            let userUID = dict["UID"] as! String
            let index = self.userIDArray.index(of: userUID)
            self.usersArray.remove(at: index!)
            self.usersArray.insert(snapshot.value as? NSDictionary, at: index!)
            self.searchTableView.reloadRows(at: [IndexPath(row: self.usersArray.count-1, section: 0)], with: .automatic)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredUsers.count
        }
        return self.usersArray.count
    }

    //NEED TO FIGURE OUT A WAY TO LOAD IMAGES FASTER WHEN SEARCHING SO THEY DONT GET MIXED UP
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user : NSDictionary?
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
        } else {
            user = usersArray[indexPath.row]
        }
        let userUID = user?["UID"] as? String
        var cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! userCell
        if(userUID == (Auth.auth().currentUser?.uid)!){
            //will segue to HomeViewController if selected
            cell = tableView.dequeueReusableCell(withIdentifier: "currentUser", for: indexPath) as!  userCell
        }
        cell.userName?.text = user?["Name"] as? String
        cell.userUsername?.text = user?["Username"] as? String
        
        //getting profile picture from Firebase Storage for user
        let reference = Storage.storage().reference(forURL: "gs://data-practice-b6f99.appspot.com")
        let imageName: String = "profileImage\(userUID!).jpg"
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
                    cell.userImage?.image = self.resizeImage(image: tempImage, targetSize: CGSize(width: 210, height: 210))
                }
            }).resume()
        }
        cell.userImage.layer.cornerRadius = cell.userImage.frame.size.width/2
        cell.userImage.clipsToBounds = true
        cell.userImage.layer.borderColor = (UIColor.gray).cgColor
        cell.userImage.layer.borderWidth = 1.0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let indexPath = tableView.indexPathForSelectedRow
        let user : NSDictionary?
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredUsers[(indexPath?.row)!]
        } else {
            user = usersArray[(indexPath?.row)!]
        }
        let userUID = user?["UID"] as? String
        let currentCell = tableView.cellForRow(at: indexPath!)! as! userCell
        currentItem = currentCell.userUsername.text!
        currentImage = currentCell.userImage.image!
        if(userUID != (Auth.auth().currentUser?.uid)!){
            //getting the current cell from the index path
            vc?.getUser = currentItem
            vc?.getImage = currentImage
            vc?.getUserID = userUID!
        }
        print("1")
    }
    
    //updates search results by filtering through the content every time
    //a letter is added or removed from the search bar
    func updateSearchResults(for searchController: UISearchController) {
        filterContent(searchText: self.searchController.searchBar.text!)
    }
    
    func filterContent(searchText:String)
    {
        let whitespace = " "
        self.filteredUsers = self.usersArray.filter{ user in
            if(searchText.contains(whitespace)){
                let username = user!["Name"] as? String
                return(username?.lowercased().contains(searchText.lowercased()))!
            } else {
                let handle = user!["Username"] as? String
                return(handle?.lowercased().contains(searchText.lowercased()))!
            }
        }
        searchTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is FriendProfileViewController {
            print("2")
            vc = segue.destination as? FriendProfileViewController
        }
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
}
