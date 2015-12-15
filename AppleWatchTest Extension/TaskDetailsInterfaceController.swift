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
    @IBOutlet var startedAtDate: WKInterfaceDate!
    @IBOutlet var dueAtLabel: WKInterfaceLabel!
    @IBOutlet var dueAtDate: WKInterfaceDate!

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
        case .TaskTypeReview:
            image = UIImage(named: "task_priority_high")!;
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

}
