//
//  ViewController.swift
//  DataPractice
//
//  Created by Hannah Li on 7/24/18.
//  Copyright © 2018 Hannah Li. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import SwiftKeychainWrapper

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    var userIDArray = [String]()
    var homeVC:HomeViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.email.delegate = self
        self.password.delegate = self
        self.hideKeyboardWhenTappedAround()
        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == email {
            textField.resignFirstResponder()
            password.becomeFirstResponder()
        } else if textField == password {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func displayAlert(userMessage:String) -> Void
    {
        let alertController = UIAlertController(title: "Oops!", message: userMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    

    @IBAction func signInPressed(_ sender: UIButton){
        if((email.text?.isEmpty)!) || (password.text?.isEmpty)!{
            displayAlert(userMessage: "All fields are required.")
        } else if((email.text?.range(of: "@")) == nil) {
            displayAlert(userMessage: "Please enter in your full email address.")
        } else {
            Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (user, error) in
            //if error does not exists
                if(error == nil) {
                    print("Signed in!")
                } else {
                    //error exists
                    self.displayAlert(userMessage: "Password is incorrect.")
                    print("Error logging in: \(String(describing: error?.localizedDescription))")
                    //self.dismiss(animated: true, completion: nil)
                }
            }
            perform(#selector(delayLogin), with: nil, afterDelay: 1)
        }
    }
    
    @objc func delayLogin() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! TabBarViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "toSignUp", sender: self)
    }
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {
        email.text = ""
        password.text = ""
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
