//
//  LoginViewController.swift
//  Magic Recorder
//
//  Created by Pranish Pathak on 25/7/2024.
//

import UIKit

class LoginViewController: UIViewController {
    
    // All UI elements
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    
    var myContact : Contacts!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        myContact = Contacts(name: "Pranish", email: "iampranish@outlook.com", position: "Software Engineer")
    }
    
    // functions for all buttons

    // when forgot password button is tapped
    @IBAction func forgotPasswordOnTap(_ sender: Any) {
    }
    
    // when login button is pressed
    @IBAction func loginButtonOnTap(_ sender: Any) {
    }
    
    // when registerButton is Pressed
    @IBAction func registerButtonOnTap(_ sender: Any) {
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: RegisterViewController.self){
            let registerVc = segue.destination as! RegisterViewController
            registerVc.receivedContacts = myContact
        }
        
    }
    @IBAction func unwindToLoginViewController(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    

}
