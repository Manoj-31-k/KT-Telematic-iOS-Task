//
//  SignUpViewController.swift
//  IOS Developer Task
//
//  Created by Manoj on 27/06/24.
//

import UIKit
import RealmSwift

class SignUpViewController: UIViewController,UITextFieldDelegate {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signUpButtonAction(_ sender: Any) {
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            self.showAlert(title: "Sign Up", message: "Please Enter the email")
        } else if isValidEmail(email: emailTextField.text ?? "") == false {
            self.showAlert(title: "Sign Up", message: "Please Enter the valid email")
        } else if passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            self.showAlert(title: "Sign Up", message: "Please Enter the password")
        } else if (passwordTextField.text?.count ?? 0) < 6 {
            self.showAlert(title: "Sign Up", message: "password should be at least 6 characters")
        } else if confirmPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            self.showAlert(title: "Sign Up", message: "Please Enter the confirm password")
        } else if confirmPasswordTextField.text != passwordTextField.text {
            self.showAlert(title: "Sign Up", message: "Password and confirm password did not match")
        } else if emailCheck(email: emailTextField.text ?? "") {
            self.showAlert(title: "Sign Up", message: "Email already exist")
        } else {
            signup(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func signup(email: String, password: String) {
        let realm = try? Realm()
        
        let newUser = User()
        newUser.email = email
        newUser.password = password
        
        try? realm?.write {
            realm?.add(newUser)
        }
        self.showAlert(title: "Sign Up", message: "User signed up successfully") {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func emailCheck(email: String) -> Bool {
        let realm = try! Realm()
        if realm.objects(User.self).filter("email == %@", email).first != nil {
            return true
        } else {
            return false
        }
    }
    
}



