//
//  LoginViewController.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 25/7/2024.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    // initializing repository
    let repository = LoginRepository()
    
    // All UI elements
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the delicate
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    
    
    // function which will show alert Message in the screen
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default))
                        self.present(alert, animated: true, completion: nil)}
    
    
    // functions for all buttons
    // when forgot password button is tapped
    @IBAction func forgotPasswordOnTap(_ sender: Any) {
    }
    
    // when login button is pressed
    @IBAction func loginButtonOnTap(_ sender: Any) {
        progressIndicator.startAnimating()
        
        guard let email = emailTextField.text, !emailTextField.text.isNilOrWhiteSpace else{
            self.alert(title: "Email", message: "Check your Email")
            progressIndicator.stopAnimating()
            return
        }
        guard let password = passwordTextField.text, !passwordTextField.text.isNilOrWhiteSpace else{
            self.alert(title: "Password", message: "Check your Password")
            progressIndicator.stopAnimating()
            return
        }
        
        repository.login(email: email, password: password){
            success in
            if(success){
                self.progressIndicator.stopAnimating()
                let mainViewController = self.storyboard?.instantiateViewController(identifier: "MainViewController") as?
                UITabBarController
                self.view.window?.rootViewController = mainViewController
                self.view.window?.makeKeyAndVisible()
            }
            else {
                self.progressIndicator.stopAnimating()
                self.alert(title: "Something went wrong!", message: "Check your email and password. Or, Try again later!")

            }
        }
    }
    
    // when registerButton is Pressed
    @IBAction func registerButtonOnTap(_ sender: Any) {
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if(textField == emailTextField){
            passwordTextField.becomeFirstResponder()
        }
        else if(textField == passwordTextField){
            passwordTextField.resignFirstResponder()
        }
    
        return true
    }
    
}
