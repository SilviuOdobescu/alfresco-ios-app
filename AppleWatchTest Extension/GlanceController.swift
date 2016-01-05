//
//  GlanceController.swift
//  AppleWatchTest Extension
//
//  Created by Silviu Odobescu on 14/12/15.
//  Copyright © 2015 Alfresco. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: WKInterfaceController, TaskListDisplayDelegate {

    @IBOutlet var numberOfTasksLabel: WKInterfaceLabel!
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        CommunicationManager.sharedInstance.taskListDelegate = self;
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func loadTasks(tasks: [AlfrescoTask])
    {
        numberOfTasksLabel.setText(String(tasks.count));
    }

}
