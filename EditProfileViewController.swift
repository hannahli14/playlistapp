//
//  EditProfileViewController.swift
//  DataPractice
//
//  Created by Hannah Li on 8/8/18.
//  Copyright © 2018 Hannah Li. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

protocol EditProfileDelegate {
    func sendData(image: UIImage, name: String, handle: String)
}

class EditProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmTF: UITextField!
    var image:UIImage!
    var getImage:UIImage!
    var getName:String!
    var getEmail:String!
    var getUsername:String!
    var getPassword:String!
    var getConfirmPW:String!
    var profileURL:URL?
    var delegate:EditProfileDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //getting informatino from Profile View Controller
        profileImage.image = getImage
        nameTF.text = getName
        emailTF.text = getEmail
        usernameTF.text = getUsername
        passwordTF.text = getPassword
        confirmTF.text = getConfirmPW
        //delegation
        passwordTF.isSecureTextEntry = true
        confirmTF.isSecureTextEntry = true
        nameTF.delegate = self
        emailTF.delegate = self
        usernameTF.delegate = self
        passwordTF.delegate = self
        confirmTF.delegate = self
        //design/UX
        self.hideKeyboardWhenTappedAround()
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        profileImage.layer.borderColor = (UIColor.gray).cgColor
        profileImage.layer.borderWidth = 1.0
        gradientCalled()
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
    
    @IBAction func selectPhotoPressed(_ sender: Any) {
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
    
    @IBAction func donePressed(_ sender: Any) {
        self.delegate?.sendData(image: self.profileImage.image!, name: self.nameTF.text!, handle: self.usernameTF.text!)
        let storageRef = Storage.storage().reference().child("profileImage\((Auth.auth().currentUser?.uid)!).jpg")
        if let uploadData = UIImageJPEGRepresentation(self.profileImage.image!, 0.6) {
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if (error != nil) {
                    print("Error: \(String(describing: error))")
                    return
                }
                let _ = storageRef.downloadURL(completion: { (url, error) in
                    if(error != nil)
                    {
                        print ("Error with URL: \(String(describing: error))")
                        return
                    } else {
                        self.profileURL = url
                        let ref = Database.database().reference().child("users/\((Auth.auth().currentUser?.uid)!)")
                        ref.updateChildValues([
                            "Name" : self.nameTF.text!,
                            "Username" : self.usernameTF.text!,
                            "Email" : self.emailTF.text!,
                            "Password" : self.passwordTF.text!,
                            "Profile URL" : self.profileURL?.absoluteString as Any,
                            "UID" : (Auth.auth().currentUser?.uid)!
                            ])
                    }
                })
            } //end putData
        }
        _ = navigationController?.popViewController(animated: true)
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
}



