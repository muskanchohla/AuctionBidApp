

import UIKit
import CoreData
class ProfileViewController: UIViewController {
    let loggedInUserID = UserDefaults.standard.string(forKey: "loggedInUserID")
    
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var profileEmailId: UILabel!
    
    
    @IBOutlet weak var profileRole: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loggedUserProfile()
       
    }
    
    @IBAction func changeImageBtn(_ sender: Any) {
        let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func changeNameBtn(_ sender: Any) {
        print("change name button has been clicked")
     
            let alertController = UIAlertController(title: "Change Name", message: "Enter your new name", preferredStyle: .alert)
            
            alertController.addTextField { (textField) in
                textField.placeholder = "New Name"
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let changeAction = UIAlertAction(title: "Change", style: .default) { (_) in
                if let newName = alertController.textFields?.first?.text, !newName.isEmpty {
                    // Call function to update name in Core Data
                    self.updateUserName(newName)
                } else {
                    // Show an alert if the text field is empty
                    let emptyAlert = UIAlertController(title: "Error", message: "Please enter a new name", preferredStyle: .alert)
                    emptyAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(emptyAlert, animated: true, completion: nil)
                }
            }
            alertController.addAction(changeAction)
            
            present(alertController, animated: true, completion: nil)
        
        
    }
    
    
    func updateUserName(_ newName: String) {
        guard let loggedInUserID = self.loggedInUserID else {
            print("Logged-in user ID is nil")
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Failed to get AppDelegate")
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        if let loggedUser = fetchLoggedUser(userid: loggedInUserID) {
            // Update user's name
            loggedUser.username = newName
            
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.profileName.text = newName // Update UI with new name
                }
                print("User name updated successfully")
            } catch {
                print("Failed to update user name: \(error.localizedDescription)")
            }
        } else {
            print("Logged-in user profile not found")
        }
    } // end of change name function
    
    
    @IBAction func changePasswordBtn(_ sender: Any) {
        print("change password  button has been clicked")
     
            let alertController = UIAlertController(title: "Change Password", message: "Enter your new Password", preferredStyle: .alert)
            
            alertController.addTextField { (textField) in
                textField.placeholder = "New Password"
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let changeAction = UIAlertAction(title: "Change", style: .default) { (_) in
                if let newPassword = alertController.textFields?.first?.text, !newPassword.isEmpty {
                    // Call function to update name in Core Data
                    self.updatePassword(newPassword)
                } else {
                    // Show an alert if the text field is empty
                    let emptyAlert = UIAlertController(title: "Error", message: "Please enter a new Password ", preferredStyle: .alert)
                    emptyAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(emptyAlert, animated: true, completion: nil)
                }
            }
            alertController.addAction(changeAction)
            
            present(alertController, animated: true, completion: nil)
        
        
    }
    
    
    func updatePassword(_ newPassword: String) {
        guard let loggedInUserID = self.loggedInUserID else {
            print("Logged-in user ID is nil")
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Failed to get AppDelegate")
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        if let loggedUser = fetchLoggedUser(userid: loggedInUserID) {
          
            loggedUser.userpassword = newPassword
            
            do {
                try context.save()
                DispatchQueue.main.async {
                   
                }
                print("Password updated successfully")
                let message = "Password Updated Successfully "
                let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
               present(alertController, animated: true, completion: nil)
            } catch {
                print("Failed to update failed to Update Password: \(error.localizedDescription)")
            }
        } else {
            print("Logged-in user profile not found")
        }
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
   

        if let loggedUser = fetchLoggedUser(userid: loggedInUserID!) {
            // Update UI on the main thread
            DispatchQueue.main.async {
               // self.bidderNameLbl.text = loggedUser.username
              //  self.bidderRoleLbl.text = loggedUser.usertype
                self.profileName.text = loggedUser.username
                self.profileEmailId.text = loggedUser.useremail
                
                if let userType = loggedUser.usertype {
                    self.profileRole.text = "I am a \(userType)"
                } else {
                    // Handle the case where usertype is nil
                    // For example:
                    self.profileRole.text = "User type is not specified"
                }

                
                // Set the logged-in user's image
                // Set the logged-in user's image
                if let imageData = loggedUser.userimage {
                    if let image = UIImage(data: imageData) {
                        self.profileImage.image = image
                    } else {
                       // self.bidderImg.image = UIImage(named: "UserImage") // Placeholder image name or nil
                        self.profileImage.image = UIImage(named: "UserImage")
                    }
                } else {
                    self.profileImage.image = UIImage(named: "UserImage")
                }
                
            }
            print("Logged-in User ID: \(loggedInUserID)")
        } else {
            print("Failed to fetch logged-in user profile")
        }
    }
    
    

   

}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            profileImage.image = selectedImage
            updateProfileImageInCoreData(image: selectedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController {
    func updateProfileImageInCoreData(image: UIImage) {
        guard let loggedInUserID = self.loggedInUserID else {
            print("Logged-in user ID is nil")
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Failed to get AppDelegate")
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        if let loggedUser = fetchLoggedUser(userid: loggedInUserID) {
            loggedUser.userimage = image.pngData() // Convert UIImage to Data and save to Core Data
            
            do {
                try context.save()
                print("Profile image updated successfully")
            } catch {
                print("Failed to update profile image: \(error.localizedDescription)")
            }
        } else {
            print("Logged-in user profile not found")
        }
    }
}
