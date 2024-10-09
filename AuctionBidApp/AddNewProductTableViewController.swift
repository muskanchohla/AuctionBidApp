//
//  AddNewProductTableViewController.swift
//  AuctionBidApp
//
//  Created by user254754 on 3/30/24.
//

import UIKit
import CoreData

class AddNewProductTableViewController: UITableViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var newProductName: UITextField!
    
    @IBOutlet weak var newProductImg: UIImageView!
    @IBOutlet weak var newProductMinPrice: UITextField!
    @IBOutlet weak var auctionStartDate: UIDatePicker!
    @IBOutlet weak var auctionStartTime: UIDatePicker!
    
    @IBOutlet weak var imgChooseBtn: UIButton!
    
    @IBOutlet weak var instantAuctionUI: UIButton!
    @IBOutlet weak var sessionAuctionUI: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        return appDelegate.persistentContainer.viewContext
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        newProductMinPrice.delegate = self
      
    }
    
    @IBAction func submitBtn(_ sender: Any) {
        saveProductData()
    }
    
    
    @IBAction func sessionAuctionBtn(_ sender: Any) {
        sessionAuctionUI.backgroundColor = .green
        instantAuctionUI.backgroundColor = nil
        auctionStartDate.isEnabled = true
        auctionStartTime.isEnabled = true
        
    }
    @IBAction func instantAuctionBtn(_ sender: Any) {
        instantAuctionUI.backgroundColor = .green
        sessionAuctionUI.backgroundColor = nil
        auctionStartDate.isEnabled = false
        auctionStartTime.isEnabled = false
        auctionStartDate.setDate(Date(), animated: true)
        auctionStartTime.setDate(Date(), animated: true)
        showAlert(title: "INFO", message: "Auction wil be start within 1 minute  after submit")
    }
    
    @IBAction func chooseNewProductBtn(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func cancelBtn(_ sender: Any) {
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
    
    
    
    
    // function for save data ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    func saveProductData() {
        
        guard let loggedInUserID = UserDefaults.standard.string(forKey: "loggedInUserID") else {
            print("Logged-in User ID not found")
            return
        }
        print(loggedInUserID)
        
        if let loggedUser = fetchLoggedUser(userid: loggedInUserID) {
            // Update UI on the main thread
            
            print("Logged-in User ID: \(loggedInUserID)")
            
            
            
            
            guard let productName = newProductName.text,
                  let minPriceText = newProductMinPrice.text,
                  let minPrice = Double(minPriceText),
                  let productImage = newProductImg.image?.pngData() else {
                return
            }
            
            
            let newProduct = AddedProductData(context: managedObjectContext)
          
            newProduct.productSubmitBy = loggedUser.username
            newProduct.productID = UUID()
            newProduct.productOwnerId = loggedUser.userid
            newProduct.productName = productName
            newProduct.productMinPrice = minPrice
            newProduct.productImage = productImage
            newProduct.saleStatus = "Not Soled Yet"
            
            // Format the date to "dd/MM/yyyy" (day/month/year) string
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let dateStringForAuctionStart = dateFormatter.string(from: auctionStartDate.date)
            // Convert the formatted string back to a Date object
            newProduct.productAuctionDate = dateFormatter.date(from: dateStringForAuctionStart)
            
            let calendar = Calendar.current
            let timeComponentForAuctionTime = calendar.dateComponents([.hour, .minute, .second], from: auctionStartTime.date)
            newProduct.productAuctionTime = calendar.date(from: timeComponentForAuctionTime)
            
       
            
            
            
          

            // Convert the formatted string back to a Date object
            if let auctionStartDate = dateFormatter.date(from: dateStringForAuctionStart) {
                let calendar = Calendar.current
                
                // Extract time components from the auction start time
                let timeComponentForAuctionTime = calendar.dateComponents([.hour, .minute, .second], from: auctionStartTime.date)
                
                // Combine date and time components
                if let auctionTime = calendar.date(bySettingHour: timeComponentForAuctionTime.hour ?? 0, minute: timeComponentForAuctionTime.minute ?? 0, second: timeComponentForAuctionTime.second ?? 0, of: auctionStartDate) {
                    
                    // Set the auction date and time
                    newProduct.productAuctionDateTime = auctionTime
                } else {
                    print("Error: Unable to create auction time")
                }
            } else {
                print("Error: Unable to create auction start date")
            }

            
            
            
            let dateForProductSubmit = dateFormatter.string(from: Date())
            // Convert the formatted string back to a Date object
            newProduct.productSubmitDate = dateFormatter.date(from: dateForProductSubmit)
            
            let timeForProductSubmit = calendar.dateComponents([.hour, .minute, .second], from: auctionStartTime.date)
            newProduct.productAuctionTime = calendar.date(from: timeForProductSubmit)
            
            
            
            
        } else {
            print("Failed to fetch logged-in user profile")
        }
        
        
        do {
            try managedObjectContext.save()
            print("Product data saved successfully")
            showAlert(title: "Success", message: "Product Added Successfully")
            resetFields()
            
        } catch {
            print("Failed to save product data: \(error)")
            showAlert(title: "Failed", message: "Failed to Add Product")
            
            
            
        }
    }
    
    // function for show Alert ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            newProductImg.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
           let allowedCharacters = CharacterSet(charactersIn: "0123456789")
           let characterSet = CharacterSet(charactersIn: string)
           return allowedCharacters.isSuperset(of: characterSet)
       }
    
    
}// end of class

    extension AddNewProductTableViewController {
        
        func resetFields() {
            newProductName.text = ""
            newProductImg.image = nil
            newProductMinPrice.text = ""
            auctionStartDate.setDate(Date(), animated: true)
            auctionStartTime.setDate(Date(), animated: true)
            instantAuctionUI.backgroundColor = nil
            sessionAuctionUI.backgroundColor = nil
        }
        
    }
