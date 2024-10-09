//
//  LoginTableViewController.swift
//  AuctionBidApp
//
//  Created by user254754 on 3/29/24.
//

import UIKit
import CoreData

class LoginTableViewController: UITableViewController, UINavigationControllerDelegate{
    
  
  
    

    @IBOutlet weak var loginEmail: UITextField!
    
    @IBOutlet weak var loginPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("lgoin page opened")
      // globalDeleter()
       // showGlobalAlert(message: "Welcome ", viewController: self)
        print ("time is \(auctionTime)")
        
    }
    
    @IBAction func loginBtn(_ sender: Any) {
        print(loginEmail.text!)
        print(loginPassword.text!)
        let inputLoginEmail = loginEmail.text!
        let inputLoginPassword = loginPassword.text!
        loginButtonPressed(useremail: inputLoginEmail, password: inputLoginPassword)
        
    }
    
    @IBAction func signUpBtn(_ sender: Any) {
        let signUpVC = storyboard?.instantiateViewController(withIdentifier: "SignUpTableViewController") as! SignUpTableViewController
        navigationController?.pushViewController(signUpVC, animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    
    
    func fetchUser(useremail: String) -> UserProfileData? {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        let context = appDelegate!.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<UserProfileData> = UserProfileData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "useremail == %@", useremail)
        
        do {
            let users = try context.fetch(fetchRequest)
            return users.first
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    func loginButtonPressed(useremail: String, password: String) {
        
        if let user = fetchUser(useremail: useremail) {
            if user.userpassword == password {
                print("Successful Login")
                
                let uid = user.userid?.uuidString
                UserDefaults.standard.set(uid, forKey: "loggedInUserID")
                if let uid = uid {
                    // The value was successfully set
                    print("Successfully set loggedInUserID to: \(uid)")
                    
                } else {
                    // Failed to set the value (possibly because user.userid is nil)
                    print("Failed to set loggedInUserID")
                }
                if (user.usertype == "Seller" && user.usertypecode == 2){
                    performSegue(withIdentifier: "loginToSeller", sender: self)
                }
                else if (user.usertype == "Bidder" && user.usertypecode == 1){
                    performSegue(withIdentifier: "loginToBidder", sender: self)
                }
                else {
                    showAlert(title: "Error", message: "Something Went Wrong")
                    
                }
                
                
            } else {
                print("Incorrect Password")
                showAlert(title: "Error", message: "Incorrect Password")
            }
        } else {
            showAlert(title: "Error", message: "Username not found")
            print("Username not found")
        }
    }
    
    
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func forgotPasswordClick(_ sender: Any) {
        let forgotPassVC = storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordViewController
        navigationController?.pushViewController(forgotPassVC, animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    
}
    




//showAlert(title: "Login Successful", message: "Welcome!")



//                let sellerhomeVC = storyboard?.instantiateViewController(withIdentifier: "SellerHomeTableViewController") as! SellerHomeTableViewController
//                sellerhomeVC.loggedInUser = user.username
//                sellerhomeVC.loggedInUserType = user.usertype
//                sellerhomeVC.loggedInUserEmail = user.useremail
//                if let imageData = user.userimage {
//                    sellerhomeVC.loggedInUserImage = UIImage(data: imageData)
//                }


//                navigationController?.pushViewController(sellerhomeVC, animated: true)
//                dismiss(animated: true, completion: nil)
//                // Remove the back button
//                navigationController?.viewControllers = [sellerhomeVC]
                
                
                
