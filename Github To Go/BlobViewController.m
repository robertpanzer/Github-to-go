//
//  BlobViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 05.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BlobViewController.h"
#import "NetworkProxy.h"

@implementation BlobViewController

@synthesize textView;
@synthesize blob;

- (id)initWithUrl:(NSString*)anUrl name:(NSString*)aName
{
    self = [super initWithNibName:@"BlobViewController" bundle:nil];
    if (self) {
        self.navigationItem.title = aName;
        [[NetworkProxy sharedInstance] loadStringFromURL:anUrl block:^(int statusCode, id data) {
            if (statusCode == 200) {
                self.blob = [[[Blob alloc] initWithJSONObject:data andName:aName] autorelease];
                self.textView.text = self.blob.content;
            }
        }];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
