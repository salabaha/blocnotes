//
//  Note.swift
//  BlocNotes
//
//  Created by Adrian Bolinger on 2/18/15.
//  Copyright (c) 2015 PPC Software. All rights reserved.
//

import Foundation
import CoreData

class Note: NSManagedObject {

    @NSManaged var dateCreated: NSDate
    @NSManaged var dateEdited: NSDate
    @NSManaged var noteTitle: String
    @NSManaged var noteBody: String

}
