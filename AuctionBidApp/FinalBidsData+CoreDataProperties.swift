//
//  FinalBidsData+CoreDataProperties.swift
//  AuctionBidApp
//
//  Created by user256708 on 4/26/24.
//
//

import Foundation
import CoreData


extension FinalBidsData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FinalBidsData> {
        return NSFetchRequest<FinalBidsData>(entityName: "FinalBidsData")
    }

    @NSManaged public var fbProductId: UUID?
    @NSManaged public var fbProductBidderId: UUID?
    @NSManaged public var fbProductSellerId: UUID?
    @NSManaged public var fbBidedAmt: Double
    @NSManaged public var fbDateTime: Date?

}

extension FinalBidsData : Identifiable {

}
