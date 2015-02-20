//
//  AddNoteViewController.swift
//  BlocNotes
//
//  Created by Adrian Bolinger on 2/19/15.
//  Copyright (c) 2015 PPC Software. All rights reserved.
//

import UIKit
import CoreData

class AddNoteViewController: UIViewController, UITextViewDelegate { // Added a delegate method
    
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var newNoteTitle: UITextField!
    @IBOutlet weak var newNoteBody: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set border of UITextView to look like border of UITextField
        self.newNoteBody.layer.borderWidth = 1.0
        self.newNoteBody.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3).CGColor
        self.newNoteBody.layer.cornerRadius = 5.0
        
        newNoteBody.delegate = self
        if (newNoteBody.text == "") {
            textViewDidEndEditing(newNoteBody)
        }
        var tapDismiss = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tapDismiss)
        
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
    
    // MARK: - Placeholder text methods
    
    func dismissKeyboard(){
        newNoteBody.resignFirstResponder()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if (textView.text == "") {
            textView.text = "Enter note here"
            textView.textColor = UIColor.lightGrayColor()
        }
        textView.resignFirstResponder()
    }
    
    func textViewDidBeginEditing(textView: UITextView){
        if (textView.text == "Enter note here"){
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
        textView.becomeFirstResponder()
    }
    
    // MARK: - UIDocumentPicker Methods
    
    // MARK: - Navigation
    
    //    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //        // Get the new view controller using segue.destinationViewController.
    //        // Pass the selected object to the new view controller.
    //    }
    
}