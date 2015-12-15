//
//  InterfaceController.swift
//  AppleWatchTest Extension
//
//  Created by Silviu Odobescu on 14/12/15.
//  Copyright © 2015 Alfresco. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController
{
    @IBOutlet var tableView: WKInterfaceTable!
    var tableViewDataSource: [AlfrescoTask]!

    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context);
        
        // Configure interface objects here.
        
//        tableViewDataSource = [AlfrescoTask.init(taskTypeParam: .TaskTypeToDo, taskNameParam: "Task To Do", taskPriorityParam: .TaskPriorityLow), AlfrescoTask.init(taskTypeParam: .TaskTypeReview, taskNameParam: "Task Review with a long name ", taskPriorityParam: .TaskPriorityHigh)];
        
        tableView.setNumberOfRows(tableViewDataSource.count, withRowType: "TaskTableRow");
        for index in 0..<tableView.numberOfRows
        {
            if let controller = tableView.rowControllerAtIndex(index) as? TaskTableRow
            {
                controller.setup(tableViewDataSource[index]);
            }
        }
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
}
