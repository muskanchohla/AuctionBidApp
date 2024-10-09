//
//  Wallet+CoreDataProperties.swift
//  AuctionBidApp
//
//  Created by user256708 on 4/20/24.
//
//

import Foundation
import CoreData


extension Wallet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Wallet> {
        return NSFetchRequest<Wallet>(entityName: "Wallet")
    }

    @NSManaged public var walletId: UUID?
    @NSManaged public var walletUserId: UUID?
    @NSManaged public var walletUserType: String?
    @NSManaged public var walletTotalBalance: Double
    @NSManaged public var walletTransaction: String?
    @NSManaged public var walletHoldBalance: Double
    @NSManaged public var walletUnHoldBalance: NSObject?

}

extension Wallet : Identifiable {

}
