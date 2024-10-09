
import UIKit
import CoreData

class PurchasesViewController: UIViewController, UITextFieldDelegate {
    let loggedInUserID = UserDefaults.standard.string(forKey: "loggedInUserID")
    @IBOutlet weak var purchasesCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myCollections()
    }
 
    func myCollections()
    {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<FinalBidData>(entityName: "FinalBidData")
        fetchRequest.predicate = NSPredicate(format: "fbProductBidderId == %@", loggedInUserID! as CVarArg)
        do {
            let purchasedProducts = try context.fetch(fetchRequest)
            if purchasedProducts.isEmpty {
                globalNoDataEmoji(on: self.view)
            }
        }
        catch{
        }
    }

}

extension PurchasesViewController : UICollectionViewDelegate , UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var cellCounter = [FinalBidData]();
          
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<FinalBidData>(entityName: "FinalBidData")
            fetchRequest.predicate = NSPredicate(format: "fbProductBidderId == %@", loggedInUserID! as CVarArg)
            
            
            do {
                let purchasedProducts = try context.fetch(fetchRequest)
                for product in purchasedProducts{
                    
                    cellCounter.append(product)

                }
            }
            catch{
                
            }
            
            
        return cellCounter.count
       
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = purchasesCollectionView.dequeueReusableCell(withReuseIdentifier: "CVCell", for: indexPath) as! PurchasesCollectionViewCell
        
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<FinalBidData>(entityName: "FinalBidData")
        fetchRequest.predicate = NSPredicate(format: "fbProductBidderId == %@", loggedInUserID! as CVarArg)
        
        
        do {
            var purchasedProducts = try context.fetch(fetchRequest)
            purchasedProducts.reverse()
            
            // Ensure index path is within bounds
            guard indexPath.row < purchasedProducts.count else {
                print("Index out of bounds")
                return cell
            }
            
            var product = purchasedProducts[indexPath.row]
                
                
                    cell.purchasedProductName.text = product.fbProductName
                    cell.purchaseAmount.text = String(product.fbBidedAmt)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Customize the format according to your needs
                    let dateString = dateFormatter.string(from: product.fbDateTime!)
                    cell.purchaseDate.text = dateString
            
            if let imageData = product.fbProductImage,  let productImage = UIImage(data: imageData)
                    {
                        cell.purchasedProdcutImage.image = productImage
                    } else {
                        cell.purchasedProdcutImage.image = UIImage(named: "PRODUCT IMAGE")
                    }

                }
            
               
                catch
                {
                    print ("Prodcut Not Found")
                }

        return cell
   
    }
    
    
}
