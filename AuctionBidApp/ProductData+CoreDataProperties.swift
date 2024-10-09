//
//  ProductData+CoreDataProperties.swift
//  AuctionBidApp
//
//  Created by user254754 on 3/31/24.
//
//

import Foundation
import CoreData


extension ProductData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductData> {
        return NSFetchRequest<ProductData>(entityName: "ProductData")
    }

    @NSManaged public var productID: UUID?
    @NSManaged public var productName: String?
    @NSManaged public var productMinPrice: Double
    @NSManaged public var productImage: Data?
    @NSManaged public var productAuctionDate: Date?
    @NSManaged public var productAuctionTime: Date?
    @NSManaged public var productSubmitBy: String?
    @NSManaged public var productSubmitDate: Date?
    @NSManaged public var productSubmitTime: Date?
    @NSManaged public var soldStatus: Bool

}

extension ProductData : Identifiable {

}
