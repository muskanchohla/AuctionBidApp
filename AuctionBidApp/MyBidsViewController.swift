

import UIKit
import CoreData

class MyBidsViewController: UIViewController , UITextFieldDelegate {
    let loggedInUserID = UserDefaults.standard.string(forKey: "loggedInUserID")
    
    @IBOutlet weak var MBCollectionView: UICollectionView!
    
    let auctionTime = globalCode.auctionTime
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMyBids()
      
    }
    


    func updateBidPrice(for biduid : UUID) {

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
                        
                        if bidAmt < Int(walletDetail.walletUnHoldBalance) {

                            do {
                                let fetchRequest: NSFetchRequest<BidsData> = BidsData.fetchRequest()
                                fetchRequest.predicate = NSPredicate(format: "bidID == %@", biduid as CVarArg)
                                
                                if let bidData = try contextPlaceBid.fetch(fetchRequest).first {
                                    let previousBidAmt = bidData.bidAmount
                                    bidData.bidAmount = Int64(bidAmt)
                                    
                                    try contextPlaceBid.save()
                                    print("Bid amount updated successfully!")
                                    
                                    
                                    
                                    
                                    let contextUpdateBal = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                                    let fetchRequestWallet: NSFetchRequest<WalletData> = WalletData.fetchRequest()
                                    fetchRequestWallet.predicate = NSPredicate(format: "walletUserId == %@", loggedInUserID! as CVarArg)
                                    
                                    do {
                                        if let walletData = try contextUpdateBal.fetch(fetchRequestWallet
                                        ).first {
                                            walletData.walletUnHoldBalance += Double(previousBidAmt)
                                            walletData.walletUnHoldBalance -= Double (bidAmt)
                                            walletData.walletHoldBalance -= Double(previousBidAmt)
                                            walletData.walletHoldBalance += Double(bidAmt)
                                        
                                            try contextUpdateBal.save()
                                            print("Wallet Balance updated successfully!")
                                            
                                            
                                        } else {
                                            print("Wallet data not found for the logged-in user.")
                                        }
                                    } catch {
                                        print("Error updating wallet data: \(error)")
                                    }
                                    
                                    
                                    MBCollectionView.reloadData()
                                }
                                else {
                                    print("Bid Amount Not update.")
                                }
                            }
                                catch {
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

    } // End of Update Bid Price Fuctions
    
  
    
    func deleteBid(for bidUID: UUID) {
       
        print("Update button tapped for product ID: \(bidUID)")
      

                    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                    let fetchRequestBid = NSFetchRequest<BidsData>(entityName: "BidsData")

                        fetchRequestBid.predicate = NSPredicate(format: "bidID == %@", bidUID as CVarArg)

                    do {
                    
                        if let bid = try context.fetch(fetchRequestBid).first {
                            
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
                            
                            try context.save()
                            MBCollectionView.reloadData()
                        }
                        
                    } catch let error as NSError {
                        print("Error fetching all bids: \(error), \(error.userInfo)")
                    }

            
        }
        
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
    
    func fetchMyBids(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequestBidsByUser = NSFetchRequest<BidsData>(entityName: "BidsData")
        fetchRequestBidsByUser.predicate = NSPredicate(format: "biderID == %@", loggedInUserID!)
        
        do {
            let userBids = try context.fetch(fetchRequestBidsByUser)
                if userBids.isEmpty {
                    globalNoDataEmoji(on: self.view)
                }
        }
        catch{
            print ("Error Fetching Bids")
        }
    }

} // end of class



extension MyBidsViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        
        let fetchRequestBidsByUser = NSFetchRequest<BidsData>(entityName: "BidsData")
        fetchRequestBidsByUser.predicate = NSPredicate(format: "biderID == %@", loggedInUserID!)
        
        var itemsBided = 0
        do {
            itemsBided = try context.count(for : fetchRequestBidsByUser)
            let bidedProduct = try context.fetch(fetchRequestBidsByUser)
            print(itemsBided)
            for bp in bidedProduct{
                print (bp.biderID)
            }
            return itemsBided
        }
        catch{
            print("Product not fetched")
        }
        return itemsBided
    }
    
    
    //*************************************************************************************************
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = MBCollectionView.dequeueReusableCell(withReuseIdentifier: "CVCell", for: indexPath) as! MyBidsCollectionViewCell
   
            
            

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let fetchRequestBidsByUser = NSFetchRequest<BidsData>(entityName: "BidsData")
        fetchRequestBidsByUser.predicate = NSPredicate(format: "biderID == %@", loggedInUserID!)

        do {
            let userBids = try context.fetch(fetchRequestBidsByUser)
            guard indexPath.row < userBids.count else {
                print("Index out of bounds")
                return cell
            }
            let bid = userBids[indexPath.row]

            let fetchRequestProduct = NSFetchRequest<AddedProductData>(entityName: "AddedProductData")
            fetchRequestProduct.predicate = NSPredicate(format: "productID == %@", bid.bidProductID! as CVarArg )
            
            do {
                let bidedProducts = try context.fetch(fetchRequestProduct)
                
                if bidedProducts.isEmpty {
                    globalNoDataEmoji(on: self.view)
                }
                
                // Check if there are any bided products
                guard !bidedProducts.isEmpty else {
                    print("No product found for bid with ID:", bid.bidProductID!)
                    return cell
                }
                
           
                let product = bidedProducts[0]
                
                    // If the user has bid on the product, display bid information
                    cell.MBcancelBidBtn.isHidden = false
                   
                    cell.MBupdateBidBtn.isHidden = false
                    
                    cell.MBProductName.text = product.productName
                    cell.MBProductPrice.text = String(product.productMinPrice)
                    cell.MBListedBy.text = product.productSubmitBy
                    
                    let fetchRequestBidsOnProduct = NSFetchRequest<BidsData>(entityName: "BidsData")
                    fetchRequestBidsOnProduct.predicate = NSPredicate(format: "bidProductID == %@", product.productID! as CVarArg)
                    let bidCounter = try context.count(for: fetchRequestBidsOnProduct)
                    cell.MBPlacedBids.text = "\(bidCounter)"
                    
                    let fetchRequestHighestBidAmt = NSFetchRequest<BidsData>(entityName: "BidsData")
                    fetchRequestHighestBidAmt.predicate = NSPredicate(format: "bidProductID == %@", product.productID! as CVarArg)

                    do {
                        let allBidsForProduct = try context.fetch(fetchRequestHighestBidAmt)
                        if let highestBid = allBidsForProduct.max(by: { $0.bidAmount < $1.bidAmount }) {
                            cell.MBHighestBid.text = "\(highestBid.bidAmount)"
                        } else {
                            // No bids found for the product
                            cell.MBHighestBid.text = "No bids"
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
                                 cell.MBEndIn.text = "Auction has Ended!"
                                 timer.invalidate() // Stop the timer
                                 cell.MBupdateBidBtn.isEnabled = false
                                 cell.MBcancelBidBtn.isEnabled = false
                             } else {
                                 // Update the label with remaining time
                                 cell.MBEndIn.text = self.stringFromTimeInterval(remainingTime)
                                
                             }
                         }
                     } else {
                         // Handle the case where productAuctionDateTime is nil
                         cell.MBEndIn.text = "Auction time not specified"
                     }
              
                    cell.MBmybidAmt.text = " \(bid.bidAmount)"
                    
                    if let imageData = product.productImage,  let productImage = UIImage(data: imageData)
                    {
                        cell.MBProductImage.image = productImage
                    } else {
                        cell.MBProductImage.image = UIImage(named: "PRODUCT IMAGE")
                    }
                
                cell.deleteBidAction = { [weak self] in
                        // Fetch product ID associated with the cell and pass it
                        guard let bidid = userBids[indexPath.row].bidID else { return }
                        self?.deleteBid(for:  bidid)
                    }
                
                cell.updateBidAction = { [weak self] in
                        // Fetch product ID associated with the cell and pass it
                        guard let bidid = userBids[indexPath.row].bidID else { return }
                        self?.updateBidPrice(for:  bidid)
                    }
                    
                

            } catch {
                print("Error fetching bided product:", error)
            }

            cell.layer.cornerRadius = 10
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.blue.cgColor

        } catch {
            print("Error fetching user bids:", error)
        }
        


        return cell

    }
    
}
    
    
    

