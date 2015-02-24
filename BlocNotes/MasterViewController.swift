//
//  MasterViewController.swift
//  BlocNotes
//
//  Created by Adrian Bolinger on 2/18/15.
//  Copyright (c) 2015 PPC Software. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    var detailViewController: DetailViewController? = nil
    var addNoteViewController:AddNoteViewController? = nil  // I added this
    var managedObjectContext: NSManagedObjectContext? = nil
    
    // Added variable for UISearchController
    var searchController: UISearchController!
    var searchPredicate: NSPredicate? // I added this. It's optional on and gets set later
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            let context = self.fetchedResultsController.managedObjectContext
            let entity = self.fetchedResultsController.fetchRequest.entity!
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
        
        // UISearchController setup
        searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController?.searchBar
        self.tableView.delegate = self
        self.definesPresentationContext = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func insertNewObject(sender: AnyObject) {
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context) as! NSManagedObject
        
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        //        newManagedObject.setValue(NSString(), forKey: "noteTitle")
        
        // Save the context.
        var error: NSError? = nil
        if !context.save(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            println("Unresolved error \(error), \(error?.userInfo)")
            abort()
        }
    }
    
    // MARK: - UISearchResultsUpdating Delegate Method
    // Called when the search bar's text or scope has changed or when the search bar becomes first responder.
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = self.searchController?.searchBar.text // steve put breakpoint
        println(searchController.searchBar.text)
        if let searchText = searchText {
            searchPredicate = NSPredicate(format: "noteBody contains[c] %@", searchText)
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        
        if segue.identifier == "addNote" {
            //            println("segue.identifier is addNote")
            //            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! AddNoteViewController
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchPredicate == nil {
            let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
            return sectionInfo.numberOfObjects
        }
        
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            var note: Note
            if searchPredicate == nil {
                note = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Note
            } else {
                let filteredObjects = self.fetchedResultsController.fetchedObjects?.filter() {
                    return self.searchPredicate!.evaluateWithObject($0)
                }
                note = filteredObjects![indexPath.row] as! Note
            }
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(note)
            
            var error: NSError? = nil
            if !context.save(&error) {
                abort()
            }
            
            //            let context = self.fetchedResultsController.managedObjectContext
            //            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
            //
            //            var error: NSError? = nil
            //            if !context.save(&error) {
            //                // Replace this implementation with code to handle the error appropriately.
            //                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //                //println("Unresolved error \(error), \(error.userInfo)")
            //                abort()
            //            }
        }
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        cell.textLabel!.text = object.valueForKey("noteTitle")!.description
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Note", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        // TODO: change to match code here
        let sortDescriptor = NSSortDescriptor(key: "noteTitle", ascending: false)
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        var error: NSError? = nil
        if !_fetchedResultsController!.performFetch(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            println("Unresolved error \(error), \(error?.userInfo)")
            abort()
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        //        self.tableView.beginUpdates() // ** original code, change if doesn't work** steve put breakpoint here
        
        // ANSWER said this section is redundant
        if searchPredicate == nil {
            tableView.beginUpdates()
        } else {
            (searchController.searchResultsUpdater as! MasterViewController).tableView.beginUpdates()
        }
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        var tableView = UITableView()
        
        if self.searchPredicate == nil {
            tableView = self.tableView
        } else {
            tableView = (self.searchController.searchResultsUpdater as! MasterViewController).tableView
        }
        
        switch type {
        case .Insert:
            println("*** NSFetchedResultsChangeInsert (object)")
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            println("*** NSFetchedResultsChangeDelete (object)")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            println("*** NSFetchedResultsChangeUpdate (object)")
            // TODO: need fix this
            
            // ORIGINAL CODE
            // self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!) // original code
            
            // PROSPECTIVE SOLUTION CODE
            println("*** NSFetchedResultsChangeUpdate (object)")
            if searchPredicate == nil {
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!) // original code
            } else {
                //                let cell = tableView.cellForRowAtIndexPath(searchIndexPath) as LocationCell
                //                let location = controller.objectAtIndexPath(searchIndexPath) as Location
                //                cell.configureForLocation(location)
            }
            
        case .Move:
            println("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if self.searchPredicate == nil {
            self.tableView.endUpdates()
        } else {
            println("controllerDidChangeContent")
            (self.searchController.searchResultsUpdater as! MasterViewController).tableView.endUpdates()
        }
        
    }
    
    
    /*
    // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
    // In the simplest, most efficient, case, reload the table view.
    self.tableView.reloadData()
    }
    */
    
}

