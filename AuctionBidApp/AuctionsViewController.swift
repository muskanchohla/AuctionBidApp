import UIKit
import CoreData
let auctionTime = 5 // time in minutes

class AuctionsViewController: UIViewController {
    
    @IBOutlet weak var productCollectionView: UICollectionView!
    
    var fetchedProductData: [AddedProductData] = []

    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        showAlert(title: "Info", message: "Swipe Up For Next Product")
       
    
        productCollectionView.reloadData()
        fetchAuctionsByCurrentUser()
    }
    
    


       // Function to delete the product
       private func deleteProduct(at indexPath: IndexPath, product: AddedProductData) {
           // Delete the product at the selected index path
           managedContext.delete(product)
           
           // Save changes
           do {
               try managedContext.save()
               print("Product deleted successfully")
               showAlert(title: "Success", message: "Product deleted successfully")
               
               // Remove the deleted product from the fetchedProductData array
               fetchedProductData.remove(at: indexPath.row)
               
               // Reload the collection view after the deletion
               productCollectionView.reloadData()
           } catch {
               print("Error deleting product: \(error)")
               showAlert(title: "Error", message: "Failed to delete product")
           }


    }
    
    

    func fetchAuctionsByCurrentUser() {
        guard let loggedInUserID = UserDefaults.standard.string(forKey: "loggedInUserID") else {
            print("Logged-in User ID not found")
           
            return
        }
        print(loggedInUserID)
        let fetchRequest = NSFetchRequest<AddedProductData>(entityName: "AddedProductData")
        
        // Create a predicate to filter products with auction time greater than current time
       
        let predicate = NSPredicate(format: "productOwnerId = %@", loggedInUserID )
        fetchRequest.predicate = predicate
        
        print(predicate)
        
        do {
            fetchedProductData = try managedContext.fetch(fetchRequest)
            fetchedProductData.reverse()
            productCollectionView.reloadData()
            
            if fetchedProductData.isEmpty {
                globalNoDataEmoji(on: self.view)
            }
            
        } catch {
            print("Error fetching records: \(error)")
        }
    }
    
    
    
    func showAlert(title: String, message: String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    
     func deleterecords() {
   
        let appDelegate = UIApplication.shared.delegate as? AppDelegate

        let context = appDelegate!.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AddedProductData")

            do {
                // Fetch all records for the entity
                let results = try context.fetch(fetchRequest)

                // Loop through fetched results and delete each object
                for object in results {
                    if let managedObject = object as? NSManagedObject {
                        context.delete(managedObject)
                    }
                }

                // Save changes
                try context.save()
                print("All records deleted successfully")
            } catch {
                print("Error deleting records: \(error)")
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

    
} // end of class



extension AuctionsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedProductData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = productCollectionView.dequeueReusableCell(withReuseIdentifier: "CVCell", for: indexPath) as! ListedProductCollectionViewCell
        let productData = fetchedProductData[indexPath.row]
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        // Convert Data to UIImage
        if let imageData = productData.productImage,
           let productImage = UIImage(data: imageData) {
            cell.productImage.image = productImage
        } else {
            // Default image or placeholder if there's no valid image data
            cell.productImage.image = UIImage(named: "placeholderImage")
        }
        
        cell.productName.text = productData.productName
        cell.listedBy.text = "You"
     
        let doubleValue: Double = productData.productMinPrice
                let stringValue = String(doubleValue)
        cell.productPrice.text = stringValue
        

        let fetchRequestHighestBidAmt = NSFetchRequest<BidsData>(entityName: "BidsData")
        fetchRequestHighestBidAmt.predicate = NSPredicate(format: "bidProductID == %@", productData.productID! as CVarArg)

        do {
            let allBidsForProduct = try context.fetch(fetchRequestHighestBidAmt)
            if let highestBid = allBidsForProduct.max(by: { $0.bidAmount < $1.bidAmount }) {
                cell.highestBid.text = "\(highestBid.bidAmount)"
            } else {
                // No bids found for the product
                cell.highestBid.text = "No bids"
            }
        } catch {
            print("Error fetching highest bid amount: \(error)")
        }
        
        
        let auctionLiveTime = productData.productAuctionDateTime
        let oneHourFromNow = Calendar.current.date(byAdding: .minute, value: auctionTime, to: auctionLiveTime!) ?? auctionLiveTime
             if let auctionDateTime = oneHourFromNow {
                 Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                     let remainingTime = self.remainingTime(to: auctionDateTime)
                     if remainingTime <= 0 {
                         // Auction has started, update UI accordingly
                         cell.auctionEndIn.text = "Auction has Ended!"
                         
                         let fetchRequestSoldAmt = NSFetchRequest<FinalBidData>(entityName: "FinalBidData")
                         fetchRequestSoldAmt.predicate = NSPredicate(format: "fbProductId == %@", productData.productID! as CVarArg)

                         do {
                             let allBidsForProduct = try context.fetch(fetchRequestSoldAmt)
                             if let saleAmount = allBidsForProduct.max(by: { $0.fbBidedAmt < $1.fbBidedAmt }) {
                                 cell.highestBid.text = "\(saleAmount.fbBidedAmt)"
                                 cell.HIGHBIDLBL.text = "Sale Amount"
                                 cell.placedBids.text = "Biding Done"
                                 
                             } else {
                                 
                                 cell.highestBid.text = "NA"
                             }
                         } catch {
                             print("Error fetching highest bid amount: \(error)")
                         }
                         
                         
                         timer.invalidate() // Stop the timer
                     } else {
                         // Update the label with remaining time
                         cell.auctionEndIn.text = self.stringFromTimeInterval(remainingTime)
                        
                     }
                 }
             } else {
                 // Handle the case where productAuctionDateTime is nil
                 cell.auctionEndIn.text = "Auction time not specified"
             }


        
        let fetchRequestBidsOnProduct = NSFetchRequest<BidsData>(entityName: "BidsData")
        fetchRequestBidsOnProduct.predicate = NSPredicate(format: "bidProductID == %@", productData.productID! as CVarArg)
        do{
            let bidCounter = try context.count(for: fetchRequestBidsOnProduct)
            cell.placedBids.text = "\(bidCounter)"
        }
        catch{
            cell.placedBids.text = "Not Bid Placed"
        }
        
        
        cell.saleStatus.text = productData.saleStatus
        
        
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.blue.cgColor
        
        return cell
    }

}

/*
@IBAction func DeleteProductBtn(_ sender: UIButton) {
    
    // Get the cell containing the delete button
       guard let cell = sender.superview?.superview?.superview?.superview as? ListedProductCollectionViewCell,
             let indexPath = productCollectionView.indexPath(for: cell) else {
           print("Failed to get indexPath for delete button")
           return
       }
       
       // Get the product to be deleted
       let productToDelete = fetchedProductData[indexPath.row]
       
       // Create and present a confirmation alert
       let alertController = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete this product?", preferredStyle: .alert)
       
       let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
       alertController.addAction(cancelAction)
       
       let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
           // Delete the product
           self.deleteProduct(at: indexPath, product: productToDelete)
       }
       alertController.addAction(deleteAction)
       
       present(alertController, animated: true, completion: nil)
   }
*/
