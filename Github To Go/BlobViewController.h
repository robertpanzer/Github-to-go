//
//  BlobViewController.h
//  Github To Go
//
//  Created by Robert Panzer on 05.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Blob.h"

@interface BlobViewController : UIViewController {
    UIScrollView* scrollView;
    Blob* blob;
    NSString* url;
    NSString* name;
}

@property(strong) IBOutlet UIScrollView* scrollView;
@property(strong) Blob* blob;
@property(strong) NSString* name;
@property(strong) NSString* url;

- (id)initWithUrl:(NSString*)anUrl name:(NSString*)aName;

@end
