//
//  LoginViewController.swift
//  AllStars
//
//  Created by Rodrigo Gonzalez on 4/7/16.
//  Copyright © 2016 Belatrix. All rights reserved.
//

import UIKit
import SnapKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    let usernameTag = 100
    let passwordTag = 101
    
    var usernameEntered = false {
        didSet {
            enableLoginButton()
        }
    }
    
    var passwordEntered = false {
        didSet {
            enableLoginButton()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Login"
        
        view.backgroundColor = Utils.mainColor
        setupViews()
        setupLoginButton()
        loginButton.enabled = false
    }

    let offset = 15
    let textfieldHeight = 30
    
    func setupViews() {
        usernameTextField.tag = usernameTag
        passwordTextField.tag = passwordTag
        setupTextField(usernameTextField)
        setupTextField(passwordTextField)
    }
    
    func setupTextField(textfield : UITextField) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 20))
        textfield.leftView = paddingView
        textfield.leftViewMode = .Always
        
        textfield.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
       
        textfield.layer.borderWidth = 0.5
        textfield.layer.borderColor = UIColor.whiteColor().CGColor
        textfield.layer.cornerRadius = 3
        textfield.clipsToBounds = true

        textfield.textColor = .whiteColor()
        
        textfield.addTarget(self, action: #selector(textDidChange), forControlEvents: UIControlEvents.EditingChanged)
        
        textfield.delegate = self
    }
    
    func textDidChange(textfield : UITextField) {
        switch textfield.tag {
        case usernameTag :
            usernameEntered = textfield.text?.characters.count > 0
        case passwordTag :
            passwordEntered = textfield.text?.characters.count > 0
        default :
            // do nothing
            return
        }
 
    }
    
    func enableLoginButton() {
        loginButton.enabled = usernameEntered && passwordEntered
    }
    
    func setupLoginButton() {
        loginButton.tintColor = .whiteColor()
        loginButton.layer.borderColor = UIColor.whiteColor().CGColor
        loginButton.layer.borderWidth = 0.5
        loginButton.layer.cornerRadius = 3
        loginButton.clipsToBounds = true

    }
    @IBAction func loginButtonAction(sender: AnyObject) {
        //do login stuff
        self.showLoadingIndicator()
        guard let username = usernameTextField.text, password = passwordTextField.text else {
            return
        }

        LoginService.login(username, password: password) { (response : AnyObject?, error : NSError?) -> Void in
            self.hideLoadingIndicator()
            
            if error != nil {
                print("error")
            } else if let token = (response as? NSDictionary)!["token"] as? String, let userId = (response as? NSDictionary)!["user_id"] as? UInt {
                
                Utils.save(token, key: Utils.tokenKey)
                Utils.save(String(userId), key: Utils.userIdKey)
                self.performSegueWithIdentifier("login", sender: nil)
            } else {
                print("error")
            }
        }
    }

    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField.tag {
        case usernameTag :
            usernameTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        case passwordTag :
            passwordTextField.resignFirstResponder()
            if loginButton.enabled {
                loginButtonAction(self)
            } else {
                usernameTextField.becomeFirstResponder()
            }
        default :
            // do nothing
            break
        }
        return true
    }
}
