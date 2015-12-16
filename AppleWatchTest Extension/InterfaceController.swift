//
//  InterfaceController.swift
//  AppleWatchTest Extension
//
//  Created by Silviu Odobescu on 14/12/15.
//  Copyright © 2015 Alfresco. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate
{
    @IBOutlet var tableView: WKInterfaceTable!
    var tableViewDataSource: [AlfrescoTask]!

    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context);
        
        // Configure interface objects here.
        
        let session = WCSession.defaultSession()
        session.delegate = self;
        session.activateSession()
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
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject])
    {
        tableViewDataSource = parseApplicationContext(applicationContext);
        
        tableView.setNumberOfRows(tableViewDataSource.count, withRowType: "TaskTableRow");
        for index in 0..<tableView.numberOfRows
        {
            if let controller = tableView.rowControllerAtIndex(index) as? TaskTableRow
            {
                controller.setup(tableViewDataSource[index]);
            }
        }

    }
    
    func parseApplicationContext(context: [String : AnyObject]) -> [AlfrescoTask]!
    {
        var results = [AlfrescoTask]()
        
        if let array = context["results"] as! [Dictionary<String, AnyObject>]?
        {
            for dict in array
            {
                let taskIdentifier = dict["taskIdentifier"] as! String;
                let taskName = dict["taskName"] as! String;
                let taskType = dict["taskType"] as! String;
                let taskPriority = dict["taskPriority"] as! Int;
                let taskStartedAt = dict["taskStartedAt"] as! NSDate;
                let taskDueAt = dict["taskDueAt"] as! NSDate;
                
                let task = AlfrescoTask.init(taskIdentifier: taskIdentifier, taskName: taskName, taskType: taskType, taskPriority: taskPriority, taskStartedAtDate: taskStartedAt, taskDueAtDate: taskDueAt);
                results.append(task);
            }
        }
        
        return results
    }
}
