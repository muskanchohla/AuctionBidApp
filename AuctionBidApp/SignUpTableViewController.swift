

import UIKit
import CoreData
 
class SignUpTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    @IBOutlet weak var iAmBidderBtn: UIButton!
    @IBOutlet weak var iAmSellerBtn: UIButton!
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var createPasswordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    
    let imagePicker = UIImagePickerController()
    var iAm = "";
    var iAmCode: Int32 = 0;
    
    override func viewDidLoad() {
                super.viewDidLoad()
                // Do any additional setup after loading the view.
                imagePicker.delegate = self
            }

    @IBAction func iAmBidder(_ sender: Any) {
        iAm = "Bidder"
        iAmCode = 1
        iAmBidderBtn.backgroundColor = .green
        iAmSellerBtn.backgroundColor = nil
    }
    
    @IBAction func iAmSeller(_ sender: Any) {
        iAm = "Seller"
        iAmCode = 2
        iAmSellerBtn.backgroundColor = .green
        iAmBidderBtn.backgroundColor =  nil
    }
    
    @IBAction func createAccount(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequestEmail: NSFetchRequest<UserProfileData> = UserProfileData.fetchRequest()
        fetchRequestEmail.predicate = NSPredicate(format: "useremail == %@", emailTF.text!)

        do {
            let matchingEmailUsers = try context.fetch(fetchRequestEmail)
            if !matchingEmailUsers.isEmpty {
                // Email already exists, display an alert
                let alertController = UIAlertController(title: "Email Already Registered", message: "The entered email is already registered. Please use a different email or login if you already have an account.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
                return
            }
        } catch {
            print("Error fetching user data: \(error)")
        }
       
            
            
            // Create a new User object
            let newUser = UserProfileData(context: context)
            newUser.userid = UUID() // Assign a new UUID for the userid attribute
            newUser.username = userNameTF.text
            newUser.useremail = emailTF.text
            newUser.userpassword = createPasswordTF.text
            newUser.usertype = iAm
            newUser.usertypecode = iAmCode
            newUser.usercreationdate = Date()
            newUser.userstatus = true
            
            // Convert the image to Data and save it to the image attribute
            if let userImage = imageView.image {
                newUser.userimage = userImage.pngData() // Convert UIImage to Data and save it
            }
            
            // Save the context
            do {
                try context.save()
                print("User data saved successfully")
                
                // Fetch the user who just created their profile
                        let fetchRequest: NSFetchRequest<UserProfileData> = UserProfileData.fetchRequest()
                
                        fetchRequest.predicate = NSPredicate(format: "userid == %@", newUser.userid! as CVarArg)
                        
                        if let currentUser = try context.fetch(fetchRequest).first {
                            // Instantiate the detail view controller
                            let userDetailVC = storyboard?.instantiateViewController(withIdentifier: "CreatedUserTableViewController") as! CreatedUserTableViewController
                            
                            // Pass data to the detail view controller
                            userDetailVC.nuserName = currentUser.username
                            userDetailVC.nuserEmail = currentUser.useremail
                            userDetailVC.nuserType = currentUser.usertype
                            if let imageData = currentUser.userimage {
                                userDetailVC.nuserImage = UIImage(data: imageData)
                            }
                            
                            // Present the detail view controller
                            navigationController?.pushViewController(userDetailVC, animated: true)
                            dismiss(animated: true, completion: nil)
                                    
                            // Remove the back button
                            navigationController?.viewControllers = [userDetailVC]
                        } else {
                            print("User not found")
                        }
                    } catch {
                        print("Error saving user data: \(error)")
                    }

            
    }
    
    
    
    
    
    
    
    
    
    @IBAction func selectPhotoButtonTapped(_ sender: UIButton) {
                imagePicker.sourceType = .photoLibrary
                present(imagePicker, animated: true, completion: nil)
            }
            
            // MARK: - UIImagePickerControllerDelegate Methods
            
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    imageView.image = selectedImage
                }
                dismiss(animated: true, completion: nil)
            }
            
            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                dismiss(animated: true, completion: nil)
            }
        }

        
        
        
        
        
        
        
        

