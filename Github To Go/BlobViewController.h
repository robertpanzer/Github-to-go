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
    UITextView* textView;
    Blob* blob;
}

@property(strong) IBOutlet UITextView* textView;
@property(strong) Blob* blob;

- (id)initWithUrl:(NSString*)anUrl name:(NSString*)aName;

@end
