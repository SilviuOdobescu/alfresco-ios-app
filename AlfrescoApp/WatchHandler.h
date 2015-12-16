//
//  WatchHandler.h
//  AlfrescoApp
//
//  Created by Silviu Odobescu on 16/12/15.
//  Copyright © 2015 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WatchHandler : NSObject

+ (WatchHandler *)sharedManager;

@property (nonatomic, strong) id<AlfrescoSession> session;

@end
