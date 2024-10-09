//
//  HomeTableViewController.swift
//  AuctionBidApp
//
//  Created by user254754 on 3/29/24.
//

import UIKit
import CoreData

class SellerHomeTableViewController: UITableViewController, UINavigationControllerDelegate {

    @IBOutlet weak var loggedUserName: UILabel!
    @IBOutlet weak var loggedUserImage: UIImageView!
    @IBOutlet weak var accountType: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationItem.hidesBackButton = true

        
        loggedUserProfile()
    

        // Apply rounded corners to the user image view
        loggedUserImage.layer.borderWidth = 3
        loggedUserImage.layer.borderColor = UIColor.green.cgColor
        
        loggedUserImage.layer.masksToBounds = true
        loggedUserImage.layer.cornerRadius = loggedUserImage.frame.height / 2
        
        
    }
        
    
    @IBAction func logoutBtn(_ sender: Any) {
        print("logout clicked")
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginTableViewController") as! LoginTableViewController
        navigationController?.pushViewController(loginVC, animated: true)
        self.dismiss(animated: true, completion: nil)
        navigationController?.viewControllers = [loginVC]
        
        
    }
    
    
    func fetchLoggedUser(userid: String) -> UserProfileData? {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        let context = appDelegate!.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<UserProfileData> = UserProfileData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userid == %@", userid)
        
        do {
            let users = try context.fetch(fetchRequest)
            return users.first
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
            return nil
        }
    }
    
    func loggedUserProfile() {
        guard let loggedInUserID = UserDefaults.standard.string(forKey: "loggedInUserID") else {
            print("Logged-in User ID not found")
            return
        }

        // Fetch logged-in user profile
        if let loggedUser = fetchLoggedUser(userid: loggedInUserID) {
            // Update UI on the main thread
            DispatchQueue.main.async {
                self.loggedUserName.text = loggedUser.username
                self.accountType.text = loggedUser.usertype
               
                
                // Set the logged-in user's image
                // Set the logged-in user's image
                if let imageData = loggedUser.userimage {
                    if let image = UIImage(data: imageData) {
                        self.loggedUserImage.image = image
                    } else {
                        self.loggedUserImage.image = UIImage(named: "UserImage") // Placeholder image name or nil
                    }
                } else {
                    self.loggedUserImage.image = UIImage(named: "UserImage") // Placeholder image name or nil
                }

            }
            print("Logged-in User ID: \(loggedInUserID)")
        } else {
            print("Failed to fetch logged-in user profile")
        }
    }


    
}

