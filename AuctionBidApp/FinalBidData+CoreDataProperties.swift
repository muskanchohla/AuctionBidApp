//
//  FinalBidData+CoreDataProperties.swift
//  AuctionBidApp
//
//  Created by user256708 on 4/26/24.
//
//

import Foundation
import CoreData


extension FinalBidData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FinalBidData> {
        return NSFetchRequest<FinalBidData>(entityName: "FinalBidData")
    }

    @NSManaged public var fbProductId: UUID?
    @NSManaged public var fbProductBidderId: UUID?
    @NSManaged public var fbProductSellerId: UUID?
    @NSManaged public var fbBidedAmt: Double
    @NSManaged public var fbDateTime: Date?
    @NSManaged public var fbProductName: String?
    @NSManaged public var fbProductImage: Data?

}

extension FinalBidData : Identifiable {

}
