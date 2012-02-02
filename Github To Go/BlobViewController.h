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

@interface BlobViewController : UIViewController <UIWebViewDelegate> {
    UIWebView* webView;
    Blob* blob;
    NSString* url;
    NSString* name;
    NSString* commitSha;
    Repository* repository;
}

@property(strong) IBOutlet UIWebView* webView;
@property(strong) Blob* blob;
@property(readonly, strong) NSString* absolutePath;
@property(strong) NSString* url;
@property(strong) NSString* commitSha;
@property(strong, readonly) Repository* repository;

- (id)initWithUrl:(NSString*)anUrl absolutePath:(NSString*)anAbsolutePath commitSha:(NSString*)aCommitSha repository:(Repository*)aRepository;

@end
