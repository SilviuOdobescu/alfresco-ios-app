//
//  InterfaceController.swift
//  AppleWatchTest Extension
//
//  Created by Silviu Odobescu on 14/12/15.
//  Copyright © 2015 Alfresco. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController, TaskListDisplayDelegate
{
    @IBOutlet var tableView: WKInterfaceTable!
    var tableViewDataSource: [AlfrescoTask]!

    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context);
        
        // Configure interface objects here.
        CommunicationManager.sharedInstance.taskListDelegate = self;
    }

    override func willActivate()
    {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate();
    }

    override func didDeactivate()
    {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate();
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject?
    {
        return tableViewDataSource[rowIndex];
    }
    
    func loadTasks(tasks: [AlfrescoTask])
    {
        tableViewDataSource = tasks;
        tableView.setNumberOfRows(tableViewDataSource.count, withRowType: "TaskTableRow");
        for index in 0..<tableViewDataSource.count
        {
            if let controller = tableView.rowControllerAtIndex(index) as? TaskTableRow
            {
                controller.setup(tableViewDataSource[index]);
            }
        }
    }
}
