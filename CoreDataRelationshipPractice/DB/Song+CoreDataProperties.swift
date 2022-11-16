//
//  Song+CoreDataProperties.swift
//  
//
//  Created by Daisaku Ejiri on 2022/11/16.
//
//

import Foundation
import CoreData


extension Song {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Song> {
        return NSFetchRequest<Song>(entityName: "Song")
    }

    @NSManaged public var title: String?
    @NSManaged public var project: Project?

}
