//
//  DetailViewController.swift
//  BlocNotes
//
//  Created by Adrian Bolinger on 2/18/15.
//  Copyright (c) 2015 PPC Software. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail: AnyObject = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.valueForKey("noteBody")!.description
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIActivityViewController (aka "Share Sheet")
    
    @IBAction func shareNote(sender: AnyObject) {
        if let noteToShare = detailDescriptionLabel.text {
            
            let objectsToShare = [noteToShare]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //New Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList] // Leaving it in for now
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
}

