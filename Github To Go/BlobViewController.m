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



@implementation NSString (RPFiltering)

- (NSString*) escapeCharsToHtml {
    NSString* filteredLine = self;
    filteredLine = [filteredLine stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    filteredLine = [filteredLine stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    filteredLine = [filteredLine stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp;"];
    return filteredLine;
}

-(NSString*)wrapToHtmlWithOldLineNo:(NSNumber*)oldLineNo newLineNo:(NSNumber*)newLineNo {
    NSString* class = nil;
    NSString* oldLineNoString;
    NSString* newLineNoString;
    if (oldLineNo.intValue == 0 && newLineNo.intValue > 0) {
        class = @"new";
        oldLineNoString = @"";
        newLineNoString = [NSString stringWithFormat:@"+%@", newLineNo];
    } else if (oldLineNo.intValue > 0 && newLineNo.intValue == 0) {
        class = @"old";
        oldLineNoString = [NSString stringWithFormat:@"<nobr>-%@</nobr>", oldLineNo];
        newLineNoString = @"";
    } else {
        class = @"oldAndNew";
        oldLineNoString = [oldLineNo description];
        newLineNoString = [newLineNo description];
    }
    NSString* ret = [NSString stringWithFormat:@"<tr class=\"%@\"><td>%@</td><td>%@</td><td>%@</td></tr>\n", class, oldLineNoString, newLineNoString, [self escapeCharsToHtml]];
    return ret;
}

-(NSString*)wrapToHtmlWithLineNo:(NSNumber*)lineNo {
    NSString* lineNoString = [lineNo description];
    NSString* ret = [NSString stringWithFormat:@"<tr><td>%@</td><td>%@</td></tr>\n", lineNoString, [self escapeCharsToHtml]];
    return ret;
}

@end


@implementation BlobViewController

@synthesize webView;
@synthesize blob;
@synthesize url;
@synthesize absolutePath;
@synthesize commitSha;
@synthesize repository;
@synthesize commitFile;
@synthesize showDiffs;

- (id)initWithUrl:(NSString*)anUrl absolutePath:(NSString *)anAbsolutePath commitSha:(NSString*)aCommitSha repository:(Repository*)aRepository
{
    self = [super initWithNibName:@"BlobViewController" bundle:nil];
    if (self) {
        self.url = anUrl;
        repository = aRepository;
        
        absolutePath = anAbsolutePath;
        commitSha = aCommitSha;
        showDiffs = NO;
        self.navigationItem.title = [absolutePath pathComponents].lastObject;
    }
    return self;
}

- (id)initWithCommitFile:(CommitFile*)aCommitFile
{
    self = [super initWithNibName:@"BlobViewController" bundle:nil];
    if (self) {
        url = aCommitFile.rawUrl;
        self.commitFile = aCommitFile;
        repository = aCommitFile.commit.repository;
        
        absolutePath = aCommitFile.fileName;
        commitSha = aCommitFile.commit.sha;
        showDiffs = YES;
        self.navigationItem.title = [absolutePath pathComponents].lastObject;
        
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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showBlobHistory:)];

    // Do any additional setup after loading the view from its nib.
    
    [[NetworkProxy sharedInstance] loadStringFromURL:url block:^(int statusCode, NSDictionary* headerFields, id data) {
        if (statusCode == 200) {
            if ([data isKindOfClass:[NSString class]]) {
                self.blob = [[Blob alloc] initWithRawData:data absolutePath:absolutePath commitSha:commitSha];
            } else {
                self.blob = [[Blob alloc] initWithJSONObject:data absolutePath:absolutePath commitSha:commitSha];
            }

            NSMutableString* html = [[NSMutableString alloc] initWithCapacity:self.blob.content.length + 1000];
            
            [html appendString:@"<!DOCTYPE html>\n"];
            [html appendString:@"<html><head><style>\n"];

            
            [html appendString:@"table { margin: 0px; border: 0px; border-spacing: 0px; padding:0px;  border-collapse: collapse;}\n"];
            [html appendString:@"table td { border-left: 1px solid; border-right: 1px solid; border-collapse: collapse; vertical-align: top;}\n"];
            [html appendString:@"table tr:first-child { border-top: 1px solid;}\n"];
            [html appendString:@"table tr:last-child { border-bottom: 1px solid;}\n"];
            [html appendString:@"tr td:nth-child(1) {text-align: right;}\n"];
            [html appendString:@"tr td:nth-child(2) {text-align: right;}\n"];
            [html appendString:@".old { background-color: #FF8080;height:12pt}\n"];
            [html appendString:@".new { background-color: #80FF80;height:12pt;}\n"];
            
            [html appendString:@".oldAndNew { background-color: clear; height:12pt;}\n"];
            [html appendString:@"body { font-family: Courier; font-size: 11pt;}\n"];
            [html appendString:@"</style></head><body>\n"];
            [html appendString:@"<table>\n"];
            
            NSString* originalString = self.blob.content;
            NSString* dos2unixString = [originalString stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
            NSArray* lines = [dos2unixString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

            if (self.commitFile == nil) {
                for (int i = 1; i <= lines.count; i++) {
                    NSString* line = [lines objectAtIndex:i - 1];
                    [html appendString:[line wrapToHtmlWithLineNo:[NSNumber numberWithInt:i]]];
                }
            } else {
                int maxLineNo = MAX( lines.count, MAX(commitFile.largestOldLineNo, commitFile.largestNewLineNo) );
                int oldLineCounter = 1;
                for (int i = 1; i <= maxLineNo; i++) {
                    NSString* oldLine = [self.commitFile.linesOfOldFile objectForKey:[NSNumber numberWithInt:oldLineCounter]];
                    NSString* newLine = [self.commitFile.linesOfNewFile objectForKey:[NSNumber numberWithInt:i]];
                    if (oldLine != nil) {
                        do {
                            oldLine = [self.commitFile.linesOfOldFile objectForKey:[NSNumber numberWithInt:oldLineCounter]];
                            if (oldLine != nil) {
                                [html appendString:[oldLine wrapToHtmlWithOldLineNo:[NSNumber numberWithInt:oldLineCounter] newLineNo:nil]];
                                oldLineCounter++;
                            }
                        } while (oldLine != nil);
                    }
                    if (newLine != nil) {
                        [html appendString:[newLine wrapToHtmlWithOldLineNo:nil newLineNo:[NSNumber numberWithInt:i]]];
                    } else if (lines.count > i) {
                        NSString* line = [lines objectAtIndex:i - 1];
                        [html appendString:[line wrapToHtmlWithOldLineNo:[NSNumber numberWithInt:oldLineCounter++] newLineNo:[NSNumber numberWithInt:i]]];
                    }
                }
            }            
            [html appendString:@"</table>\n"];
            [html appendString:@"</body>\n"];
            [html appendString:@"</html>\n"];
            NSLog(@"HTML:\n%@", html);
            [self.webView setScalesPageToFit:YES];
            [self.webView loadData:[html dataUsingEncoding:NSUTF8StringEncoding] MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:nil];
            self.webView.delegate = self;
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
    return YES;
}

-(void)showBlobHistory:(id)sender {    
    BranchViewController* branchViewController = [[BranchViewController alloc] initWithGitObject:blob commitSha:self.commitSha repository:repository];
    [self.navigationController pushViewController:branchViewController animated:YES];
    
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"Hier! %@", request.URL);
    if ([request.URL.path isEqualToString:@"/open"]) {
        NSLog(@"Params %@", request.URL.description );
        NSRange range = [request.URL.description rangeOfString:@"line="];
        NSString* lineno = [request.URL.description substringFromIndex:range.location + range.length ];
        NSLog(@"Hier %@ ", lineno);
    }
    return YES;
}

@end
