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

@implementation BlobViewController

@synthesize webView;
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
        repository = aRepository;
        
        absolutePath = anAbsolutePath;
        commitSha = aCommitSha;
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
            self.blob = [[Blob alloc] initWithJSONObject:data absolutePath:absolutePath commitSha:commitSha];

            NSMutableString* html = [[NSMutableString alloc] initWithCapacity:self.blob.content.length + 1000];
            
            [html appendString:@"<!DOCTYPE html>\n"];
            [html appendString:@"<html><head><style>\n"];
            [html appendString:@".l { min-width: 100px; display: inline-block; text-align: right}\n"];
            [html appendString:@"body { font-family: Arial;}\n"];
            [html appendString:@"</style></head><body>\n"];
            
            NSArray* lines = [self.blob.content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            int lineNo = 1;
            for (__strong NSString* line in lines) {
                line = [line stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
                line = [line stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
                
                [html appendFormat:@"<span class=\"l\"><a href=\"open?line=%d\">%d</a></span>%@<br>", lineNo, lineNo++, line];
            }
            
            [html appendString:@"<script>\n"];
            [html appendString:@"document.querySelector(\"body\").innerHtml = \"Hallo Welt\";\n"];
            [html appendString:@"  function f(evt) {\n"];
            [html appendString:@"    location.href = \"http://www.heise.de\";"];
            [html appendString:@"      evt.target.innerHtml=\"42\";\n"];
            [html appendString:@"  }\n"];
            [html appendString:@"  document.querySelector(\"body\").addEventListener(\"mouseup\", f);\n"];
            [html appendString:@"</script>\n"];
            [html appendString:@"</body>\n"];
            [html appendString:@"</html>\n"];
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
