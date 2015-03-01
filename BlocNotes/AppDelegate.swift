//
//  AppDelegate.swift
//  BlocNotes
//
//  Created by Adrian Bolinger on 2/18/15.
//  Copyright (c) 2015 PPC Software. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self
        
        let masterNavigationController = splitViewController.viewControllers[0] as! UINavigationController
        let controller = masterNavigationController.topViewController as! MasterViewController
        controller.managedObjectContext = self.managedObjectContext
        
        randomNoteCreator() // Creates random notes if none exist in the managed object context
        
        setKeyValueStorage()
        iCloudAccountIsSignedIn()
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Split view
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController!, ontoPrimaryViewController primaryViewController:UIViewController!) -> Bool {
        if let secondaryAsNavController = secondaryViewController as? UINavigationController {
            if let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController {
                if topAsDetailController.detailItem == nil {
                    // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
                    return true
                }
            }
        }
        return false
    }
    // MARK: - Core Data stack
    
    // TODO: Might need to take this out? Ask Bjorn
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.PPCSoftware.BlocNotes" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("BlocNotes", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    // This is the original PSC before I messed around w/ it in the version below.
//    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
//        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
//        // Create the coordinator and store
//        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
//        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("BlocNotes.sqlite")
//        var error: NSError? = nil
//        var failureReason = "There was an error creating or loading the application's saved data."
//        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
//            coordinator = nil
//            // Report any error we got.
//            var dict = [String: AnyObject]()
//            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
//            dict[NSLocalizedFailureReasonErrorKey] = failureReason
//            dict[NSUnderlyingErrorKey] = error
//            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
//            // Replace this with code to handle the error appropriately.
//            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog("Unresolved error \(error), \(error!.userInfo)")
//            abort()
//        }
//        
//        return coordinator
//        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        // Setup iCloud in another thread
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            // ** Note: if you adapt this code for your own use, you MUST change this variable:
            let iCloudEnabledAppID = "A983637AY3.com.PPCSoftware.BlocNotes"
            
            // ** Note: if you adapt this code for your own use, you should change this variable:
            let dataFileName = "BlocNotes.sqlite"
            
            // ** Note: For basic usage you shouldn't need to change anything else
            let iCloudDataDirectoryName = "Data.nosync"
            let iCloudLogsDirectoryName = "Logs"
            let fileManager = NSFileManager.defaultManager()
            let localStore: NSURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent(dataFileName)
            if let iCloud = fileManager.URLForUbiquityContainerIdentifier(nil) {
                println("iCloud is working!") // And you can access iCloud here
                let iCloudLogsPath: NSURL = NSURL.fileURLWithPath((iCloud.path?.stringByAppendingPathComponent(iCloudLogsDirectoryName))!)!
                println("iCloudEnabledAppID = \(iCloudEnabledAppID)")
                println("dataFileName = \(dataFileName)")
                println("iCloudDataDirectoryName = \(iCloudDataDirectoryName)")
                println("iCloudLogsDirectoryName = \(iCloudLogsDirectoryName)")
                println("iCloud = \(iCloud)")
                println("iCloudLogsPath = \(iCloudLogsPath)")
                
                // Stop point:
                // working on swiftifying this
                
//                if ((fileManager.fileExistsAtPath((iCloud.path)!.stringByAppendingPathComponent(iCloudDataDirectoryName))) == false) {
//                    var fileSystemError: NSError
//                    (fileManager.createDirectoryAtPath(iCloud.path.stringByAppendingPathComponent(iCloudDataDirectoryName), withIntermediateDirectories: true, attributes: nil, error: &fileSystemError)
//                }
                
                

                
                
            } else {
                println("iCloud is NOT working!") // And you don't need iCloud here
                
            }
            
        })
        
        
//        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("BlocNotes.sqlite")
//        var error: NSError? = nil
//        var failureReason = "There was an error creating or loading the application's saved data."
//        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
//            coordinator = nil
//            // Report any error we got.
//            var dict = [String: AnyObject]()
//            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
//            dict[NSLocalizedFailureReasonErrorKey] = failureReason
//            dict[NSUnderlyingErrorKey] = error
//            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
//            // Replace this with code to handle the error appropriately.
//            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog("Unresolved error \(error), \(error!.userInfo)")
//            abort()
//        }
        
        return coordinator
        }()

    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
    // MARK: - Add sample data
    func randomNoteCreator() {
        
        var error: NSError? = nil
        let request = NSFetchRequest(entityName: "Note")
        let noteCount = self.managedObjectContext?.countForFetchRequest(request, error: &error)
        if noteCount < 1 {
            println("Adding sample notes")
            var count: Int = 1
            while count < 11 {
                let newNote = NSEntityDescription.insertNewObjectForEntityForName("Note", inManagedObjectContext: self.managedObjectContext!) as! Note
                
                newNote.noteTitle = "Test Note \(count)"
                newNote.noteBody = "Now is the time for all good men to come to the aid of their country"
                newNote.dateCreated = NSDate()
                newNote.dateEdited = NSDate()
                count++
                self.saveContext() // added with Steve
            }
        } else {
            println("There are already notes in the app")
        }
    }
    
    // MARK: - iCloud methods
    func iCloudAccountIsSignedIn() -> Bool{
        if let token = NSFileManager.defaultManager().ubiquityIdentityToken {
            println("iCloud account is signed in")
            return true
        } else {
            println("iCloud account is NOT signed in")
            return false
        }
    }

    
    func setKeyValueStorage () {
        // KeyValueStorage methods
        // register to receive notifications from the store (TODO: which store?)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("storeDidChange"), name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification, object: NSUbiquitousKeyValueStore.defaultStore())
        
        // get changes that might have happened while this app wasn't running
        NSUbiquitousKeyValueStore.defaultStore().synchronize()
    }
    
    func storeDidChange(notification: NSNotification) {
        // Example code:
        // Need to customize
        // Retrieve the changes from iCloud
        // _notes = [[[NSUbiquitousKeyValueStore defaultStore] arrayForKey:@"AVAILABLE_NOTES"] mutableCopy];
        // Reload the table view to show changes
        // [self.tableView reloadData];
    }
    
    
    
    
    
    
    
    
    
    
    
    

}

