//
//  SellerWalletData+CoreDataProperties.swift
//  AuctionBidApp
//
//  Created by user256708 on 4/28/24.
//
//

import Foundation
import CoreData


extension SellerWalletData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SellerWalletData> {
        return NSFetchRequest<SellerWalletData>(entityName: "SellerWalletData")
    }

    @NSManaged public var sellerWalletId: UUID?
    @NSManaged public var sellterWalletSaleAmount: Double
    @NSManaged public var sellterWalletWithdrawAmount: Double
    @NSManaged public var sellerWalletBalance: Double

}

extension SellerWalletData : Identifiable {

}
