//
//  FileDiffViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 14.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FileDiffViewController.h"
#import "CommitFile.h"
#import "BlobViewController.h"

@implementation FileDiffViewController

@synthesize label;
@synthesize commitFile;
@synthesize scrollView;

- (id)initWithCommitFile:(CommitFile*)aCommitFile
{
    self = [super initWithNibName:@"FileDiffViewController" bundle:nil];
    if (self) {
        // Custom initialization
        self.commitFile = aCommitFile;
        
        [self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showFile:)] autorelease]];
    }
    return self;
}

- (void)dealloc {
    [label release];
    [commitFile release];
    [scrollView release];
    [super dealloc];
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
    label = [[UILabel alloc] init];
    label.text = commitFile.patch;
    label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    label.numberOfLines = 0;
    label.lineBreakMode = UILineBreakModeWordWrap;
    [label sizeToFit];
    [scrollView addSubview:label];
    [scrollView setContentSize:label.frame.size];
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
    return YES;
}

-(void)showFile:(id)sender {
    
    NSString* blobUrl = [NSString stringWithFormat:@"https://api.github.com/repos/%@/git/blobs/%@", commitFile.commit.repository.fullName, commitFile.blobSha];
    
    BlobViewController* blobViewController = [[[BlobViewController alloc] initWithUrl:blobUrl name:commitFile.fileName] autorelease];
    [self.navigationController pushViewController:blobViewController animated:YES];
}

@end