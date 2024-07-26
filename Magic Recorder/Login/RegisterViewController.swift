//
//  RegisterViewController.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 25/7/2024.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    var receivedContacts : Contacts!
    
    // initializing repository class
    let repository = LoginRepository()
    
    
    // all Text fields
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default))
                        self.present(alert, animated: true, completion: nil)

                        }
    
                        
    
    
    // Functions for all buttons
    @IBAction func registerButtonOnPressed(_ sender: Any) {
        print("button Pressed")
        
        repository.registerUser(email: emailTextField.text, password: passwordTextField.text){
            callBack in
            if(callBack){
                self.dismiss(animated: true)
                self.alert(title: "Success", message: "New User Registered Successfully")
                
            }
            else{
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
