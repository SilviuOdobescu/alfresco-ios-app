//
//  TaskTableRow.swift
//  AlfrescoApp
//
//  Created by Silviu Odobescu on 15/12/15.
//  Copyright © 2015 Alfresco. All rights reserved.
//

import WatchKit
import Foundation

class TaskTableRow : NSObject
{
    @IBOutlet weak var taskImage: WKInterfaceImage!
    @IBOutlet weak var taskNameLabel: WKInterfaceLabel!
    
    func setup(rowDataSource : AlfrescoTask)
    {
        var image : UIImage;
        switch rowDataSource.taskType
        {
        case .TaskTypeToDo:
            image = UIImage(named: "cell-button-checked-filled")!;
        case .TaskTypeReview:
            image = UIImage(named: "task_priority_high")!;
        }
        image = image.imageWithRenderingMode(.AlwaysTemplate);
        
        switch rowDataSource.taskPriority
        {
        case .TaskPriorityLow:
            taskImage.setTintColor(UIColor.greenColor());
        case .TaskPriorityMedium:
            taskImage.setTintColor(UIColor.yellowColor());
        case .TaskPriorityHigh:
            taskImage.setTintColor(UIColor.redColor());
        }
        
        taskImage.setImage(image);
        taskNameLabel.setText(rowDataSource.taskName);
    }
}