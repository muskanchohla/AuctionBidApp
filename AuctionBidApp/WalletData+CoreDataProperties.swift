//
//  WalletData+CoreDataProperties.swift
//  AuctionBidApp
//
//  Created by user256708 on 4/20/24.
//
//

import Foundation
import CoreData


extension WalletData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WalletData> {
        return NSFetchRequest<WalletData>(entityName: "WalletData")
    }

    @NSManaged public var walletId: UUID?
    @NSManaged public var walletUserId: UUID?
    
    @NSManaged public var walletTotalBalance: Double

    @NSManaged public var walletHoldBalance: Double
    @NSManaged public var walletUnHoldBalance: Double

}

extension WalletData : Identifiable {

}
