//
// SignInVC.swift
//  SocialMediaApp
//
//  Created by YC on 1/10/17.
//  Copyright © 2017 Cakmak LLC. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper


class SignInVC: UIViewController {
    
    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var pwdField: FancyField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {   // segue s cannot be performed in viewDidLoad
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("ALERT: ID found in keychain")
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

       @IBAction func facebookBtnTapped(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("ALERT:Unable to authanticate with Facebook! - \(error)")
            } else if result?.isCancelled == true {
                
                print("ALERT:User cancelled facebook authantication!")
            } else {
                print("ALERT:Successfully authenticated with Facebook!")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
            
        }
    }
    
    func firebaseAuth(_ credential: FIRAuthCredential){
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("ALERT:Unable to authenticate with Firebase - \(error)")
            } else {
                print("ALERT:Successfully authenticate with Firebase")
                
                if let user = user {
                    
                    let userData = ["provider": credential.provider]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
            }
            
        })
    }
    @IBAction func signInTapped(_ sender: Any) {
        
        if let email = emailField.text, let pwd = pwdField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("ALERT: Email user authenticated with Firebase!")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user2, error2) in
                        if error2 != nil {
                             print("ALERT:Unable to authentica with Firebase using email")
                        } else {
                            print("ALERT:Successfully authenticated with Firebase ")
                            if let user = user {
                                let userData = ["provider": user.providerID ]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
                        }
                    })
                    
                }
            })
            
        }
        
        
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>){
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        KeychainWrapper.standard.set(id, forKey: KEY_UID )
        performSegue(withIdentifier: "goToFeed", sender: nil)
 
    }

}
















