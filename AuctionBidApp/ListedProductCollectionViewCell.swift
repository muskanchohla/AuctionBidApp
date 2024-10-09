//
//  ListedProductCollectionViewCell.swift
//  AuctionBidApp
//
//  Created by user254754 on 4/1/24.
//

import UIKit

class ListedProductCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    
    @IBOutlet weak var productPrice: UILabel!
    
    @IBOutlet weak var listedBy: UILabel!
    
    @IBOutlet weak var auctionEndIn: UILabel!
    
    @IBOutlet weak var placedBids: UILabel!
    @IBOutlet weak var highestBid: UILabel!
    @IBOutlet weak var placeBidBtn: UIButton!
    
    @IBOutlet weak var saleStatus: UILabel!
    
    @IBOutlet weak var HIGHBIDLBL: UILabel!
}
