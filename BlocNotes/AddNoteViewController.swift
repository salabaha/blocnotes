//
//  AddNoteViewController.swift
//  BlocNotes
//
//  Created by Adrian Bolinger on 2/19/15.
//  Copyright (c) 2015 PPC Software. All rights reserved.
//

import UIKit
import CoreData

class AddNoteViewController: UIViewController {
    
    @IBOutlet weak var newNoteTitle: UITextField!
    @IBOutlet weak var newNoteBody: UITextField!
    
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    @IBOutlet weak var newNoteTitle: UITextField!
    @IBOutlet weak var newNoteBody: UITextField!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addNote(sender: AnyObject) {
        let newNote = NSEntityDescription.insertNewObjectForEntityForName("Note", inManagedObjectContext: self.managedObjectContext!) as! Note
        
        newNote.noteTitle = newNoteTitle.text
        newNote.noteBody = newNoteBody.text
        newNote.dateCreated = NSDate()
        newNote.dateEdited = NSDate()
        var error: NSError? = nil
        self.managedObjectContext!.save(&error)

        newNoteTitle.text = nil
        newNoteBody.text = nil        
    }

    // MARK: - Navigation

<<<<<<< HEAD
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
    
}
=======
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

//    @IBAction func saveNote(sender: UIBarButtonItem) {
//        let newNote = NSEntityDescription.insertNewObjectForEntityForName("Note", inManagedObjectContext: AppDelegate.managedObjectContext!) as! Note
//        
//        newNoteTitle.noteTitle = self.newNoteTitle
//        newNoteBody.noteBody = self.newNoteBody
//        self.dateCreated = NSDate()
//        newNote.dateEdited = NSDate()
//
//    }
}
>>>>>>> 8fe142108564ad16492bb36d1fa680171471804f
