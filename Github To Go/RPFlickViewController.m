//
//  RPViewController.m
//  TableTest
//
//  Created by Robert Panzer on 01.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RPFlickViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface RPFlipViewHeaderView : UIView

@property(strong, nonatomic) NSArray *titles;
@property(nonatomic) NSInteger currentTitle;
@property(nonatomic, assign) CGLayerRef layerRef;

@end

@implementation RPFlipViewHeaderView

@synthesize titles;
@synthesize currentTitle;
@synthesize layerRef;

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.contentMode = UIViewContentModeRedraw;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

-(void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGFloat width = self.frame.size.width / titles.count;

    // Draw the texts on a layer
    // Create layer
    if (layerRef == nil) {
        layerRef = CGLayerCreateWithContext(context, self.frame.size, nil);   
        CGContextRef layerContext = CGLayerGetContext(layerRef);
        // Fill it with the background image but clip it because it will be scaled otherwise
        UIImage *backgroundImage = [UIImage imageNamed:@"background"];
        CGContextClipToRect(layerContext, CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height));
        CGContextDrawImage(layerContext, CGRectMake(0.0f, 0.0f, backgroundImage.size.width, backgroundImage.size.height),     backgroundImage.CGImage);
        
        // Draw the strings using UIKit draw methods
        UIGraphicsPushContext(layerContext);
        // Set Blend mode to clear because we want to let the background shine through
        CGContextSetBlendMode(layerContext, kCGBlendModeClear);
        CGContextSetFillColorWithColor(layerContext, [UIColor clearColor].CGColor);
        
        for (int i = 0; i < titles.count; i++) {
            CGContextSetBlendMode(layerContext, kCGBlendModeNormal);
            CGContextSetFillColorWithColor(layerContext, [UIColor darkGrayColor].CGColor);

            [(NSString*)[titles objectAtIndex:i] drawInRect:CGRectMake(width * i + 1.0f, 4.0f, width, 17.0f) 
                                                   withFont:[UIFont boldSystemFontOfSize:13.0f] 
                                              lineBreakMode:UILineBreakModeTailTruncation 
                                                  alignment:UITextAlignmentCenter];

            CGContextSetBlendMode(layerContext, kCGBlendModeClear);
            CGContextSetFillColorWithColor(layerContext, [UIColor clearColor].CGColor);
            
            [(NSString*)[titles objectAtIndex:i] drawInRect:CGRectMake(width * i, 3.0f, width, 17.0f) 
                                                   withFont:[UIFont boldSystemFontOfSize:13.0f] 
                                              lineBreakMode:UILineBreakModeTailTruncation 
                                                  alignment:UITextAlignmentCenter];
        }
        
        UIGraphicsPopContext();
    }
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, self.frame.size.width, 20.0f));
    // Now draw a block in blue behind the text that is current select
    CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
    CGContextFillRect(context, CGRectMake(currentTitle*width, 0.0f, width, 20.0f));
    // And draw the texts on top so that the block shines through the text
    CGContextDrawLayerAtPoint(context, CGPointMake(0.0f, 0.0f), layerRef);
}

-(void)setCurrentTitle:(NSInteger)aCurrentTitle {
    currentTitle = aCurrentTitle;
    [self setNeedsDisplay];
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (self.layerRef != NULL) {
        CGLayerRelease(self.layerRef);
        self.layerRef = NULL;
    }
}

@end



static int kGestureStatePossible = 0;
static int kGestureStateFailed   = 1;
static int kGestureStateSuccess  = 2;

@interface RPFlickViewController ()

@property(strong, nonatomic) RPFlipViewHeaderView *header;
@property(nonatomic) NSUInteger currentViewIndex;
@property(nonatomic) NSUInteger gestureState;

-(void)pan:(UIPanGestureRecognizer*)sender;

-(UIViewController*) currentViewController;

-(UIViewController*) leftViewController;

-(UIViewController*) rightViewController;

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

@end

@implementation RPFlickViewController

@synthesize currentViewIndex;
@synthesize gestureState;
@synthesize header;
@synthesize titles;

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
    }
    return self;
}


-(void)setChildViewControllers:(NSArray*)childViewControllers {
    for (UIViewController* childViewController in childViewControllers) {
        [self addChildViewController:childViewController];
        childViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.contentMode = UIViewContentModeRedraw;
    
    UIPanGestureRecognizer *panGesturerecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    panGesturerecognizer.delegate = self;
    [self.view addGestureRecognizer:panGesturerecognizer];
    
    self.currentViewIndex = 0;
    header = [[RPFlipViewHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 20.0f)];
    header.titles = self.titles;
    header.currentTitle = 0;
    [self.view addSubview:header];

    
    
    self.leftViewController.view.frame = CGRectMake(-self.view.frame.size.width, 20.0f, self.view.frame.size.width, self.view.frame.size.height - 20.0f);
    self.currentViewController.view.frame = CGRectMake(0.0f, 20.0f, self.view.frame.size.width, self.view.frame.size.height - 20.0f);
    self.rightViewController.view.frame = CGRectMake(self.view.frame.size.width, 20.0f, self.view.frame.size.width, self.view.frame.size.height - 20.0f);
    
    [self.view addSubview:self.leftViewController.view];
    [self.view addSubview:self.currentViewController.view];
    [self.view addSubview:self.rightViewController.view];
    
    self.header.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 20.0f);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.header = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    self.leftViewController.view.hidden = NO;
    self.leftViewController.view.frame = CGRectMake(-self.view.frame.size.width, 20.0f, self.view.frame.size.width, self.view.frame.size.height - 20.0f);
    
    self.currentViewController.view.hidden = NO;
    self.currentViewController.view.frame = CGRectMake(0.0f, 20.0f, self.view.frame.size.width, self.view.frame.size.height - 20.0f);
    
    self.rightViewController.view.hidden = NO;
    self.rightViewController.view.frame = CGRectMake(self.view.frame.size.width, 20.0f, self.view.frame.size.width, self.view.frame.size.height - 20.0f);

}

-(void)pan:(UIPanGestureRecognizer*)sender {
    CGPoint translation = [sender translationInView:self.view];

    if (sender.state == UIGestureRecognizerStateBegan) {
        self.gestureState = kGestureStatePossible;
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.currentViewController.view isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView*)self.currentViewController.view).scrollEnabled = YES;
        }
        if (self.gestureState == kGestureStateSuccess) {
            if (translation.x > 100.0f) {
                
                [UIView beginAnimations:@"swipe" context:nil];
                self.leftViewController.view.frame = CGRectMake(0.0f, 20.0f, self.view.frame.size.width, self.view.frame.size.height - 20.0f);
                self.currentViewController.view.frame = CGRectMake(self.view.frame.size.width, 20.0f, self.view.frame.size.width, self.view.frame.size.height - 20.0f);
                [self.rightViewController.view removeFromSuperview];
                self.currentViewIndex --;
                if (self.currentViewIndex == -1) {
                    self.currentViewIndex =  self.childViewControllers.count - 1;
                }
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
                [UIView commitAnimations];
                
                
            } else if (translation.x < -100.0f) {
                [UIView beginAnimations:@"swipe" context:nil];
                [self.leftViewController.view removeFromSuperview];
                self.currentViewController.view.frame = CGRectMake(-self.view.frame.size.width, 20.0f, self.view.frame.size.width, self.view.frame.size.height - 20.0f);
                self.rightViewController.view.frame = CGRectMake(0.0f, 20.0f, self.view.frame.size.width, self.view.frame.size.height - 20.0f);
                self.currentViewIndex ++;
                if (self.currentViewIndex == self.childViewControllers.count) {
                    self.currentViewIndex = 0;
                }
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
                [UIView commitAnimations];
            } else {
                [UIView beginAnimations:@"swipe" context:nil];
                self.leftViewController.view.frame = CGRectMake(-self.view.frame.size.width, 20.0f, self.view.frame.size.width, self.view.frame.size.height - 20.0f);
                self.currentViewController.view.frame = CGRectMake(0.0f, 20.0f, self.view.frame.size.width, self.view.frame.size.height - 20.0f);
                self.rightViewController.view.frame = CGRectMake(self.view.frame.size.width, 20.0f, self.view.frame.size.width, self.view.frame.size.height - 20.0f);
                [UIView commitAnimations];
                
            }
        }
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        if (self.gestureState == kGestureStatePossible) {
            if (ABS(translation.x) > 10.0f) {
                if ([self.currentViewController.view isKindOfClass:[UIScrollView class]]) {
                    ((UIScrollView*)self.currentViewController.view).scrollEnabled = NO;
                }
                self.gestureState = kGestureStateSuccess;
            } else {
                if (ABS(translation.y) > 10.0f) {
                    self.gestureState = kGestureStateFailed;
                }
            }
        } 
        if (self.gestureState == kGestureStatePossible || self.gestureState == kGestureStateSuccess) {
            self.leftViewController.view.frame = CGRectMake(-self.view.frame.size.width + translation.x, 20.0f, self.view.frame.size.width, self.view.frame.size.height - 20.0f);
            self.currentViewController.view.frame = CGRectMake(translation.x, 20.0f, self.view.frame.size.width, self.view.frame.size.height - 20.0f);
            self.rightViewController.view.frame = CGRectMake(self.view.frame.size.width + translation.x, 20.0f, self.view.frame.size.width, self.view.frame.size.height - 20.0f);
        }
    } else if (sender.state == UIGestureRecognizerStateCancelled || sender.state == UIGestureRecognizerStateFailed) {
        if ([self.currentViewController.view isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView*)self.currentViewController.view).scrollEnabled = YES;
        }
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(UIView *)currentViewController {
    return [self.childViewControllers objectAtIndex:self.currentViewIndex];
}

-(UIView *)leftViewController {
    NSInteger leftIndex = self.currentViewIndex - 1;
    if (leftIndex < 0) {
        leftIndex = leftIndex + self.childViewControllers.count;
    }
    return [self.childViewControllers objectAtIndex:leftIndex];
}

-(UIView *)rightViewController {
    NSUInteger rightIndex = (self.currentViewIndex + 1) % self.childViewControllers.count;
    return [self.childViewControllers objectAtIndex:rightIndex];
}


- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if (![[self.view subviews] containsObject:self.leftViewController.view]) {
        [self.view addSubview:self.leftViewController.view];
    }
    self.leftViewController.view.frame = CGRectMake(-self.view.frame.size.width, 20.0f, self.view.frame.size.width, self.view.frame.size.height - 20.0f);

    self.currentViewController.view.frame = CGRectMake(0.0f, 20.0f, self.view.frame.size.width, self.view.frame.size.height - 20.0f);

    if (![[self.view subviews] containsObject:self.rightViewController.view]) {
        [self.view addSubview:self.rightViewController.view];
    }
    self.rightViewController.view.frame = CGRectMake(self.view.frame.size.width, 20.0f, self.view.frame.size.width, self.view.frame.size.height - 20.0f);
}

-(void)setCurrentViewIndex:(NSUInteger)aCurrentViewIndex {
    currentViewIndex = aCurrentViewIndex;
    self.header.currentTitle = aCurrentViewIndex;
    [self.header setNeedsDisplay];
}

@end

