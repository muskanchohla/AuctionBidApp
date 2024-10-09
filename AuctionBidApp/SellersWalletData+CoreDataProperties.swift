//
//  SellersWalletData+CoreDataProperties.swift
//  AuctionBidApp
//
//  Created by user256708 on 4/28/24.
//
//

import Foundation
import CoreData


extension SellersWalletData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SellersWalletData> {
        return NSFetchRequest<SellersWalletData>(entityName: "SellersWalletData")
    }

    @NSManaged public var sellerWalletId: UUID?
    @NSManaged public var sellterWalletSaleAmount: Double
    @NSManaged public var sellterWalletWithdrawAmount: Double
    @NSManaged public var sellerWalletBalance: Double

}

extension SellersWalletData : Identifiable {

}
