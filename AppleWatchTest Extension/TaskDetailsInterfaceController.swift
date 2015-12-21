//
//  TaskDetailsInterfaceController.swift
//  AlfrescoApp
//
//  Created by Silviu Odobescu on 14/12/15.
//  Copyright © 2015 Alfresco. All rights reserved.
//

import WatchKit
import Foundation


class TaskDetailsInterfaceController: WKInterfaceController
{
    @IBOutlet var taskImage: WKInterfaceImage!
    @IBOutlet var taskName: WKInterfaceLabel!
    @IBOutlet var startedAtLabel: WKInterfaceLabel!
    @IBOutlet var dueAtLabel: WKInterfaceLabel!
    @IBOutlet var startedAtDate: WKInterfaceLabel!
    @IBOutlet var dueAtDate: WKInterfaceLabel!

    var taskDataSource : AlfrescoTask!
    
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        taskDataSource = context as! AlfrescoTask;
        
        var image : UIImage;
        switch taskDataSource.taskType
        {
        case .TaskTypeToDo:
            image = UIImage(named: "cell-button-checked-filled")!;
            addMenuItemWithItemIcon(.Accept, title: "Done", action: "doneButtonPressed");
        case .TaskTypeReview:
            image = UIImage(named: "task_priority_high")!;
            addMenuItemWithItemIcon(.Accept, title: "Approve", action: "approveButtonPressed");
            addMenuItemWithItemIcon(.Decline, title: "Reject", action: "rejectButtonPressed");
        }
        image = image.imageWithRenderingMode(.AlwaysTemplate);
        
        switch taskDataSource.taskPriority
        {
        case .TaskPriorityLow:
            taskImage.setTintColor(UIColor.greenColor());
        case .TaskPriorityMedium:
            taskImage.setTintColor(UIColor.yellowColor());
        case .TaskPriorityHigh:
            taskImage.setTintColor(UIColor.redColor());
        }
        
        taskImage.setImage(image);
        taskName.setText(taskDataSource.taskName);
        
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "dd MMMM yyyy";
        startedAtDate.setText(dateFormatter.stringFromDate(taskDataSource.taskStartedAtDate));
        dueAtDate.setText(dateFormatter.stringFromDate(taskDataSource.taskDueAtDate));
    }

    override func willActivate()
    {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate()
    {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    func rejectButtonPressed()
    {
        CommunicationManager.sharedInstance.sendInteractiveMessage("Reject", taskIdentifier: taskDataSource.taskIdentifier);
    }
    
    func approveButtonPressed()
    {
        CommunicationManager.sharedInstance.sendInteractiveMessage("Approve", taskIdentifier: taskDataSource.taskIdentifier);
    }
    
    func doneButtonPressed()
    {
        CommunicationManager.sharedInstance.sendInteractiveMessage("Done", taskIdentifier: taskDataSource.taskIdentifier);
    }
}
