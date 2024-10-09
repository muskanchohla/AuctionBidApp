

import UIKit
import CoreData

class UpcommingAuctionsViewController: UIViewController {

  
    @IBOutlet weak var UACollectionView: UICollectionView!
    
  

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRecordsWithFutureAuctionTime()
        
    }
    
// ===================================code for Fetch Data From AddedProductData=========================================
    
    var fetchedProductData: [AddedProductData] = []
    
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
 /*   func fetchAllRecords() {
        let fetchRequest = NSFetchRequest<AddedProductData>(entityName: "AddedProductData")
        
        do {
            fetchedProductData = try managedContext.fetch(fetchRequest)
            UACollectionView.reloadData()
        } catch {
            print("Error fetching records: \(error)")
        }
    }
 */
    func fetchRecordsWithFutureAuctionTime() {
        let fetchRequest = NSFetchRequest<AddedProductData>(entityName: "AddedProductData")
        
        // Create a predicate to filter products with auction time greater than current time
        let currentDate = Date()
        let predicate = NSPredicate(format: "productAuctionDateTime > %@", currentDate as NSDate)
        fetchRequest.predicate = predicate
        
        do {
            fetchedProductData = try managedContext.fetch(fetchRequest)
            UACollectionView.reloadData()
            
            // Check if fetchedProductData array is empty
            if fetchedProductData.isEmpty {
                globalNoDataEmoji(on: self.view)
            }
        } catch {
            print("Error fetching records: \(error)")
        }
    }

//======================================================================================================================

    @IBAction func placeAbidBtn(_ sender: Any) {
        
    }
    
    
    // Function to calculate remaining time in seconds
       func remainingTime(to date: Date) -> TimeInterval {
           let currentDate = Date()
           return date.timeIntervalSince(currentDate)
       }
       
       // Function to format time interval as a string
       func stringFromTimeInterval(_ interval: TimeInterval) -> String {
           let formatter = DateComponentsFormatter()
           formatter.unitsStyle = .full
           formatter.allowedUnits = [.hour, .minute, .second]
           return formatter.string(from: interval)!
       }
}










extension UpcommingAuctionsViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedProductData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = UACollectionView.dequeueReusableCell(withReuseIdentifier: "CVCell", for: indexPath) as! UpcommingAuctionsCollectionViewCell
        
        let productData = fetchedProductData[indexPath.row]
        
        cell.UAProductNameLbl.text = productData.productName
        cell.UAProductMInPrice.text =  String(productData.productMinPrice)
        cell.UAProductSubmitBy.text = productData.productSubmitBy
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm" // Change the format to your preference

        if let auctionDateTime = productData.productAuctionDateTime {
            cell.UAProductStartTimeDate.text = dateFormatter.string(from: auctionDateTime)
        } else {
            // Handle the case where productAuctionDateTime is nil
            cell.UAProductStartTimeDate.text = "No auction time specified"
        }
    
       
      
        // Check if productAuctionDateTime is not nil before scheduling the timer
        if let auctionDateTime = productData.productAuctionDateTime {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                let remainingTime = self.remainingTime(to: auctionDateTime)
                if remainingTime <= 0 {
                    // Auction has started, update UI accordingly
                    cell.UAProductRemainingTime.text = "Auction has started!"
                    timer.invalidate() // Stop the timer
                } else {
                    // Update the label with remaining time
                    cell.UAProductRemainingTime.text = self.stringFromTimeInterval(remainingTime)
                }
            }
        } else {
            // Handle the case where productAuctionDateTime is nil
            cell.UAProductRemainingTime.text = "Auction time not specified"
        }

        if let imageData = productData.productImage,
           let productImage = UIImage(data: imageData) {
            cell.UAProductNameImage.image = productImage
        } else {
            // Default image or placeholder if there's no valid image				 data
            cell.UAProductNameImage.image = UIImage(named: "placeholderImage")
        }
        
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.blue.cgColor
        return cell
    }
    
    
    
    
}
