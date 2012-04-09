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
#import "CommitComment.h"


@implementation NSString (RPFiltering)

- (NSString*) escapeCharsToHtml {
    NSString* filteredLine = self;
    filteredLine = [filteredLine stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    filteredLine = [filteredLine stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    filteredLine = [filteredLine stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp;"];
    filteredLine = [filteredLine stringByReplacingOccurrencesOfString:@"\r\n" withString:@"<br>"];
    filteredLine = [filteredLine stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
    return filteredLine;
}

- (NSString*) escapeCharsToHtmlWithoutNbsp {
    NSString* filteredLine = self;
    filteredLine = [filteredLine stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    filteredLine = [filteredLine stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    filteredLine = [filteredLine stringByReplacingOccurrencesOfString:@"\r\n" withString:@"<br>"];
    filteredLine = [filteredLine stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
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
    NSString* ret = [NSString stringWithFormat:@"<tr class=\"%@\"><td class=\"ln\">%@</td><td class=\"ln\">%@</td><td>%@</td></tr>\n", class, oldLineNoString, newLineNoString, [self escapeCharsToHtml]];
    return ret;
}

-(NSString*)wrapToHtmlWithLineNo:(NSNumber*)lineNo {
    NSString* lineNoString = [lineNo description];
    NSString* ret = [NSString stringWithFormat:@"<tr><td>%@</td><td>%@</td></tr>\n", lineNoString, [self escapeCharsToHtml]];
    return ret;
}

-(NSString*)wrapToHtmlWithLineNo:(NSNumber*)lineNo class:(NSString*)class {
    NSString* lineNoString = [lineNo description];
    NSString* ret = [NSString stringWithFormat:@"<tr class=\"%@\"><td>%@</td><td>%@</td></tr>\n", class, lineNoString, [self escapeCharsToHtml]];
    return ret;
}


@end

@interface BlobViewController()

-(NSArray*)commentsForOldLine:(NSNumber*)lineNumber;
-(NSArray*)commentsForNewLine:(NSNumber*)lineNumber;
-(NSString*)wrapComments:(NSArray*)aComments;

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
@synthesize comments;

- (id)initWithUrl:(NSString*)anUrl absolutePath:(NSString *)anAbsolutePath commitSha:(NSString*)aCommitSha repository:(Repository*)aRepository
{
    self = [super initWithNibName:@"BlobViewController" bundle:nil];
    if (self) {
        self.url = [NSString stringWithFormat:@"https://github.com/%@/raw/%@/%@", aRepository.fullName, aCommitSha, anAbsolutePath];
        self.repository = aRepository;
        
        self.absolutePath = anAbsolutePath;
        self.commitSha = aCommitSha;
        self.showDiffs = NO;
        self.navigationItem.title = [absolutePath pathComponents].lastObject;
    }
    return self;
}

- (id)initWithCommitFile:(CommitFile*)aCommitFile comments:(NSArray*)aComments
{
    self = [super initWithNibName:@"BlobViewController" bundle:nil];
    if (self) {
        self.url = aCommitFile.rawUrl;
        self.commitFile = aCommitFile;
        self.comments = aComments;
        self.repository = aCommitFile.commit.repository;
        
        self.absolutePath = aCommitFile.fileName;
        self.commitSha = aCommitFile.commit.sha;
        self.showDiffs = YES;
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
    [[NetworkProxy sharedInstance] loadStringFromURL:self.url block:^(int statusCode, NSDictionary* headerFields, id data) {
        if (statusCode == 200) {
            NSString *contentType = [headerFields objectForKey:@"Content-Type"];
            if ([data isKindOfClass:[NSString class]]) {
                self.blob = [[Blob alloc] initWithRawData:data absolutePath:absolutePath commitSha:commitSha];
            } else if ([data isKindOfClass:[NSDictionary class]]) {
                self.blob = [[Blob alloc] initWithJSONObject:data absolutePath:absolutePath commitSha:commitSha];
            } else {
                self.blob = [[Blob alloc] initWithData:data absolutePath:self.absolutePath commitSha:commitSha];
            }
            if ([contentType hasPrefix:@"text/"]) {
                NSMutableString* html = [[NSMutableString alloc] initWithCapacity:((NSString*)self.blob.content).length + 1000];
                
                [html appendString:@"<!DOCTYPE html>\n"];
                [html appendString:@"<html><head><style>\n"];
                
                
                [html appendString:@"table { margin: 0px; border: 0px; border-spacing: 0px; padding:0px;  border-collapse: collapse;}\n"];
                [html appendString:@"table td { border-left: 1px solid; border-right: 1px solid; border-collapse: collapse; vertical-align: top;}\n"];
                [html appendString:@"table tr:first-child { border-top: 1px solid;}\n"];
                [html appendString:@"table tr:last-child { border-bottom: 1px solid;}\n"];
                [html appendString:@"tr td:nth-child(1) {min-width: 20px;}\n"];
                if (self.commitFile != nil) {
                    [html appendString:@"tr td:nth-child(2) {min-width: 20px;}\n"];
                }
                [html appendString:@".ln { text-align: right}\n"];
                [html appendString:@".old { background-color: #FF8080;height:12pt}\n"];
                [html appendString:@".new { background-color: #80FF80;height:12pt;}\n"];
                [html appendString:@".comment { background-color: #A0A0A0; height:12pt; font-family: Helvetica; -webkit-border-radius: 10px; margin:3px;}\n"];
                
                [html appendString:@".commentFirstLine { text-align: left; background-color: #C0C0C0; height:12pt; font-family: Helvetica; border: solid 1px; }\n"];
                [html appendString:@".commentBody { text-align: left; background-color: #E0E0E0; height:12pt; font-family: Helvetica; border: solid 1px; }"];
                
                [html appendString:@".oldAndNew { background-color: clear; height:12pt;}\n"];
                [html appendString:@"body { font-family: Courier; font-size: 11pt;}\n"];
                [html appendString:@"</style></head><body>\n"];
                [html appendString:@"<table>\n"];
                
                NSArray *lines = nil;
                if (![self.commitFile.status isEqualToString:@"removed"]) {
                    NSString* originalString = self.blob.content;
                    NSString* dos2unixString = [originalString stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
                    lines = [dos2unixString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                }                
                if (self.commitFile == nil) {
                    for (int i = 1; i <= lines.count; i++) {
                        NSString* line = [lines objectAtIndex:i - 1];
                        [html appendString:[line wrapToHtmlWithLineNo:[NSNumber numberWithInt:i]]];
                    }
                } else if ([self.commitFile.status isEqualToString:@"added"]) {
                    for (int i = 1; i <= lines.count; i++) {
                        NSString* line = [lines objectAtIndex:i - 1];
                        [html appendString:[line wrapToHtmlWithOldLineNo:nil newLineNo:[NSNumber numberWithInt:i]]];
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
                                    
                                    NSArray *lineComments = [self commentsForOldLine:[NSNumber numberWithInt:oldLineCounter]];
                                    if (lineComments != nil) {
                                        [html appendString:[self wrapComments:lineComments]];
                                    }
                                    
                                    oldLineCounter++;
                                }
                            } while (oldLine != nil);
                        }
                        if (newLine != nil) {
                            [html appendString:[newLine wrapToHtmlWithOldLineNo:nil newLineNo:[NSNumber numberWithInt:i]]];
                            NSArray *lineComments = [self commentsForNewLine:[NSNumber numberWithInt:i]];
                            if (lineComments != nil) {
                                [html appendString:[self wrapComments:lineComments]];
                            }
                        } else if (lines.count >= i) {
                            NSString* line = [lines objectAtIndex:i - 1];
                            [html appendString:[line wrapToHtmlWithOldLineNo:[NSNumber numberWithInt:oldLineCounter++] newLineNo:[NSNumber numberWithInt:i]]];
                        }
                    }
                }            
                [html appendString:@"</table>\n"];
                [html appendString:@"</body>\n"];
                [html appendString:@"</html>\n"];
//                 NSLog(@"HTML:\n%@", html);
                dispatch_async(dispatch_get_main_queue(), ^() {
                    self.webView.delegate = self;
                    [self.webView setScalesPageToFit:YES];
                    [self.webView loadData:[html dataUsingEncoding:NSUTF8StringEncoding] MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:nil];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^() {
                    self.webView.delegate = self;
                    [self.webView setScalesPageToFit:YES];
                    if ([data isKindOfClass:[NSData class]]) {
                        [self.webView loadData:data MIMEType:contentType textEncodingName:nil baseURL:nil];
                    } else {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Unexpected content type %@", @"Unexpected content type"), contentType] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alertView show];
                    }
                });
            }
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
    BranchViewController* branchViewController = [[BranchViewController alloc] initWithGitObject:self.blob commitSha:self.commitSha repository:repository];
    [self.navigationController pushViewController:branchViewController animated:YES];
    
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.path isEqualToString:@"/open"]) {
//        NSRange range = [request.URL.description rangeOfString:@"line="];
//        NSString* lineno = [request.URL.description substringFromIndex:range.location + range.length ];
    }
    return YES;
}



-(NSArray*)commentsForOldLine:(NSNumber*)lineNumber
{
    NSString *key = [NSString stringWithFormat:@"-%d", [lineNumber intValue]];
    NSNumber *patchLine = [self.commitFile.diffViewLineToPatchLine objectForKey:key];
    NSMutableArray *ret = [NSMutableArray array];
    for (CommitComment *comment in self.comments) {
        if (comment.position == [patchLine intValue]) {
            [ret addObject:comment];
        }
    }
    if (ret.count > 0) {
        return ret;
    } else {
        return nil;
    }
}

-(NSArray*)commentsForNewLine:(NSNumber*)lineNumber
{
    NSString *key = [NSString stringWithFormat:@"+%d", [lineNumber intValue]];
    NSNumber *patchLine = [self.commitFile.diffViewLineToPatchLine objectForKey:key];
    NSMutableArray *ret = [NSMutableArray array];
    for (CommitComment *comment in self.comments) {
        if (comment.position == [patchLine intValue]) {
            [ret addObject:comment];
        }
    }
    if (ret.count > 0) {
        return ret;
    } else {
        return nil;
    }
}

-(NSString*)wrapComments:(NSArray*)aComments {
    NSMutableString *ret = [NSMutableString string];
    for (CommitComment *comment in aComments) {
        
        NSString *firstLine = [NSString stringWithFormat:NSLocalizedString(@"%@ commented on %@", @"%@ commented on %@"), comment.user.displayname, [NSDateFormatter localizedStringFromDate:comment.createdAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle]];
        
        [ret appendString:@"<tr><td/><td/><td>\n"];
        [ret appendFormat:@"<table><tr class=\"commentFirstLine\"><td>%@\n", firstLine ];
        [ret appendFormat:@"<tr class=\"commentBody\"><td>%@\n", [comment.body escapeCharsToHtmlWithoutNbsp]];
        [ret appendString:@"</table>\n"];
    }
    return ret;
}

@end
