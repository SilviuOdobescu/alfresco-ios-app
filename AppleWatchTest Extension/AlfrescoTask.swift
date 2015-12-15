//
//  AlfrescoTaskTableRowDataSource.swift
//  AlfrescoApp
//
//  Created by Silviu Odobescu on 15/12/15.
//  Copyright © 2015 Alfresco. All rights reserved.
//

import WatchKit

class AlfrescoTask : NSObject
{
    var taskIdentifier : String
    var taskName : String
    var taskType : TaskType
    var taskPriority : TaskPriority
    var taskStartedAtDate : NSDate
    var taskDueAtDate : NSDate
    
    init(taskIdentifier taskIdentifierParam : String, taskName taskNameParam : String, taskType taskTypeParam : TaskType, taskPriority taskPriorityParam : TaskPriority, taskStartedAtDate taskStartedAtDateParam : NSDate, taskDueAtDate taskDueAtDateParam : NSDate)
    {
        taskIdentifier = taskIdentifierParam;
        taskName = taskNameParam;
        taskType = taskTypeParam;
        taskPriority = taskPriorityParam;
        taskStartedAtDate = taskStartedAtDateParam;
        taskDueAtDate = taskDueAtDateParam;
    }
}