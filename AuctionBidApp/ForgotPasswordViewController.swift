

import UIKit
import CoreData

class ForgotPasswordViewController: UIViewController {

  
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var accountNameTextField: UITextField!
    
    
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    @IBAction func forgotBtn(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
                      let username = accountNameTextField.text, !username.isEmpty,
                      let newPassword = newPasswordTextField.text, !newPassword.isEmpty,
                      let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
          
                    showAlert(message: "All fields are required")
                    return
        
    }
    
        if let userData = fetchUserData(email: email, username: username) {
                  
                    if newPassword == confirmPassword {
                    
                        userData.userpassword = newPassword
                        saveChanges()
                        showAlert(message: "Password updated successfully")
                    } else {

                        showAlert(message: "New password and confirm password do not match")
                    }
                } else {
                    
                    showAlert(message: "User not found please correct email and display name ")
                }
            }
    
    func fetchUserData(email: String, username: String) -> UserProfileData? {
           let fetchRequest: NSFetchRequest<UserProfileData> = UserProfileData.fetchRequest()
           fetchRequest.predicate = NSPredicate(format: "useremail = %@ AND username = %@", email, username)
           
           do {
               let users = try context.fetch(fetchRequest)

               return users.first
           } catch {
               print("Error fetching user data: \(error.localizedDescription)")
            
               
               return nil
           }
       }
       
      
       func saveChanges() {
           do {
               try context.save()
           } catch {
               print("Error saving changes: \(error.localizedDescription)")
           }
       }
       
  
       func showAlert(message: String) {
           let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           self.present(alert, animated: true, completion: nil)
       }
   }


