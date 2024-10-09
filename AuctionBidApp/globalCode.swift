//
//  globalCode.swift
//  AuctionBidApp
//
//  Created by user256708 on 5/1/24.
//

import Foundation
import UIKit
import CoreData


class globalCode {
    static let auctionTime = 5 // Define time for acutions live time in minutes
    
}



func showGlobalAlert(message: String, viewController: UIViewController) {
    let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    viewController.present(alert, animated: true, completion: nil)
}


func globalNoDataEmoji(on view: UIView) {
    // Remove any existing subviews
    for subview in view.subviews {
        subview.removeFromSuperview()
    }
    
    // Create a label for "No Any Record"
 
    
    // Create a GIF image view
    let gifImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    gifImageView.contentMode = .scaleAspectFit
    gifImageView.image = UIImage(named: "no-no-no-nope.png.gif")
    
    // Calculate the frame to center the GIF image view below the label
  
    gifImageView.center = CGPoint(x: view.center.x, y: 200 + gifImageView.frame.height / 2)
    
    // Add the GIF image view to the view hierarchy
    view.addSubview(gifImageView)
    
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
    label.text = "No Any Record"
    label.textAlignment = .center
    label.center = view.center
    
    // Add the label to the view hierarchy
    view.addSubview(label)
}





func globalDeleter() {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    let context = appDelegate!.persistentContainer.viewContext
    
    let fetchRequest_AddedProductData = NSFetchRequest<NSFetchRequestResult>(entityName: "AddedProductData")
    let fetchRequest_BidsData = NSFetchRequest<NSFetchRequestResult>(entityName: "BidsData")
    let fetchRequest_FinalBidData = NSFetchRequest<NSFetchRequestResult>(entityName: "FinalBidData")
    let fetchRequest_WalletData = NSFetchRequest<NSFetchRequestResult>(entityName: "WalletData")
    let fetchRequest_SellerWalletData = NSFetchRequest<NSFetchRequestResult>(entityName: "SellersWalletData")
    
    do {
        let results_AdderedProductData = try context.fetch(fetchRequest_AddedProductData)
        let results_BidsData = try context.fetch(fetchRequest_BidsData)
        let results_FinalBidData = try context.fetch(fetchRequest_FinalBidData)
        let results_WalletData = try context.fetch(fetchRequest_WalletData)
        let results_SellerWalletData = try context.fetch(fetchRequest_SellerWalletData)
        
        for object in results_AdderedProductData {
            if let managedObject = object as? NSManagedObject {
                context.delete(managedObject)
            }
        }
        
        for object in results_BidsData {
            if let managedObject = object as? NSManagedObject {
                context.delete(managedObject)
            }
        }
        
        for object in results_FinalBidData {
            if let managedObject = object as? NSManagedObject {
                context.delete(managedObject)
            }
        }
        
        for object in results_WalletData {
            if let managedObject = object as? NSManagedObject {
                context.delete(managedObject)
            }
        }
        
        for object in results_SellerWalletData {
            if let managedObject = object as? NSManagedObject {
                context.delete(managedObject)
            }
        }
        
        try context.save()
        print("All records deleted successfully")
    } catch {
        print("Error deleting records: \(error)")
    }
    
    
    
}
