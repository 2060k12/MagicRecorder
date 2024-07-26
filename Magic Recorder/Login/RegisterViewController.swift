//
//  RegisterViewController.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 25/7/2024.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
//    var receivedContacts : Contacts!
    
    // initializing repository class
    let repository = LoginRepository()
    
    
    // all Text fields
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextFIeld: UITextField!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // function which will show alert Message in the screen
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default))
                        self.present(alert, animated: true, completion: nil)}
    
    
    // Functions for all buttons
    @IBAction func registerButtonOnPressed(_ sender: Any) {
        progressIndicator.startAnimating()
        // unwrapping values
        
        guard let email = emailTextField.text, !emailTextField.text.isNilOrWhiteSpace else{
            progressIndicator.stopAnimating()
            self.alert(title: "Email", message: "Please Fill all Fields before continueing")
            return
        }
        
        guard let phoneNumber = phoneTextField.text, !phoneTextField.text.isNilOrWhiteSpace  else{
            progressIndicator.stopAnimating()
            self.alert(title: "Phone Number", message: "Please Fill all Fields before continueing")
            return
        }
        guard let fullName = fullNameTextField.text, !fullNameTextField.text.isNilOrWhiteSpace else{
            progressIndicator.stopAnimating()
            self.alert(title: "Full Name", message: "Please Fill all Fields before continueing")
            return
        }
        guard let password = passwordTextField.text, !passwordTextField.text.isNilOrWhiteSpace else{
            progressIndicator.stopAnimating()
            self.alert(title: "Password", message: "Please Fill all Fields before continueing")
            return
        }
        
        guard let confirmPassword = confirmPasswordTextField.text, !confirmPasswordTextField.text.isNilOrWhiteSpace else{
            progressIndicator.stopAnimating()
            self.alert(title: "Password", message: "Please Fill all Fields before continueing")
            return
        }
        
        // checking if both password and confirm password are same
        // if both password doesn't match user wont be able to continue regestering
        
        guard password == confirmPassword else{
            progressIndicator.stopAnimating()
            self.alert(title: "Password doesn't match", message: "Please make sure both password are same ")
            return
        }
        
        
        // initializing Profile Class so that we can pass it as an argument in register function
        let userProfile = Profile(fullName: fullName, email: email, phoneNumber: phoneNumber)
        
        repository.registerUser(user: userProfile, password: password){
            callBack in
            if(callBack){
                self.progressIndicator.stopAnimating()
                self.dismiss(animated: true)
                self.alert(title: "Success", message: "New User Registered Successfully")
                
            }
            else{
                self.progressIndicator.stopAnimating()
                self.alert(title: "Registration Failed", message: "Uh, Oh! Something went wrong!!  ")

            }
        }
    
    }
    
    
   
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
  

}
