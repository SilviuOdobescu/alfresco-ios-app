//
//  WatchHandler.m
//  AlfrescoApp
//
//  Created by Silviu Odobescu on 16/12/15.
//  Copyright © 2015 Alfresco. All rights reserved.
//

#import "WatchHandler.h"
@import WatchConnectivity;

static NSString * const kDateFormat = @"dd MMMM yyyy";
static NSString * const kActivitiReview = @"activitiReview";
static NSString * const kActivitiParallelReview = @"activitiParallelReview";
static NSString * const kActivitiToDo = @"activitiAdhoc";
static NSString * const kActivitiInviteNominated = @"activitiInvitationNominated";
static NSString * const kJBPMReview = @"wf:review";
static NSString * const kJBPMParallelReview = @"wf:parallelreview";
static NSString * const kJBPMToDo = @"wf:adhoc";
static NSString * const kJBPMInviteNominated = @"wf:invitationNominated";
static NSString * const kSupportedTasksPredicateFormat = @"processDefinitionIdentifier CONTAINS %@ AND NOT (processDefinitionIdentifier CONTAINS[c] 'pooled')";
static NSString * const kAdhocProcessTypePredicateFormat = @"SELF CONTAINS[cd] %@";
static NSString * const kInitiatorWorkflowsPredicateFormat = @"initiatorUsername like %@";

@interface WatchHandler() <WCSessionDelegate>

@property (nonatomic, strong) WCSession *watchSession;
@property (nonatomic, strong) AlfrescoWorkflowService *workflowService;
@property (nonatomic, strong) AlfrescoListingContext *defaultListingContext;

@end

@implementation WatchHandler

+ (WatchHandler *)sharedManager
{
    static dispatch_once_t onceToken;
    static WatchHandler *sharedAccountManager = nil;
    dispatch_once(&onceToken, ^{
        sharedAccountManager = [[self alloc] init];
    });
    return sharedAccountManager;
}

- (void)setSession:(id<AlfrescoSession>)session
{
    _session = session;
    if(_session)
    {
        [self startWatchConnectivitySetup];
    }
}

#pragma mark - Setup
- (void)startWatchConnectivitySetup
{    
    if([WCSession isSupported])
    {
        self.watchSession = [WCSession defaultSession];
        self.watchSession.delegate = self;
        [self.watchSession activateSession];
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.session];
        self.defaultListingContext = [[AlfrescoListingContext alloc] initWithMaxItems:kMaxItemsPerListingRetrieve skipCount:0];
        [self checkWatchState];
    }
}

- (void)checkWatchState
{
    if((self.watchSession.isPaired) && (self.watchSession.isWatchAppInstalled))
    {
        [self.workflowService retrieveTasksWithListingContext:self.defaultListingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
            if(pagingResult)
            {
                NSArray *resultsArray = pagingResult.objects;
                NSArray *supportedProcessIdentifiers = @[kActivitiReview, kActivitiParallelReview, kActivitiInviteNominated, kActivitiToDo, kJBPMReview, kJBPMParallelReview, kJBPMToDo, kJBPMInviteNominated];
                NSMutableArray *tasksSubpredicates = [[NSMutableArray alloc] init];
                [supportedProcessIdentifiers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [tasksSubpredicates addObject:[NSPredicate predicateWithFormat:kSupportedTasksPredicateFormat, obj]];
                }];
                
                NSPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:tasksSubpredicates];
                
                NSArray *filteredTasks = [resultsArray filteredArrayUsingPredicate:predicate];
                
                // Primary sort: priority
                NSSortDescriptor *prioritySortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES];
                
                // Seconday sort: due date
                NSSortDescriptor *dueDateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dueAt" ascending:NO comparator:^NSComparisonResult(NSDate *obj1, NSDate *obj2) {
                    // Note reversed logic here along with "ascending:NO" to get nil dates sorted to the bottom
                    return [obj2 compare:obj1];
                }];
                
                resultsArray = [[filteredTasks sortedArrayUsingDescriptors:@[prioritySortDescriptor, dueDateSortDescriptor]] mutableCopy];
                
                NSMutableDictionary *contextDictionary = [self prepareContextDictionary:resultsArray];
                NSError *updateContextError = nil;
                BOOL updateResult = [self.watchSession updateApplicationContext:contextDictionary error:&updateContextError];
                if(!updateResult)
                {
                    NSLog(@"==== Something happened while trying to update the watch application context %@", updateContextError);
                }
            }
            else
            {
                //for some reason we have an error; nothing to do here
            }
        }];
    }
}

#pragma mark - Helper methods
- (NSMutableDictionary *)prepareContextDictionary:(NSArray *)results
{
    NSMutableDictionary *returnDictionary = [NSMutableDictionary new];
    NSMutableArray *resultsArray = [NSMutableArray new];
    for(AlfrescoWorkflowTask *task in results)
    {
        NSMutableDictionary *item = [NSMutableDictionary new];
        [item setObject:task.identifier forKey:@"taskIdentifier"];
        [item setObject:task.summary forKey:@"taskName"];
        [item setObject:task.type forKey:@"taskType"];
        [item setObject:task.startedAt forKey:@"taskStartedAt"];
        [item setObject:task.dueAt forKey:@"taskDueAt"];
        [item setObject:task.priority forKey:@"taskPriority"];
        [resultsArray addObject:item];
    }
    
    [returnDictionary setObject:resultsArray forKey:@"results"];
    
    return returnDictionary;
}

#pragma mark - WCSessionDelegate methods
- (void)sessionWatchStateDidChange:(WCSession *)session
{
    self.watchSession = session;
    [self checkWatchState];
}

- (void)session:(WCSession *)session didReceiveMessage:(nonnull NSDictionary<NSString *,id> *)message replyHandler:(nonnull void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler
{
    NSLog(@"message received %@", message);
    replyHandler(@{@"reply": @"some reply"});
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message
{
    NSLog(@"message received %@", message);
}

@end
