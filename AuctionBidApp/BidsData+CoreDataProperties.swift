//
//  BidsData+CoreDataProperties.swift
//  AuctionBidApp
//
//  Created by user256708 on 4/19/24.
//
//

import Foundation
import CoreData


extension BidsData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BidsData> {
        return NSFetchRequest<BidsData>(entityName: "BidsData")
    }

    @NSManaged public var bidID: UUID?
    @NSManaged public var bidProductID: UUID?
    @NSManaged public var biderID: UUID?
    @NSManaged public var bidAmount: Int64
    @NSManaged public var bidPlaced: Bool
    @NSManaged public var bidProductName: String?
    @NSManaged public var bidProductImage: Data?
    @NSManaged public var bidAuctionStartDateTime: Date?
    @NSManaged public var bidProductOwnerId: UUID?
}

extension BidsData : Identifiable {

}
