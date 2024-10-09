//
//  Bids+CoreDataProperties.swift
//  AuctionBidApp
//
//  Created by user256708 on 4/19/24.
//
//

import Foundation
import CoreData


extension Bids {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bids> {
        return NSFetchRequest<Bids>(entityName: "Bids")
    }

    @NSManaged public var bidID: UUID?
    @NSManaged public var bidProductID: UUID?
    @NSManaged public var biderID: UUID?
    @NSManaged public var bidAmount: Int16
    @NSManaged public var bidPlaced: Bool

}

extension Bids : Identifiable {

}
