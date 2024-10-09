

import UIKit
import CoreData

class AvailableAuctionsViewController: UIViewController , UITextFieldDelegate{
    
    @IBOutlet weak var AACollectionView: UICollectionView!  //====Attachment of collectionView with View Controller
    let loggedInUserID = UserDefaults.standard.string(forKey: "loggedInUserID")
    
    let auctionTime = globalCode.auctionTime
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAllAcutions()
    } // End of View Did Load

    
    func fetchAllAcutions(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequestProduct = NSFetchRequest<AddedProductData>(entityName: "AddedProductData")
        let now = Date()
        let oneHourAgo = Calendar.current.date(byAdding: .minute, value: -auctionTime, to: Date())!
         fetchRequestProduct.predicate = NSPredicate(format: "productAuctionDateTime >= %@ AND productAuctionDateTime <= %@",  oneHourAgo as NSDate, now as NSDate)
        
        do {
            let liveAuctions = try context.fetch(fetchRequestProduct)
                if liveAuctions.isEmpty {
                    globalNoDataEmoji(on: self.view)
                }
        }
        catch{
            print ("Error Fetching Auctions")
        }
    }
    
    
    @IBAction func placeAbidBtn(_ sender: UIButton)
    {
        guard let cell = sender.superview?.superview?.superview?.superview as? AvailableAuctionsCollectionViewCell,
              let indexPath = AACollectionView.indexPath(for: cell) else {
            print("Failed to get indexPath for place bid button")
            return
        }
        let contextPlaceBid = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        
        
        
        
        let fetchRequest: NSFetchRequest<WalletData> = WalletData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "walletUserId == %@", loggedInUserID! as CVarArg)

        do {
            let walletData = try contextPlaceBid.fetch(fetchRequest)
            
            if walletData.isEmpty {
                let message = "You have No Deposit Monery in Wallet "
                let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
               present(alertController, animated: true, completion: nil)
  
            } 
            else
            {
                let walletDetail = walletData.first!
                    print("Wallet ID: \(walletDetail.walletId ?? UUID())")
                    print("User ID: \(walletDetail.walletUserId ?? UUID())")
                    print("Total Balance: \(walletDetail.walletTotalBalance)")
                    print("Hold Balance: \(walletDetail.walletHoldBalance)")
                    print("UnHold Balance: \(walletDetail.walletUnHoldBalance)")
                    print("-------------------------")
                let alertController = UIAlertController(title: "Place A Bid. ", message: "Your Have \(walletDetail.walletUnHoldBalance) Unhold Balance in Wallet.  Enter Your Bid Amount:", preferredStyle: .alert)
                alertController.addTextField { textField in
                    textField.placeholder = "Amount"
                    textField.keyboardType = .numberPad
                    textField.delegate = self // Set delegate
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                let okAction = UIAlertAction(title: "OK", style: .default) { [self] _ in
                    if let textField = alertController.textFields?.first,
                       let text = textField.text,
                       let bidAmt = Int(text) {
                        print("Entered amount: \(bidAmt)")
                        
                        if bidAmt <= Int(walletDetail.walletUnHoldBalance) {
                            deleteBidByUser(sender: sender) // caling to delete previous bid function for delete previous bid on this produc by this user
                            
                            let newBid = BidsData(context: contextPlaceBid)
                            newBid.bidID = UUID()
                            newBid.bidAmount = Int64(bidAmt)
                            newBid.biderID = UUID(uuidString: loggedInUserID!)
                            newBid.bidPlaced = true
                            if let product = getProductForIndexPath(indexPath) {
                                    newBid.bidProductID = product.productID
                                    newBid.bidProductName = product.productName
                                    newBid.bidProductImage = product.productImage
                                    newBid.bidAuctionStartDateTime = product.productAuctionDateTime
                                newBid.bidProductOwnerId = product.productOwnerId
                                print ("Bid Product Owner Id \(product.productSubmitBy)")
                           
                            do {
                                try contextPlaceBid.save()
                                print("Bid Saved Successfully")
                                
                                let contextUpdateBal = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                                let fetchRequest: NSFetchRequest<WalletData> = WalletData.fetchRequest()
                                fetchRequest.predicate = NSPredicate(format: "walletUserId == %@", loggedInUserID! as CVarArg)
                                
                                do {
                                        if let walletData = try contextUpdateBal.fetch(fetchRequest).first {
                                          
                                            walletData.walletHoldBalance += Double(bidAmt)
                                            walletData.walletUnHoldBalance -= Double(bidAmt)
                                            try contextUpdateBal.save()
                                            print("Wallet Balance updated successfully!")
                                            
                                            
                                        } else {
                                            print("Wallet data not found for the logged-in user.")
                                        }
                                    } catch {
                                        print("Error updating wallet data: \(error)")
                                    }
                                
                                
                                if let indexPath = AACollectionView.indexPath(for: cell) {
                                    AACollectionView.reloadItems(at: [indexPath])
                                }
                            } catch {
                                print("Error saving bid: \(error)")
                            }
                        }
                    }
                     else
                        {
                         let message = " Insufficient Balance ! "
                         let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                         alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            present(alertController, animated: true, completion: nil)
                         
                     }
                        
                    }
                }
                

                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                
                
                if let viewController = UIApplication.shared.keyWindow?.rootViewController {
                    viewController.present(alertController, animated: true, completion: nil)
                } else {
                    print("Failed to access root view controller")
                }
           
                
            }
            
            
            
            
            
        }
        catch
        {
            print ("Error Loading Wallet Balance")
        }
            
            
            
            
            
            

        

        
    }// end of place a bid button
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacterSet = CharacterSet(charactersIn: "0123456789")
        let typedCharacterSet = CharacterSet(charactersIn: string)
        return allowedCharacterSet.isSuperset(of: typedCharacterSet)
    } // end of function supports only number in alwrtr text field
    
    
    
    
     func getProductForIndexPath(_ indexPath: IndexPath) -> AddedProductData? {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let fetchRequestProduct = NSFetchRequest<AddedProductData>(entityName: "AddedProductData")
           
            let now = Date()
         let oneHourAgo = Calendar.current.date(byAdding: .minute, value: Int(-auctionTime), to: Date())!
             fetchRequestProduct.predicate = NSPredicate(format: "productAuctionDateTime >= %@ AND productAuctionDateTime <= %@",  oneHourAgo as NSDate, now as NSDate)
         
           // fetchRequestProduct.predicate = NSPredicate(format: "productAuctionDateTime < %@", currentDate as NSDate)

            do {
                let products = try context.fetch(fetchRequestProduct)
                // Ensure index path is within bounds
                if indexPath.row < products.count {
                    return products[indexPath.row]
                } else {
                    print("Index out of bounds")
                    return nil
                }
            } catch {
                print("Error fetching product: \(error)")
                return nil
            }
        } // end of getPrdouctForIndexPath function
        
    
    
    
    
    
    
    
    
    
    @IBAction func updateBidBtn(_ sender: UIButton) {
        placeAbidBtn(sender)
    }
    
    
    @IBAction func cancelBidBtn(_ sender: UIButton) {
       
        let alertController = UIAlertController(title: "Cancel Bid", message: "Are you sure you want to cancel your bid?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { (_) in
            self.deleteBidByUser(sender: sender)
            
            guard let cell = sender.superview?.superview?.superview?.superview as? AvailableAuctionsCollectionViewCell,
                  let indexPath = self.AACollectionView.indexPath(for: cell) else {
                print("Failed to get indexPath for place bid button")
                return
            }
            self.AACollectionView.reloadItems(at: [indexPath])
        }
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true, completion: nil)
        
    } // end of cancelBidBtn

    
    
    func deleteBidByUser(sender : UIButton)
    {
        guard let cell = sender.superview?.superview?.superview?.superview as? AvailableAuctionsCollectionViewCell,
            let indexPath = AACollectionView.indexPath(for: cell),
            let product = getProductForIndexPath(indexPath) else {
                print("Failed to get indexPath for place bid button")
                return
        }

                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let fetchRequestAllBids = NSFetchRequest<BidsData>(entityName: "BidsData")

                // Convert productID to string before using it in NSPredicate
                if let productID = product.productID?.uuidString {
                    fetchRequestAllBids.predicate = NSPredicate(format: "bidProductID == %@ AND biderID == %@ ", productID , loggedInUserID!)
                } else {
                    
                    print("Error: productID is nil")
                    return
                }
                

                do {
                
                    let allBids = try context.fetch(fetchRequestAllBids)
                    for bid in allBids {
                        context.delete(bid)
                        print(" Bid Deleted ")
                        let bidAmount = bid.bidAmount
                        let contextUpdateBal = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                        let fetchRequest: NSFetchRequest<WalletData> = WalletData.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "walletUserId == %@", loggedInUserID! as CVarArg)
                        
                        do {
                                if let walletData = try contextUpdateBal.fetch(fetchRequest).first {
                                  
                                    walletData.walletHoldBalance -= Double(bidAmount)
                                    walletData.walletUnHoldBalance += Double(bidAmount)
                                    try contextUpdateBal.save()
                                    print("Wallet Balance updated successfully!")
                                    
                                    
                                } else {
                                    print("Wallet data not found for the logged-in user.")
                                }
                            } catch {
                                print("Error updating wallet data: \(error)")
                            }
                    }
                    try context.save()
                   
                    
                } catch let error as NSError {
                    print("Error fetching all bids: \(error), \(error.userInfo)")
                }

        
    } // end of delete previous bid function
    
    //======================================================================================================================
        
        func remainingTime(to date: Date) -> TimeInterval {
            
            let currentDate = Date()
            
            return date.timeIntervalSince(currentDate)
        }
        
        // Function to format time interval as a string
    func stringFromTimeInterval(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: interval)!
    }

    
        
} // End of Class
    
    
    
    




    extension AvailableAuctionsViewController: UICollectionViewDelegate, UICollectionViewDataSource
    {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let fetchRequestProduct = NSFetchRequest<AddedProductData>(entityName: "AddedProductData")
            let currentDate = Date()
            
            let now = Date()
            let oneHourAgo = Calendar.current.date(byAdding: .minute, value: -auctionTime, to: Date())!
             fetchRequestProduct.predicate = NSPredicate(format: "productAuctionDateTime >= %@ AND productAuctionDateTime <= %@",  oneHourAgo as NSDate, now as NSDate)
            
          //  fetchRequestProduct.predicate = NSPredicate(format: "productAuctionDateTime < %@", currentDate as NSDate)
            var itemsCount = 0
            do {
                
                itemsCount = try context.count(for: fetchRequestProduct)
                print(itemsCount)
                return itemsCount
            }
            catch{
                print("Product not fetched")
            }
            return itemsCount
        }
        
        
//*************************************************************************************************
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = AACollectionView.dequeueReusableCell(withReuseIdentifier: "CVCell", for: indexPath) as! AvailableAuctionsCollectionViewCell
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let fetchRequestProduct = NSFetchRequest<AddedProductData>(entityName: "AddedProductData")
            let now = Date()
            let oneHourAgo = Calendar.current.date(byAdding: .minute, value: -auctionTime, to: Date())!
             fetchRequestProduct.predicate = NSPredicate(format: "productAuctionDateTime >= %@ AND productAuctionDateTime <= %@",  oneHourAgo as NSDate, now as NSDate)
            
         // fetchRequestProduct.predicate = NSPredicate(format: "productAuctionDateTime < %@", currentDate as NSDate)
            
            let fetchRequestBidsByUser = NSFetchRequest<BidsData>(entityName: "BidsData")
            fetchRequestBidsByUser.predicate = NSPredicate(format: "biderID == %@", loggedInUserID!)
            
            
            
            do {
                let products = try context.fetch(fetchRequestProduct)
                let userBids = try context.fetch(fetchRequestBidsByUser)
                
                // Ensure index path is within bounds
                guard indexPath.row < products.count else {
                    print("Index out of bounds")
                    return cell
                }
                
                let product = products[indexPath.row]
                
                // Check if the user has bid on this product
                if let bid = userBids.first(where: { $0.bidProductID == product.productID }) {
                    // If the user has bid on the product, display bid information
                    cell.cancelBidBtn.isHidden = false
                    cell.placeBidBtn.isHidden = true
                    cell.updateBidBtn.isHidden = false
                    
                    cell.AAProductName.text = product.productName
                    cell.AAProductPrice.text = String(product.productMinPrice)
                    cell.AAListedBy.text = product.productSubmitBy
                    
                    let fetchRequestBidsOnProduct = NSFetchRequest<BidsData>(entityName: "BidsData")
                    fetchRequestBidsOnProduct.predicate = NSPredicate(format: "bidProductID == %@", product.productID! as CVarArg)
                    let bidCounter = try context.count(for: fetchRequestBidsOnProduct)
                    cell.AAPlacedBids.text = "\(bidCounter)"
                    
                    let fetchRequestHighestBidAmt = NSFetchRequest<BidsData>(entityName: "BidsData")
                    fetchRequestHighestBidAmt.predicate = NSPredicate(format: "bidProductID == %@", product.productID! as CVarArg)

                    do {
                        let allBidsForProduct = try context.fetch(fetchRequestHighestBidAmt)
                        if let highestBid = allBidsForProduct.max(by: { $0.bidAmount < $1.bidAmount }) {
                            cell.AAHighestBid.text = "\(highestBid.bidAmount)"
                        } else {
                            // No bids found for the product
                            cell.AAHighestBid.text = "No bids"
                        }
                    } catch {
                        print("Error fetching highest bid amount: \(error)")
                    }
                    
                    let auctionLiveTime = product.productAuctionDateTime
                    let oneHourFromNow = Calendar.current.date(byAdding: .minute, value: auctionTime, to: auctionLiveTime!) ?? auctionLiveTime
                         if let auctionDateTime = oneHourFromNow {
                             Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] timer in
                                 let remainingTime = self.remainingTime(to: auctionDateTime)
                                 if remainingTime <= 0 {
                                     // Auction has started, update UI accordingly
                                     cell.AAEndIn.text = "Auction has Ended!"
                                     timer.invalidate() // Stop the timer
                                     
                                     if let indexPath = AACollectionView.indexPath(for: cell) {
                                         AACollectionView.reloadData()
                                     }
                                     
                                 } else {
                                     // Update the label with remaining time
                                     cell.AAEndIn.text = self.stringFromTimeInterval(remainingTime)
                                    
                                 }
                             }
                         } else {
                             // Handle the case where productAuctionDateTime is nil
                             cell.AAEndIn.text = "Auction time not specified"
                         }

              
                    cell.mybidAmt.text = " \(bid.bidAmount)"
                    
                    if let imageData = product.productImage,  let productImage = UIImage(data: imageData)
                    {
                        cell.AAProductImage.image = productImage
                    } else {
                        cell.AAProductImage.image = UIImage(named: "PRODUCT IMAGE")
                    }

                    
                    
                    
                    
                    
                } else {
                    
                    // If the user has not bid on the product, display default information
                    cell.cancelBidBtn.isHidden = true
                    cell.updateBidBtn.isHidden = true
                    cell.placeBidBtn.isHidden = false
                    
                    cell.placeBidBtn.setTitle(" Place a Bid ", for: .normal)
                    cell.AAProductName.text = product.productName
                    cell.AAProductPrice.text = String(product.productMinPrice)
                    cell.AAListedBy.text = product.productSubmitBy
                    
                    let fetchRequestHighestBidAmt = NSFetchRequest<BidsData>(entityName: "BidsData")
                    fetchRequestHighestBidAmt.predicate = NSPredicate(format: "bidProductID == %@", product.productID! as CVarArg)

                    do {
                        let allBidsForProduct = try context.fetch(fetchRequestHighestBidAmt)
                        if let highestBid = allBidsForProduct.max(by: { $0.bidAmount < $1.bidAmount }) {
                            cell.AAHighestBid.text = "\(highestBid.bidAmount)"
                        } else {
                            // No bids found for the product
                            cell.AAHighestBid.text = "No bids"
                        }
                    } catch {
                        print("Error fetching highest bid amount: \(error)")
                    }
                    
                    
                    let auctionLiveTime = product.productAuctionDateTime
                    let oneHourFromNow = Calendar.current.date(byAdding: .minute, value: auctionTime, to: auctionLiveTime!) ?? auctionLiveTime
                         if let auctionDateTime = oneHourFromNow {
                             Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                                 let remainingTime = self.remainingTime(to: auctionDateTime)
                                 if remainingTime <= 0 {
                                     // Auction has started, update UI accordingly
                                     cell.AAEndIn.text = "Auction has Ended!"
                                     timer.invalidate() // Stop the timer
                                 } else {
                                     // Update the label with remaining time
                                     cell.AAEndIn.text = self.stringFromTimeInterval(remainingTime)
                                    
                                 }
                             }
                         } else {
                             // Handle the case where productAuctionDateTime is nil
                             cell.AAEndIn.text = "Auction time not specified"
                         }


                    
                    let fetchRequestBidsOnProduct = NSFetchRequest<BidsData>(entityName: "BidsData")
                    fetchRequestBidsOnProduct.predicate = NSPredicate(format: "bidProductID == %@", product.productID! as CVarArg)
                    let bidCounter = try context.count(for: fetchRequestBidsOnProduct)
                    cell.AAPlacedBids.text = "\(bidCounter)"
                    
                    cell.mybidAmt.text = "Not Bid Placed"
                    
                    if let imageData = product.productImage,  let productImage = UIImage(data: imageData)
                    {
                        cell.AAProductImage.image = productImage
                    } else {
                        cell.AAProductImage.image = UIImage(named: "PRODUCT IMAGE")
                    }
                    

                }
                
                
                
            } catch {
                print("Error fetching products: \(error)")
            }
            
            cell.layer.cornerRadius = 10
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.blue.cgColor
            
            return cell
        }


} // End of extension

