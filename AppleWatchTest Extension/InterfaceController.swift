//
//  InterfaceController.swift
//  AppleWatchTest Extension
//
//  Created by Silviu Odobescu on 14/12/15.
//  Copyright © 2015 Alfresco. All rights reserved.
//

import WatchKit
import Foundation

enum TaskRowType : Int
{
    case TaskRowTypeToDo = 0
    case TaskRowTypeReview = 1
}

enum TaskPriority : Int
{
    case TaskPriorityLow = 0
    case TaskPriorityMedium = 1
    case TaskPriorityHigh = 2
}

class AlfrescoTaskTableRowDataSource : NSObject
{
    var taskType : TaskRowType
    var taskName : String
    var taskPriority : TaskPriority
    
    init(taskTypeParam: TaskRowType, taskNameParam: String, taskPriorityParam: TaskPriority)
    {
        taskType = taskTypeParam;
        taskName = taskNameParam;
        taskPriority = taskPriorityParam;
    }
}

class TaskTableRow : NSObject
{
    @IBOutlet weak var taskImage: WKInterfaceImage!
    @IBOutlet weak var taskNameLabel: WKInterfaceLabel!
    
    func setup(rowDataSource : AlfrescoTaskTableRowDataSource)
    {
        var image : UIImage;
        switch rowDataSource.taskType
        {
        case .TaskRowTypeToDo:
            image = UIImage(named: "cell-button-checked-filled")!;
        case .TaskRowTypeReview:
            image = UIImage(named: "task_priority_high")!;
        }
        image = image.imageWithRenderingMode(.AlwaysTemplate);
        
        switch rowDataSource.taskPriority
        {
        case .TaskPriorityLow:
            taskImage.setTintColor(UIColor.greenColor())
        case .TaskPriorityMedium:
            taskImage.setTintColor(UIColor.yellowColor())
        case .TaskPriorityHigh:
            taskImage.setTintColor(UIColor.redColor())
        }
        
        taskImage.setImage(image);
        taskNameLabel.setText(rowDataSource.taskName);
    }
}

class InterfaceController: WKInterfaceController
{
    @IBOutlet var tableView: WKInterfaceTable!
    var tableViewDataSource: [AlfrescoTaskTableRowDataSource]!

    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context);
        
        // Configure interface objects here.
        
        tableViewDataSource = [AlfrescoTaskTableRowDataSource.init(taskTypeParam: .TaskRowTypeToDo, taskNameParam: "Task To Do", taskPriorityParam: .TaskPriorityLow), AlfrescoTaskTableRowDataSource.init(taskTypeParam: .TaskRowTypeReview, taskNameParam: "Task Review with a long name ", taskPriorityParam: .TaskPriorityHigh)];
        
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
    
    

}
