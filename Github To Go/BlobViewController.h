//
//  BlobViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 05.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Blob.h"
#import "Repository.h"
#import "CommitFile.h"

@interface BlobViewController : UIViewController <UIWebViewDelegate> 

@property(strong, nonatomic) IBOutlet UIWebView* webView;
@property(strong, nonatomic) Blob* blob;
@property(strong, nonatomic) NSString* absolutePath;
@property(strong, nonatomic) NSString* url;
@property(strong, nonatomic, readonly) NSString* htmlUrl;
@property(strong, nonatomic) NSString* commitSha;
@property(strong, nonatomic) Repository* repository;
@property(strong, nonatomic) CommitFile* commitFile;
@property(strong, nonatomic) NSArray *comments;
@property BOOL showDiffs;

- (id)initWithUrl:(NSString*)anUrl absolutePath:(NSString*)anAbsolutePath commitSha:(NSString*)aCommitSha repository:(Repository*)aRepository;

- (id)initWithCommitFile:(CommitFile*)aCommitFile comments:(NSArray*)aComments;



@end
