

import UIKit
import CoreData

class bidderHomeViewController: UIViewController {
    let loggedInUserID = UserDefaults.standard.string(forKey: "loggedInUserID")
    let auctionTime = globalCode.auctionTime
    
    @IBOutlet weak var bidderImg: UIImageView!
    
    @IBOutlet weak var bidderNameLbl: UILabel!
    
    @IBOutlet weak var bidderRoleLbl: UILabel!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        loggedUserProfile()
        bidManager()
        tempDispBidsData()
        print(Date())
        tempDispFinalBidData()
        reloadFunction()
        
        //        bidderImg.image = UIImage(named: "Weather-v2")
        //
        //        bidderNameLbl.text = "Satwant Singh "
        //        bidderRoleLbl.text = "Bidder "
        
        bidderImg.layer.borderWidth = 3
        bidderImg.layer.borderColor = UIColor.green.cgColor
        
        bidderImg.layer.masksToBounds = true
        bidderImg.layer.cornerRadius = bidderImg.frame.height / 2
        
        
        Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(reloadFunction), userInfo: nil, repeats: true)
        
        
        
        
    }
    
    @objc func reloadFunction() {
        // Place your code to reload the view here
        // For example, if you want to reload the entire view, you can call viewDidLoad or viewWillAppear method again
        // Or you can reload specific data or UI elements
        
        // Example: Reloading the entire view
        loggedUserProfile()
        bidManager()
    }
    
    @IBAction func avaiableAuctionBtn(_ sender: Any) {
    }
    
    @IBAction func upcommingAuctionBtn(_ sender: Any) {
    }
    @IBAction func myBidsBtn(_ sender: Any) {
    }
    
    
    @IBAction func bidderWalletBtn(_ sender: Any) {
    }
    
    @IBAction func bidderProfileBtn(_ sender: Any) {
    }
    
    @IBAction func bidderHistoryBtn(_ sender: Any) {
    }
    
    
    @IBAction func biddeerSignOutBtn(_ sender: Any) {
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
                self.bidderNameLbl.text = loggedUser.username
                self.bidderRoleLbl.text = loggedUser.usertype
                
                
                // Set the logged-in user's image
                // Set the logged-in user's image
                if let imageData = loggedUser.userimage {
                    if let image = UIImage(data: imageData) {
                        self.bidderImg.image = image
                    } else {
                        self.bidderImg.image = UIImage(named: "UserImage") // Placeholder image name or nil
                    }
                } else {
                    self.bidderImg.image = UIImage(named: "UserImage") // Placeholder image name or nil
                }
                
            }
            print("Logged-in User ID: \(loggedInUserID)")
        } else {
            print("Failed to fetch logged-in user profile")
        }
    }
    
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
    
    func bidManager(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let contextFinalBid = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let contextFinalBidProduct = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequestBids = NSFetchRequest<BidsData>(entityName: "BidsData")
        
        // Calculate the date 15 minutes from now
        let FromNow = Calendar.current.date(byAdding: .minute, value: -auctionTime, to: Date())!
        
        // Set the predicate for the fetch request
        fetchRequestBids.predicate =  NSPredicate(format: "bidAuctionStartDateTime <= %@", FromNow as CVarArg)
        
        
      
            
            do {
                
                let allBidsForProduct = try context.fetch(fetchRequestBids)
                if let highestBid = allBidsForProduct.max(by: { $0.bidAmount < $1.bidAmount }) {
                    let otherBids = allBidsForProduct.filter { $0 != highestBid }
                    let otherBidAmounts = otherBids.map { $0.bidAmount }
                            
                            // Now you can use otherBidAmounts array as per your requirement
                            print ("bider id \(otherBids)")
                            print("Bid amounts of other bidders: \(otherBidAmounts)")
                            for  otherbidder in otherBids
                            {
                                let contextUpdateBalOb = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                                let fetchRequestWalletOb: NSFetchRequest<WalletData> = WalletData.fetchRequest()
                                fetchRequestWalletOb.predicate = NSPredicate(format: "walletUserId == %@", otherbidder.biderID! as CVarArg)
                                
                                do {
                                    if let walletData = try contextUpdateBalOb.fetch(fetchRequestWalletOb
                                    ).first {
                                        walletData.walletHoldBalance -= Double(otherbidder.bidAmount)
                                        walletData.walletUnHoldBalance += Double(otherbidder.bidAmount)
                                        walletData.walletTotalBalance = walletData.walletUnHoldBalance + walletData.walletHoldBalance
                                        try contextUpdateBalOb.save()
                                        print("other bidder Wallet Balance updated successfully!")
                                        
                                        
                                    } else {
                                        print("other bidder Wallet data not found for the logged-in user.")
                                    }
                                } catch {
                                    print("Error other bidder updating wallet data: \(error)")
                                }
                            }
                            
                    
                    
                    
                    let finalBid = FinalBidData(context: contextFinalBid)
                    finalBid.fbProductBidderId = highestBid.biderID
                    finalBid.fbProductId = highestBid.bidProductID
                    finalBid.fbBidedAmt = Double(highestBid.bidAmount)
                    finalBid.fbDateTime = Date()
                    finalBid.fbProductName = highestBid.bidProductName
                    finalBid.fbProductImage = highestBid.bidProductImage
                    finalBid.fbProductSellerId = highestBid.bidProductOwnerId
                    print("Highest Bid Amount \(highestBid.bidAmount)")
                    /* let amountTransfer = SellersWalletData(context: contextFinalBid)
                     amountTransfer.sellerWalletId = highestBid.bidProductOwnerId
                     amountTransfer.sellterWalletSaleAmount += Double(highestBid.bidAmount)*/
                    
                    
                    let fetchRequest = NSFetchRequest<SellersWalletData>(entityName: "SellersWalletData")
                    fetchRequest.predicate = NSPredicate(format: "sellerWalletId == %@", highestBid.bidProductOwnerId! as CVarArg)
                    
                    do {
                        let walletEntities = try contextFinalBid.fetch(fetchRequest)
                        
                        if let walletEntity = walletEntities.first {
                            
                            walletEntity.sellterWalletSaleAmount += Double(highestBid.bidAmount)
                            walletEntity.sellerWalletBalance += Double(highestBid.bidAmount)
                            print ("seller wallet id \(walletEntity.sellerWalletId)")
                            print ("seller wallet balance \(walletEntity.sellerWalletBalance)")
                            print("Seller Wallet Balance added successfully!")
                            
                        } else {
                            
                            let newWalletEntity = SellersWalletData(context: contextFinalBid)
                            newWalletEntity.sellerWalletId = highestBid.bidProductOwnerId
                            newWalletEntity.sellterWalletSaleAmount = Double(highestBid.bidAmount)
                            newWalletEntity.sellerWalletBalance += Double(highestBid.bidAmount)
                            print("Seller Wallet Balance updated successfully!")
                        }
                        
                        
                        // Save the context
                        try contextFinalBid.save()
                        
                    } catch {
                        print("Error fetching or saving wallet data: \(error)")
                        
                        
                    }
                    
                    
                    let contextUpdateBal = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                    let fetchRequestWallet: NSFetchRequest<WalletData> = WalletData.fetchRequest()
                    fetchRequestWallet.predicate = NSPredicate(format: "walletUserId == %@", highestBid.biderID! as CVarArg)
                    
                    do {
                        if let walletData = try contextUpdateBal.fetch(fetchRequestWallet
                        ).first {
                            walletData.walletHoldBalance -= Double(highestBid.bidAmount)
                            walletData.walletTotalBalance = walletData.walletUnHoldBalance + walletData.walletHoldBalance
                            try contextUpdateBal.save()
                            print("Wallet Balance updated successfully!")
                            
                            
                        } else {
                            print("Wallet data not found for the logged-in user.")
                        }
                    } catch {
                        print("Error updating wallet data: \(error)")
                    }
                    
                    let contextUpdateSaleStatus = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                    let fetchRequestProduct: NSFetchRequest<AddedProductData> = AddedProductData.fetchRequest()
                    fetchRequestWallet.predicate = NSPredicate(format: "productID == %@", highestBid.bidProductID! as CVarArg)
                    
                    do {
                        if let productData = try contextUpdateSaleStatus.fetch(fetchRequestProduct
                        ).first {
                            productData.saleStatus = " Sold "
                            productData.soldStatus = true
                            try contextUpdateSaleStatus.save()
                            print(" sale Status updated successfully!")
                            
                            
                        } else {
                            print("sale Status not updated.")
                        }
                    } catch {
                        print("Error updating wallet data: \(error)")
                    }
                    
                    
                    try contextFinalBid.save()
                    
                    do{
                        
                        let contextFinalBidProduct = NSFetchRequest<BidsData>(entityName: "BidsData")
                        contextFinalBidProduct.predicate = NSPredicate(format: "bidProductID == %@", highestBid.bidProductID! as CVarArg)
                            
                        
                            if let fetchedProducts = try? context.fetch(contextFinalBidProduct) {
                                for product in fetchedProducts {
                                    context.delete(product) // Delete the bids associated with the product
                                    print("Bids Deleted Succesffully")
                                }
                                try? context.save()
                            }
                        }
                    

                       // Save changes after deleting the bids
                    catch {
                        print("Error deleting bids for product: \(error)")
                    }
                } else {
                    // No bids found for the product
                    print("No bids")
                }
          
        }
    
           
        
            
        
        catch {
            print("Error fetching bids: \(error)")
        }

    } // End of Bid Manager Function
    
    
    func  tempDispFinalBidData(){
        
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<FinalBidData>(entityName: "FinalBidData")
        fetchRequest.predicate = NSPredicate(format: "fbProductBidderId == %@", loggedInUserID! as CVarArg)
        
        
        do {
            let purchasedProducts = try context.fetch(fetchRequest)
            for product in purchasedProducts{
                
                print("bdi product Name \(product.fbProductName)")
                print("bid product ID \(product.fbProductId)")
                print("bid Bidder \(product.fbProductBidderId)")
                print("bid product purchase date \(product.fbDateTime)")
              
            }
        }
            catch{
                print("Product not found")
            }
        }
    func  tempDispBidsData(){
        
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<BidsData>(entityName: "BidsData")
        //fetchRequest.predicate = NSPredicate(format: "fbProductBidderId == %@", loggedInUserID! as CVarArg)
        
        
        do {
            let purchasedProducts = try context.fetch(fetchRequest)
            for product in purchasedProducts{
                
                print("bdi product Name \(product.bidProductName)")
                print("bid product ID \(product.bidProductID)")
                print("bid Bidder \(product.biderID)")
                print("bid product purchase date \(product.bidAuctionStartDateTime)")
                          }
        }
            catch{
                print("Product not found")
            }
        }
        
    }

