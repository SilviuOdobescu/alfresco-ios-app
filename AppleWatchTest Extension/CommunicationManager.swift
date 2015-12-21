//
//  CommunicationManager.swift
//  AlfrescoApp
//
//  Created by Silviu Odobescu on 18/12/15.
//  Copyright © 2015 Alfresco. All rights reserved.
//

import Foundation
import WatchConnectivity

protocol TaskListDisplayDelegate
{
    func loadTasks(tasks: [AlfrescoTask]);
}

class CommunicationManager: NSObject, WCSessionDelegate
{
    static let sharedInstance = CommunicationManager();
    var session : WCSession;
    
    var taskListDelegate : TaskListDisplayDelegate? = nil;
    
    override init()
    {
        session = WCSession.defaultSession()
        
        super.init();
        
        session.delegate = self;
        session.activateSession()
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject])
    {
        let tasks = parseApplicationContext(applicationContext);
        taskListDelegate?.loadTasks(tasks);
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
    
    func sendInteractiveMessage(command : String, taskIdentifier: String)
    {
        if session.reachable
        {
            var message : [String : AnyObject] = [String : AnyObject]();
            message["command"] = command;
            message["taskIdentifier"] = taskIdentifier;
            session.sendMessage(message, replyHandler: { (response : [String : AnyObject]) -> Void in
                print(response);
                }, errorHandler: { (error : NSError) -> Void in
                    print(error);
            })
        }
    }
    
}