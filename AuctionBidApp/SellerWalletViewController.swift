//
//  SellerWalletViewController.swift
//  AuctionBidApp
//
//  Created by user256708 on 4/28/24.
//

import UIKit
import CoreData

class SellerWalletViewController: UIViewController, UITextFieldDelegate {
    
    let loggedInUserID = UserDefaults.standard.string(forKey: "loggedInUserID")
    
    @IBOutlet weak var saleAmount: UILabel!
    
    @IBOutlet weak var withdrawAmount: UILabel!
    
    @IBOutlet weak var availableBalance: UILabel!
    
    var depositCompletion: ((SellersWalletData) -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userIdToFetch = UUID(uuidString: loggedInUserID!)!
        fetchWalletData(forUserId: userIdToFetch)
    }
    

  
    @IBAction func WithdraBtn(_ sender: Any) {
        

                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let fetchRequest: NSFetchRequest<SellersWalletData> = SellersWalletData.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "sellerWalletId == %@", loggedInUserID! as CVarArg)

                do {
                    let walletData = try context.fetch(fetchRequest)

                            let contextWithdraw = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
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
                                    
                                    let fetchRequest: NSFetchRequest<SellersWalletData> = SellersWalletData.fetchRequest()
                                    fetchRequest.predicate = NSPredicate(format: "sellerWalletId == %@", loggedInUserID! as CVarArg)
                                    
                                    do {
                                            if let walletData = try contextWithdraw.fetch(fetchRequest).first {
                                                if withdrawAmount <= walletData.sellerWalletBalance {
                                                    
                                                    walletData.sellerWalletBalance -= withdrawAmount
                                                    walletData.sellterWalletWithdrawAmount += withdrawAmount
                                                    try contextWithdraw.save()
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
          
                self.withdrawAmount.text = String(updatedWalletData.sellterWalletWithdrawAmount)
                self.availableBalance.text = String(updatedWalletData.sellerWalletBalance)
                                
                
            }
            
           
            

            
    }
        
        
        
        
        
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacterSet = CharacterSet(charactersIn: "0123456789")
        let typedCharacterSet = CharacterSet(charactersIn: string)
        return allowedCharacterSet.isSuperset(of: typedCharacterSet)
    }
    
    func fetchWalletData(forUserId userId: UUID) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<SellersWalletData> = SellersWalletData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sellerWalletId == %@", userId as CVarArg)

        do {
            let walletData = try context.fetch(fetchRequest)
            
            if walletData.isEmpty {
                print("No wallet data found for user ID: \(userId)")
                saleAmount.text = "0"
                withdrawAmount.text =  "0"
                availableBalance.text =  "0"
            } else {
                for data in walletData {
                    print("Wallet ID: \(data.sellerWalletId ?? UUID())")

                    print("Total sale Amount : \(data.sellterWalletSaleAmount)")
         
                    print("Withdran: \(data.sellterWalletWithdrawAmount)")
                    print("wallet  Balance: \(data.sellerWalletBalance)")
                    print("-------------------------")
                   
                    saleAmount.text = String (data.sellterWalletSaleAmount)
                    withdrawAmount.text = String(data.sellterWalletWithdrawAmount)
                    availableBalance.text = String(data.sellerWalletBalance)
                }
            }
        } catch {
            print("Failed to fetch wallet data for user ID \(userId): \(error)")
           
        }
    }
    
    
    
}
