//
//  SyncCell.m
//  AlfrescoApp
//
//  Created by Mohamad Saeedi on 30/09/2013.
//  Copyright (c) 2013 Alfresco. All rights reserved.
//

#import "SyncCell.h"
#import "SyncNodeStatus.h"

NSString * const kSyncTableCellIdentifier = @"SyncCellIdentifier";

@implementation SyncCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)statusChanged:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    if ([[info objectForKey:kSyncStatusNodeIdKey] isEqualToString:self.node.identifier])
    {
        SyncNodeStatus *nodeStatus = notification.object;
        NSString *propertyChanged = [info objectForKey:kSyncStatusPropertyChangedKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateCellWithNodeStatus:nodeStatus propertyChanged:propertyChanged];
        });
    }
}

- (void)updateCellWithNodeStatus:(SyncNodeStatus *)nodeStatus propertyChanged:(NSString *)propertyChanged
{
    if ([propertyChanged isEqualToString:kSyncStatus])
    {
        [self setAccessoryViewForState:nodeStatus.status];
        [self updateDetails:nodeStatus];
    }
    [self updateStatusImageForSyncState:nodeStatus.status];
    
    if (nodeStatus.status == SyncStatusLoading && nodeStatus.bytesTransfered > 0 && nodeStatus.bytesTransfered < nodeStatus.bytesTotal)
    {
        self.progressBar.hidden = NO;
        float percentTransfered = (float)nodeStatus.bytesTransfered / (float)nodeStatus.bytesTotal;
        self.progressBar.progress = percentTransfered;
    }
    else
    {
        self.progressBar.hidden = YES;
    }
}

- (void)updateStatusImageForSyncState:(SyncStatus)syncStatus
{
    UIImage *statusImage = nil;
    switch (syncStatus)
    {
        case SyncStatusFailed:
            statusImage = [UIImage imageNamed:@"sync-status-failed"];
            break;
            
        case SyncStatusLoading:
            statusImage = [UIImage imageNamed:@"sync-status-loading"];
            break;
            
        case SyncStatusOffline:
            /**
             * NOTE: This image doesn't actually exist in the current codebase!
             */
            statusImage = [UIImage imageNamed:@"sync-status-offline"];
            break;
            
        case SyncStatusSuccessful:
            statusImage = [UIImage imageNamed:@"sync-status-success"];
            break;
            
        case SyncStatusCancelled:
            statusImage = [UIImage imageNamed:@"sync-status-failed"];
            break;
            
        case SyncStatusWaiting:
            statusImage = [UIImage imageNamed:@"sync-status-pending"];
            break;
            
        case SyncStatusDisabled:
            statusImage = nil;
            break;
            
        default:
            break;
    }
    self.status.image = statusImage;
}

- (void)setAccessoryViewForState:(SyncStatus)status
{
    UIImage *buttonImage = nil;
    UIButton *button = nil;
    
    switch (status)
    {
        case SyncStatusLoading:
            buttonImage = [UIImage imageNamed:@"stop-transfer"];
            break;
            
        case SyncStatusFailed:
            buttonImage = [UIImage imageNamed:@"ui-button-bar-badge-error.png"];
            break;
            
        default:
            break;
    }
    
    if (buttonImage)
    {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height)];
        [button setImage:buttonImage forState:UIControlStateNormal];
        [button setShowsTouchWhenHighlighted:YES];
        
        [button addTarget:self action:@selector(accessoryButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        button = [UIButton buttonWithType:UIButtonTypeInfoDark];
        [button addTarget:self action:@selector(accessoryButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.node.isFolder)
    {
        self.accessoryView = nil;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        [self setAccessoryView:button];
    }
}

- (void)updateDetails:(SyncNodeStatus *)nodeStatus
{
    if (nodeStatus.status == SyncStatusWaiting)
    {
        self.details.text = NSLocalizedString(@"sync.state.waiting-to-sync", @"waiting to sync");
    }
    else if (nodeStatus.status == SyncStatusFailed)
    {
        self.details.text = NSLocalizedString(@"sync.state.failed-to-sync", @"failed to sync");
    }
    else
    {
        self.details.text = self.nodeDetails;
    }
}

#pragma mark - Private Methods

- (void)accessoryButtonTapped:(UIControl *)button withEvent:(UIEvent *)event
{
    UIView *cell = button.superview;
    
    if (![cell isKindOfClass:[UITableViewCell class]])
    {
        cell = (UITableViewCell *)cell.superview;
    }
    UIView *table = cell.superview;
    
    if (![table isKindOfClass:[UITableView class]])
    {
        table = (UITableView *)table.superview;
    }
    UITableView *tableView = (UITableView *)table;
    
    NSIndexPath *indexPath = [tableView indexPathForCell:(UITableViewCell *)cell];
    [tableView.delegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end