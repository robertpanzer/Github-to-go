//
//  BlobViewController.m
//  Github To Go
//
//  Created by Robert Panzer on 05.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BlobViewController.h"
#import "NetworkProxy.h"
#import "BranchViewController.h"

static CGFloat widthLineNumberColumn = 50.0f;
static CGFloat xOffsetContentColumn = 55.0f;

@implementation BlobViewController

@synthesize scrollView;
@synthesize blob;
@synthesize url;
@synthesize absolutePath;
@synthesize commitSha;
@synthesize repository;

- (id)initWithUrl:(NSString*)anUrl absolutePath:(NSString *)anAbsolutePath commitSha:(NSString*)aCommitSha repository:(Repository*)aRepository
{
    self = [super initWithNibName:@"BlobViewController" bundle:nil];
    if (self) {
        self.url = anUrl;
        repository = [aRepository retain];
        
        absolutePath = [anAbsolutePath retain];
        commitSha = [aCommitSha retain];
        self.navigationItem.title = [absolutePath pathComponents].lastObject;
    }
    return self;
}

- (void)dealloc {
    [scrollView release];
    [blob release];
    [url release];
    [absolutePath release];
    [repository release];
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
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showBlobHistory:)] autorelease];

    // Do any additional setup after loading the view from its nib.
    
    [[NetworkProxy sharedInstance] loadStringFromURL:url block:^(int statusCode, NSDictionary* headerFields, id data) {
        if (statusCode == 200) {
            self.blob = [[[Blob alloc] initWithJSONObject:data absolutePath:absolutePath commitSha:commitSha] autorelease];

            NSUInteger lineNumber = 1;
            NSUInteger blockStart = 0;
            CGFloat yOffset = 0;
            CGFloat maxWidth = 0;
            NSString* s = blob.content;
            NSMutableString* lineNumberString = [[[NSMutableString alloc] init] autorelease];
            [lineNumberString appendFormat:@"%d\n", lineNumber];
            for (int i = 0; i < s.length; i++) {
                unichar zeichen = [s characterAtIndex:i];
                if ([[NSCharacterSet newlineCharacterSet] characterIsMember:zeichen]) {
                    lineNumber++;
                    [lineNumberString appendFormat:@"%d\n", lineNumber];
                    if ((lineNumber % 10) == 0) {
                        NSString* block = [s substringWithRange:NSMakeRange(blockStart, i - blockStart)];
                        blockStart = i + 1;
                        UILabel* label = [[[UILabel alloc] init] autorelease];
                        label.text = block;
                        label.numberOfLines = 0;
                        label.lineBreakMode = UILineBreakModeWordWrap;
                        [label sizeToFit];
                        label.frame = CGRectMake(xOffsetContentColumn, yOffset, label.frame.size.width, label.frame.size.height);

                        UILabel* lineNumberLabel = [[[UILabel alloc] init] autorelease];
                        lineNumberLabel.text = lineNumberString;
                        lineNumberLabel.numberOfLines = 0;
                        lineNumberLabel.lineBreakMode = UILineBreakModeWordWrap;
                        [lineNumberLabel sizeToFit];
                        lineNumberLabel.textAlignment = UITextAlignmentRight;
                        lineNumberLabel.frame = CGRectMake(0.0f, yOffset, widthLineNumberColumn, label.frame.size.height);
                        lineNumberString = [[[NSMutableString alloc] init] autorelease];
                        [lineNumberString appendFormat:@"%d\n", lineNumber];
                        
                        yOffset += label.frame.size.height;
                        [scrollView addSubview:label];
                        [scrollView addSubview:lineNumberLabel];

                        if (label.frame.size.width > maxWidth) {
                            maxWidth = label.frame.size.width;
                        }
                        NSLog(@"%f, %f", label.frame.size.width, label.frame.size.height);
                    }
                }
            }
            
            NSString* lastBlock = [s substringWithRange:NSMakeRange(blockStart, s.length - blockStart)];
            UILabel* label = [[[UILabel alloc] init] autorelease];
            label.text = lastBlock;
            label.numberOfLines = 0;
            label.lineBreakMode = UILineBreakModeWordWrap;
            [label sizeToFit];
            label.frame = CGRectMake(xOffsetContentColumn, yOffset, label.frame.size.width, label.frame.size.height);
            
            UILabel* lineNumberLabel = [[[UILabel alloc] init] autorelease];
            lineNumberLabel.text = lineNumberString;
            lineNumberLabel.numberOfLines = 0;
            lineNumberLabel.lineBreakMode = UILineBreakModeWordWrap;
            [lineNumberLabel sizeToFit];
            lineNumberLabel.textAlignment = UITextAlignmentRight;
            lineNumberLabel.frame = CGRectMake(0.0f, yOffset, widthLineNumberColumn, label.frame.size.height);
            lineNumberString = [[[NSMutableString alloc] init] autorelease];
            
            
            yOffset += label.frame.size.height;
            [scrollView addSubview:label];
            [scrollView addSubview:lineNumberLabel];
            if (label.frame.size.width > maxWidth) {
                maxWidth = label.frame.size.width;
            }
            
            [scrollView setContentSize:CGSizeMake(maxWidth + 30.0f, yOffset)];
            
        }
    }];
    
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
    return YES;//(interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)showBlobHistory:(id)sender {
    
    BranchViewController* branchViewController = [[[BranchViewController alloc] initWithGitObject:blob commitSha:self.commitSha repository:repository] autorelease];
    [self.navigationController pushViewController:branchViewController animated:YES];
    
}


@end
