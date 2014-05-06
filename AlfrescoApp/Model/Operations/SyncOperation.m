//
//  SyncOperation.m
//  AlfrescoApp
//
//  Created by Mohamad Saeedi on 14/10/2013.
//  Copyright (c) 2013 Alfresco. All rights reserved.
//

#import "SyncOperation.h"

@interface SyncOperation ()
@property (nonatomic, strong) AlfrescoDocumentFolderService *documentFolderService;
@property (nonatomic, strong) AlfrescoDocument *document;
@property (nonatomic, strong) AlfrescoRequest *syncRequest;
@property (nonatomic, strong) NSStream *stream;
@property (nonatomic, strong) AlfrescoBOOLCompletionBlock downloadCompletionBlock;
@property (nonatomic, strong) AlfrescoDocumentCompletionBlock uploadCompletionBlock;
@property (nonatomic, strong) AlfrescoProgressBlock progressBlock;
@property (nonatomic, assign) BOOL isDownload;
@end

@implementation SyncOperation

- (id)initWithDocumentFolderService:(id)documentFolderService
                   downloadDocument:(AlfrescoDocument *)document
                       outputStream:outputStream
            downloadCompletionBlock:(AlfrescoBOOLCompletionBlock)downloadCompletionBlock
                      progressBlock:(AlfrescoProgressBlock)progressBlock
{
    self = [super init];
    
    if (self)
    {
        self.documentFolderService = documentFolderService;
        self.document = document;
        self.stream = outputStream;
        self.downloadCompletionBlock = downloadCompletionBlock;
        self.progressBlock = progressBlock;
        self.isDownload = YES;
    }
    return self;
}

- (id)initWithDocumentFolderService:(id)documentFolderService
                     uploadDocument:(AlfrescoDocument *)document
                        inputStream:inputStream
              uploadCompletionBlock:(AlfrescoDocumentCompletionBlock)uploadCompletionBlock
                      progressBlock:(AlfrescoProgressBlock)progressBlock
{
    self = [super init];
    
    if (self)
    {
        self.documentFolderService = documentFolderService;
        self.document = document;
        self.stream = inputStream;
        self.uploadCompletionBlock = uploadCompletionBlock;
        self.progressBlock = progressBlock;
        self.isDownload = NO;
    }
    return self;
}

- (void)main
{
    @autoreleasepool
    {
        if (self.isCancelled)
        {
            return;
        }
        __block BOOL operationCompleted = NO;
        __weak SyncOperation *weakSelf = self;
        
        if (self.isDownload)
        {
            self.syncRequest = [self.documentFolderService retrieveContentOfDocument:self.document outputStream:(NSOutputStream *)self.stream completionBlock:^(BOOL succeeded, NSError *error) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if (weakSelf.downloadCompletionBlock)
                    {
                        weakSelf.downloadCompletionBlock(succeeded, error);
                    }
                }];
                operationCompleted = YES;
                
            } progressBlock:^(unsigned long long bytesTransferred, unsigned long long bytesTotal) {
                weakSelf.progressBlock(bytesTransferred, bytesTotal);
            }];
        }
        else
        {
            self.syncRequest = [self.documentFolderService updateContentOfDocument:self.document contentStream:(AlfrescoContentStream *)self.stream completionBlock:^(AlfrescoDocument *uploadedDocument, NSError *error) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if (weakSelf.uploadCompletionBlock)
                    {
                        weakSelf.uploadCompletionBlock(uploadedDocument, error);
                    }
                }];
                operationCompleted = YES;
                
            } progressBlock:^(unsigned long long bytesTransferred, unsigned long long bytesTotal) {
                weakSelf.progressBlock(bytesTransferred, bytesTotal);
            }];
        }
        
        while (![self isCancelled] && !operationCompleted)
        {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
}

- (void)cancelOperation
{
    [self.syncRequest cancel];
    [self cancel];
}

- (void)dealloc
{
    self.documentFolderService = nil;
    self.document = nil;
    self.stream = nil;
    self.downloadCompletionBlock = nil;
    self.uploadCompletionBlock = nil;
    self.progressBlock = nil;
}

@end