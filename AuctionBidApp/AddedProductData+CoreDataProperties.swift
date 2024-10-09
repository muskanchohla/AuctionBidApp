//
//  AddedProductData+CoreDataProperties.swift
//  AuctionBidApp
//
//  Created by user254754 on 3/31/24.
//
//

import Foundation
import CoreData


extension AddedProductData {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AddedProductData> {
        return NSFetchRequest<AddedProductData>(entityName: "AddedProductData")
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
    @NSManaged public var productAuctionDateTime: Date?
    @NSManaged public var productOwnerId: UUID?
    @NSManaged public var saleStatus : String?
}

extension AddedProductData : Identifiable {

}
