//
//  SignInViewController.swift
//  IOS Developer Task
//
//  Created by Manoj on 27/06/24.
//

import UIKit
import RealmSwift

class SignInViewController: UIViewController {
    
    @IBOutlet weak var usersTablView: UITableView!
    @IBOutlet weak var popupViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var popupTitleLabel: UILabel!
    
    var emailList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        popupView.layer.cornerRadius = 20
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configuration()
    }
    
    func configuration() {
        usersTablView.register(UINib(nibName: "DashboardMapCell", bundle: nil), forCellReuseIdentifier: "DashboardMapCell")
        emailList = getAllEmails()
        usersTablView.reloadData()
        
        if !emailList.isEmpty {
            popupView.isHidden = false
            let height = usersTablView.contentSize.height + 77
            popupViewHeightContraint.constant = height > 300 ? 300 : height
        } else {
            popupView.isHidden = true
        }
    }
    
    func getAllEmails() -> [String] {
        let realm = try! Realm()
        let users = realm.objects(User.self)
        return users.map { $0.email }
    }
    
    @IBAction func popupCloseButtonAction(_ sender: Any) {
    }
    
    
    @IBAction func signUpButtonAction(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyBoard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController else {
            return
        }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func signInButtonAction(_ sender: Any) {
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            self.showAlert(title: "Sign In", message: "Please Enter the email")
        }
        else if passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            self.showAlert(title: "Sign Up", message: "Please Enter the password")
        }
        else if login(email: emailTextField.text ?? "", password: passwordTextField.text ?? "") {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            guard let viewController = storyBoard.instantiateViewController(withIdentifier: "DashboardViewController") as? DashboardViewController else {
                return
            }
            viewController.email = emailTextField.text ?? ""
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        else {
            self.showAlert(title: "Sign Up", message: "Invalid email or password")
        }
        
    }
    
    func login(email: String, password: String) -> Bool {
        let realm = try! Realm()
        
        if let user = realm.objects(User.self).filter("email == %@ AND password == %@", email, password).first {
            try! realm.write {
                user.isLoggedIn = true
            }
            return true
        } else {
            return false
        }
    }
}
extension SignInViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        emailList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardMapCell", for: indexPath) as? DashboardMapCell else {
            return UITableViewCell()
        }
        cell.addressLbl.text = emailList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyBoard.instantiateViewController(withIdentifier: "DashboardViewController") as? DashboardViewController else {
            return
        }
        viewController.email = emailList[indexPath.row]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
