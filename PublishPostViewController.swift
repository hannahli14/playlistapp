//
//  PublishPostViewController.swift
//  DataPractice
//
//  Created by Hannah Li on 8/24/18.
//  Copyright © 2018 Hannah Li. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class PublishPostViewController: UIViewController, UITextViewDelegate{

    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var songView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    
    
    let databaseRef = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        songView.layer.cornerRadius = 12
        songView.layer.borderColor = UIColor(red: 255/255, green: 147/255, blue: 0/255, alpha: 1).cgColor
        songView.layer.borderWidth = 2.0
        postText.delegate = self
        countLabel.text = "200/200"
    }
    
    func textViewDidChange(_ textView: UITextView) {
        countLabel.text = "\(200 - textView.text.count)/200"
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= 200
    }
    
    @IBAction func postPressed(_ sender: Any) {
        let currentUser = (Auth.auth().currentUser?.uid)!
        let ref = databaseRef.child("posts")
        let newPostID = ref.childByAutoId().key
        //convert in HomeVC to seconds/days/weeks etc.
        ref.child(newPostID).setValue([
            "caption" : self.postText.text!,
            "user" : currentUser,
            "time" : ServerValue.timestamp()
        ])
        performSegue(withIdentifier: "unwindToHomeVC", sender: self)
    }
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
