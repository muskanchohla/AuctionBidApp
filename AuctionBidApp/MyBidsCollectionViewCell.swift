//
//  MyBidsCollectionViewCell.swift
//  AuctionBidApp
//
//  Created by user256708 on 4/21/24.
//

import UIKit

class MyBidsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var MBProductName: UILabel!
    
    @IBOutlet weak var MBProductImage: UIImageView!
    @IBOutlet weak var MBProductPrice: UILabel!
    @IBOutlet weak var MBListedBy: UILabel!
    @IBOutlet weak var MBEndIn: UILabel!
    @IBOutlet weak var MBPlacedBids: UILabel!
    
    @IBOutlet weak var MBHighestBid: UILabel!
    
    @IBOutlet weak var MBmybidAmt: UILabel!
    
    @IBOutlet weak var MBcancelBidBtn: UIButton!
    
    @IBOutlet weak var MBplaceBidBtn: UIButton!
    
    @IBOutlet weak var MBupdateBidBtn: UIButton!
    var deleteBidAction: (() -> Void)?
    var updateBidAction: (() -> Void)?
    
    
    @IBAction func deleteBidBtn(_ sender: Any) {
        let alertController = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to Cancel this bid?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteBidAction?()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
      
        var viewController = self.superview?.next
        while viewController != nil && !(viewController is UIViewController) {
            viewController = viewController!.next
        }
        
        if let vc = viewController as? UIViewController {
            vc.present(alertController, animated: true)
        }
    }

    @IBAction func updateBidBtn(_ sender: UIButton) {
        updateBidAction?()
    }
}
