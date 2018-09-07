//
//  registerViewController.swift
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

class RegisterViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmTF: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    
    var profileURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameTF.delegate = self
        self.emailTF.delegate = self
        self.usernameTF.delegate = self
        self.passwordTF.delegate = self
        self.confirmTF.delegate = self
        
        //design/UX
        self.hideKeyboardWhenTappedAround()
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        profileImage.layer.borderColor = (UIColor.darkGray).cgColor
        profileImage.layer.borderWidth = 0.5
        nameTF.layer.cornerRadius = 7.0
        nameTF.layer.borderWidth = 0.5
        nameTF.layer.borderColor = UIColor.darkGray.cgColor
        emailTF.layer.cornerRadius = 7.0
        emailTF.layer.borderWidth = 0.5
        emailTF.layer.borderColor = UIColor.darkGray.cgColor
        usernameTF.layer.cornerRadius = 7.0
        usernameTF.layer.borderWidth = 0.5
        usernameTF.layer.borderColor = UIColor.darkGray.cgColor
        passwordTF.layer.cornerRadius = 7.0
        passwordTF.layer.borderWidth = 0.5
        passwordTF.layer.borderColor = UIColor.darkGray.cgColor
        confirmTF.layer.cornerRadius = 7.0
        confirmTF.layer.borderWidth = 0.5
        confirmTF.layer.borderColor = UIColor.darkGray.cgColor
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTF {
            textField.resignFirstResponder()
            emailTF.becomeFirstResponder()
        } else if textField == emailTF {
            textField.resignFirstResponder()
            usernameTF.becomeFirstResponder()
        } else if textField == usernameTF {
            textField.resignFirstResponder()
            passwordTF.becomeFirstResponder()
        } else if textField == passwordTF {
            textField.resignFirstResponder()
            confirmTF.becomeFirstResponder()
        } else if textField == confirmTF {
            textField.resignFirstResponder()
        }
        return true
    }
    
    // Start Editing The Text Field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField == passwordTF){
            moveTextField(textField, moveDistance: -100, up: true)
        } else if(textField == confirmTF) {
            moveTextField(textField, moveDistance: -130, up: true)
        }
    }
    
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField == passwordTF){
            moveTextField(textField, moveDistance: -100, up: false)
        } else if(textField == confirmTF){
            moveTextField(textField, moveDistance: -130, up: false)
        }
    }
    
    // Move the text field in a pretty animation!
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    func displayError(userMessage:String)
    {
        let myAlert = UIAlertController(title: "Oops!", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title:"OK", style: UIAlertActionStyle.default, handler: nil)
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    @IBAction func donePressed(_ sender: Any) {
        let email = emailTF.text!
        let password = passwordTF.text!
        if(nameTF.text?.isEmpty)! || (emailTF.text?.isEmpty)! || (usernameTF.text?.isEmpty)! || (passwordTF.text?.isEmpty)! || (confirmTF.text?.isEmpty)! || (profileImage.image == nil) {
            displayError(userMessage: "All fields are required.")
            return
        }
        if(passwordTF.text! != confirmTF.text!) {
            displayError(userMessage: "Passwords do not match.")
            return
        }
        if((passwordTF.text?.count)! < 6) {
            displayError(userMessage: "Password must be at least 6 characters long.")
            return
        }
        
        //creating user
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            // there is an error
            if(error != nil) {
                print("Error: \(String(describing: error?.localizedDescription))")
                self.dismiss(animated: true, completion: nil)
            } else {
                print("User Created!")
                //storing user profile image
               let storageRef = Storage.storage().reference().child("profileImage\((Auth.auth().currentUser?.uid)!).jpg")
                if let uploadData = UIImageJPEGRepresentation(self.profileImage.image!, 0.6) {
                    storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                        if (error != nil) {
                            print("Error: \(error)")
                            return
                        }
                        let _ = storageRef.downloadURL(completion: { (url, error) in
                            if(error != nil) {
                                print ("Error with URL: \(error)")
                                return
                            } else {
                                self.profileURL = url
                                Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).setValue([
                                    "Name" : self.nameTF.text!,
                                    "Username" : self.usernameTF.text!,
                                    "Email" : self.emailTF.text!,
                                    "Password" : self.passwordTF.text!,
                                    "Confirm Password" : self.confirmTF.text!,
                                    "Profile URL" : self.profileURL?.absoluteString,
                                    "UID" : (Auth.auth().currentUser?.uid)!,
                                    "Private Account" : false
                                    ])
                            }
                        })
                    } //end putData
                } //end if let uploadData
            } //end else statement
        } //end Auth function
    }//end of done function
    
    @IBAction func selectProfilePhoto(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = .photoLibrary
        image.allowsEditing = true
        present(image, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage  {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            profileImage.image = resizeImage(image: selectedImage, targetSize: CGSize(width: 210, height: 210))
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Canceled Image Picker")
        dismiss(animated: true, completion: nil)
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
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
