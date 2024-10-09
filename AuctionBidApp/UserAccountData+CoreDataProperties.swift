//
//  UserAccountData+CoreDataProperties.swift
//  AuctionBidApp
//
//  Created by user254754 on 3/29/24.
//
//

import Foundation
import CoreData


extension UserAccountData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserAccountData> {
        return NSFetchRequest<UserAccountData>(entityName: "UserAccountData")
    }

    @NSManaged public var userid: UUID?
    @NSManaged public var username: String?
    @NSManaged public var useremail: String?
    @NSManaged public var userimage: Data?
    @NSManaged public var userpassword: String?
    @NSManaged public var usertype: String?
    @NSManaged public var usertypecode: Int32
    @NSManaged public var usercreationdate: Date?
    @NSManaged public var userstatus: Bool

}

extension UserAccountData : Identifiable {

}
