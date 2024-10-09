
import UIKit
import CoreData


class WalletViewController: UIViewController, UITextFieldDelegate {
    let loggedInUserID = UserDefaults.standard.string(forKey: "loggedInUserID")
    
    var depositCompletion: ((WalletData) -> Void)?
    
    @IBOutlet weak var unHoldBal: UILabel!
    @IBOutlet weak var holdBal: UILabel!
    @IBOutlet weak var totalBal: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userIdToFetch = UUID(uuidString: loggedInUserID!)!
        fetchWalletData(forUserId: userIdToFetch)

       
    }
    

    @IBAction func depositBtn(_ sender: UIButton) {
        
        
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<WalletData> = WalletData.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "walletUserId == %@", loggedInUserID! as CVarArg)

            do {
                let walletData = try context.fetch(fetchRequest)
                if walletData.isEmpty {
                    print("No wallet data found for user ID: \(String(describing: loggedInUserID))")
                    
                      
                            let contextDeposit = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                            let alertController = UIAlertController(title: "Add Money", message: "EnterAmount:", preferredStyle: .alert)
                            alertController.addTextField { textField in
                                textField.placeholder = "Amount"
                                textField.keyboardType = .numberPad
                                textField.delegate = self // Set delegate
                            }
                            
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                            
                        let okAction = UIAlertAction(title: "Deposit", style: .default) { [self]  _ in
                                if let textField = alertController.textFields?.first,
                                   let text = textField.text,
                                   let newDepositAmount = Double(text) {
                                    print("Entered amount: \(newDepositAmount)")
                                    
                                    let fetchRequest: NSFetchRequest<WalletData> = WalletData.fetchRequest()

                                    do {
                                        let newWalletData = WalletData(context: contextDeposit)
                                        newWalletData.walletId = UUID() // Set a new UUID for the wallet ID
                                        newWalletData.walletUserId = UUID(uuidString: loggedInUserID!) // Set the user ID
                                    
                                        newWalletData.walletTotalBalance = newDepositAmount
                                        newWalletData.walletUnHoldBalance = newWalletData.walletTotalBalance - newWalletData.walletHoldBalance
 
                                        try context.save()
                                        print("Wallet Created and Balance updated successfully!")
                                        
                                        if let completion = self.depositCompletion {
                                            completion(newWalletData)
                                        }
                                    }
                                         catch {
                                            print("Error updating wallet data: \(error)")
                                        }
                                    }
                                }
                            
                            alertController.addAction(cancelAction)
                            alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                         
                    
                
                    
                }
                else
                {
                  
                        let contextDeposit = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                        let alertController = UIAlertController(title: "Add Money", message: "EnterAmount:", preferredStyle: .alert)
                        alertController.addTextField { textField in
                            textField.placeholder = "Amount"
                            textField.keyboardType = .numberPad
                            textField.delegate = self // Set delegate
                        }
                        
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        
                    let okAction = UIAlertAction(title: "Deposit", style: .default) { [self]  _ in
                            if let textField = alertController.textFields?.first,
                               let text = textField.text,
                               let newDepositAmount = Double(text) {
                                print("Entered amount: \(newDepositAmount)")
                                
                                let fetchRequest: NSFetchRequest<WalletData> = WalletData.fetchRequest()
                                fetchRequest.predicate = NSPredicate(format: "walletUserId == %@", loggedInUserID! as CVarArg)
                                
                                do {
                                        if let walletData = try contextDeposit.fetch(fetchRequest).first {
                                            walletData.walletTotalBalance += newDepositAmount
                                            walletData.walletUnHoldBalance = walletData.walletTotalBalance - walletData.walletHoldBalance
                                            try context.save()
                                            print("Wallet Balance updated successfully!")
                                            if let completion = self.depositCompletion {
                                                                        completion(walletData)
                                                                    }
                                            
                                        } else {
                                            print("Wallet data not found for the logged-in user.")
                                        }
                                    } catch {
                                        print("Error updating wallet data: \(error)")
                                    }
                                
                                  
                                }
                            }
                        
                        alertController.addAction(cancelAction)
                        alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                  
                   
                
            }
                
                
        } catch {
            print("Failed to fetch wallet data for user ID \(String(describing: loggedInUserID)): \(error)")
        }
        
        depositCompletion = { [weak self] updatedWalletData in
            guard let self = self else { return }
            // Update UI with new balance
            self.unHoldBal.text = String(updatedWalletData.walletUnHoldBalance)
            self.holdBal.text = String(updatedWalletData.walletHoldBalance)
            self.totalBal.text = String(updatedWalletData.walletTotalBalance)
        }
        
       
        

        
} // end of deposit button


    
    @IBAction func withdrawBtn(_ sender: Any) {
        
        
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<WalletData> = WalletData.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "walletUserId == %@", loggedInUserID! as CVarArg)

            do {
                let walletData = try context.fetch(fetchRequest)

                        let contextDeposit = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                        let alertController = UIAlertController(title: " Withdraw Money ", message: "Enter Amount:", preferredStyle: .alert)
                        alertController.addTextField { textField in
                            textField.placeholder = "Amount"
                            textField.keyboardType = .numberPad
                            textField.delegate = self // Set delegate
                        }
                        
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        
                    let okAction = UIAlertAction(title: "Withdraw", style: .default) { [self]  _ in
                            if let textField = alertController.textFields?.first,
                               let text = textField.text,
                               let withdrawAmount = Double(text) {
                                print("Entered amount: \(withdrawAmount)")
                                
                                let fetchRequest: NSFetchRequest<WalletData> = WalletData.fetchRequest()
                                fetchRequest.predicate = NSPredicate(format: "walletUserId == %@", loggedInUserID! as CVarArg)
                                
                                do {
                                        if let walletData = try contextDeposit.fetch(fetchRequest).first {
                                            if withdrawAmount <= walletData.walletUnHoldBalance {
                                                walletData.walletUnHoldBalance -= withdrawAmount
                                                walletData.walletTotalBalance = walletData.walletUnHoldBalance + walletData.walletHoldBalance
                                                try context.save()
                                                print("Withdraw successfully!")
                                                if let completion = self.depositCompletion {
                                                    completion(walletData)
                                                }
                                            }
                                            else
                                            {
                                                let message = " Insufficient Balance ! "
                                                let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                                                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                                   present(alertController, animated: true, completion: nil)
                                            }
                                            
                                        } else {
                                            print("Wallet data not found for the logged-in user.")
                                        }
                                    } catch {
                                        print("Error updating wallet data: \(error)")
                                    }
                                }
                            }
                        
                        alertController.addAction(cancelAction)
                        alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)

                
        } catch {
            print("Failed to fetch wallet data for user ID \(String(describing: loggedInUserID)): \(error)")
        }
        
        depositCompletion = { [weak self] updatedWalletData in
            guard let self = self else { return }
            // Update UI with new balance
            self.unHoldBal.text = String(updatedWalletData.walletUnHoldBalance)
            self.holdBal.text = String(updatedWalletData.walletHoldBalance)
            self.totalBal.text = String(updatedWalletData.walletTotalBalance)
        }
        
       
        

        
}
    
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacterSet = CharacterSet(charactersIn: "0123456789")
        let typedCharacterSet = CharacterSet(charactersIn: string)
        return allowedCharacterSet.isSuperset(of: typedCharacterSet)
    }
    
    func fetchWalletData(forUserId userId: UUID) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<WalletData> = WalletData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "walletUserId == %@", userId as CVarArg)

        do {
            let walletData = try context.fetch(fetchRequest)
            
            if walletData.isEmpty {
                print("No wallet data found for user ID: \(userId)")
            } else {
                for data in walletData {
                    print("Wallet ID: \(data.walletId ?? UUID())")
                    print("User ID: \(data.walletUserId ?? UUID())")
               
                    print("Total Balance: \(data.walletTotalBalance)")
         
                    print("Hold Balance: \(data.walletHoldBalance)")
                    print("UnHold Balance: \(data.walletUnHoldBalance)")
                    print("-------------------------")
                    unHoldBal.text = String(data.walletUnHoldBalance)
                    holdBal.text = String(data.walletHoldBalance)
                    totalBal.text = String(data.walletTotalBalance)
                }
            }
        } catch {
            print("Failed to fetch wallet data for user ID \(userId): \(error)")
        }
    }
    
}
