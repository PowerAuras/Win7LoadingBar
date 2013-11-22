//
//  ProgressGradientView.m
//  win7loading
//
//  Created by PowerAuras on 13-11-11.
//  Copyright (c) 2013年 PowerAuras. All rights reserved.
//

#import "ProgressGradientView.h"
#define GradientColor1 (id)[UIColor colorWithRed:29./255 green:182./255 blue:37./255 alpha:1.].CGColor
#define GradientColor2 (id)[UIColor colorWithRed:87./255 green:240./255 blue:94./255 alpha:1.].CGColor
#define GradientColor3 (id)[UIColor colorWithRed:29./255 green:182./255 blue:37./255 alpha:1.].CGColor
#define fsw self.frame.size.width
#define fsh self.frame.size.height
#define BarInset              1

#define CORNERRADIUS 2.5
static const CGFloat gradientWidth = 0.2;
static const int animationFramesPerSec = 30;

@interface ProgressGradientView ()
{
    CGRect innerRect;
}
@end
@implementation ProgressGradientView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor=[UIColor colorWithRed:175./255 green:175./255 blue:175./255 alpha:1.];
    innerRect = CGRectMake(BarInset,
                                  BarInset,
                                  frame.size.width  - 2 * BarInset,
                                  frame.size.height - 2 * BarInset);
   
    if (self) {
        // Initialization code
        self.layer.cornerRadius=CORNERRADIUS;
        self.layer.masksToBounds=YES;
        NSMutableArray *colors = [NSMutableArray arrayWithObjects:GradientColor1,GradientColor2,GradientColor3, nil];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame     =innerRect;
        gradient.colors    = colors;
        gradient.locations = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0.f],
                              [NSNumber numberWithFloat:0.3f],
                              [NSNumber numberWithFloat:0.6],
                              nil];
        gradient.cornerRadius=CORNERRADIUS;
        gradient.masksToBounds=YES;
        gradient.startPoint=CGPointMake(0., 0.5);
        gradient.endPoint=CGPointMake(1, .5);
        [self.layer addSublayer:gradient];
        //添加玻璃质感
        {
            CGColorRef glossStart = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.6].CGColor;
            CGColorRef glossEnd = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2].CGColor;
            NSArray *ary=[NSArray arrayWithObjects:
                          (id)glossStart,(id)glossEnd,
                          nil];
            
            CAGradientLayer *layeco=[CAGradientLayer layer];
            layeco.frame=CGRectMake(0, 0, frame.size.width, frame.size.height/2);
            layeco.colors=ary;
            layeco.startPoint=CGPointMake(0, 0);
            layeco.endPoint=CGPointMake(0, 1.);
            [self.layer addSublayer:layeco];

        }
        //添加shape
        {
            mask = [CAShapeLayer layer];
            [mask setFillRule:kCAFillRuleEvenOdd];
            [mask setFillColor:[UIColor colorWithRed:202./255 green:202./255 blue:202./255 alpha:1.].CGColor];
            [gradient addSublayer:mask];
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:
                                      CGRectMake(0, 0, innerRect.size.width, innerRect.size.height)
                                       cornerRadius:CORNERRADIUS];
            UIBezierPath *cutoutPath =[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 0, innerRect.size.height) byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(CORNERRADIUS, CORNERRADIUS)];
            [maskPath appendPath:cutoutPath];
            mask.path = maskPath.CGPath;
            
            //启动shape定时器
            if (animationTimer == nil)
            {
                animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30
                                                                       target:self
                                                                     selector:@selector(setNeedsDisplay)
                                                                     userInfo:nil
                                                                      repeats:YES];
            }
        }
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	if (++animationTimerCount == (2. * animationFramesPerSec)) {
		animationTimerCount = 0;
	}
	[self setGradientLocations:((CGFloat)animationTimerCount/(CGFloat)animationFramesPerSec)];
}
- (void) setGradientLocations:(CGFloat) leftEdge {
	leftEdge -= gradientWidth;
	gradientLocations[0] = leftEdge < 0.0 ? 0.0 : (leftEdge > 1.0 ? 1.0 : leftEdge);
	gradientLocations[1] = MIN(leftEdge + gradientWidth, 1.0);
	gradientLocations[2] = MIN(gradientLocations[1] + gradientWidth, 1.0);
	//尽量保证 [0][1][2]相差0.2
    
    CAGradientLayer *layer=[[self.layer sublayers] objectAtIndex:0];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    layer.locations = [NSArray arrayWithObjects:
                       
                       [NSNumber numberWithFloat:gradientLocations[0]],
                       [NSNumber numberWithFloat:gradientLocations[1]],
                       [NSNumber numberWithFloat:gradientLocations[2]],
                       
                       nil];
    [CATransaction commit];
}
- (void)setProgress:(float)progress animated:(BOOL)animated{
    progress=progress<0.0?0.0:progress;
    progress=progress>1.0?1.0:progress;
    //0~9
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:
                              CGRectMake(0, 0, innerRect.size.width, innerRect.size.height)
                                                        cornerRadius:CORNERRADIUS];
    CGFloat width=(fsw-2*BarInset)*progress;
    
    UIBezierPath *cutoutPath =[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, innerRect.size.height)];
    
    [maskPath appendPath:cutoutPath];
    if (animated) {
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
        anim.delegate = self;
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        anim.duration = .3;
        anim.removedOnCompletion = NO;
        anim.fillMode = kCAFillModeForwards;
        anim.fromValue = (__bridge id)(mask.path);
        anim.toValue = (__bridge id)(maskPath.CGPath);
        [mask addAnimation:anim forKey:@"path"];
        mask.path = maskPath.CGPath;
    }else{
        mask.path = maskPath.CGPath;
    }

}
- (void)setProgress:(float)progress{
    [self setProgress:progress animated:YES];
}
-(void)dealloc{
    if (animationTimer && [animationTimer isValid])
    {
        [animationTimer invalidate];
    }
    
    [animationTimer release];
    [super dealloc];
}
@end