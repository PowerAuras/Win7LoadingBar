//
//  ViewController.m
//  Win7Loading
//
//  Created by PowerAuras on 13-11-12.
//  Copyright (c) 2013年 PowerAuras. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    pgv=[[ProgressGradientView alloc] initWithFrame:CGRectMake(10, 200, self.view.frame.size.width-20, 15)];
    [self.view addSubview:pgv];

    [[NSTimer scheduledTimerWithTimeInterval:1.0/30 target:self selector:@selector(animationTimerFired:) userInfo:nil repeats:YES] retain];
}

- (void)animationTimerFired:(NSTimer*)theTimer {
    int re=rand()%10;
    if (re==2) {
        progress+=0.02;
        if (progress>1.1) {
            progress=0.;
        }
        [pgv setProgress:progress];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
