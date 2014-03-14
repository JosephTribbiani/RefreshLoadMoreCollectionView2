//
//  CVActivityView.m
//  ColV
//
//  Created by Igor Bogatchuk on 3/7/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "CVActivityView.h"

#define ACTIVITY_VIEW_WIDTH 60
#define INDICATOR_SIDE_WIDTH 30

#define ANIMATION_DURATION 0.2

@interface CVActivityView()

@property (nonatomic, strong) UIImageView* arrowImageView;

@end

@implementation CVActivityView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_activityIndicator setFrame:CGRectMake(frame.size.width/2 - INDICATOR_SIDE_WIDTH/2, frame.size.height/2 - INDICATOR_SIDE_WIDTH/2, INDICATOR_SIDE_WIDTH, INDICATOR_SIDE_WIDTH)];
        [self addSubview:_activityIndicator];
    
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width/2 - INDICATOR_SIDE_WIDTH/2, frame.size.height/2 - INDICATOR_SIDE_WIDTH/2, INDICATOR_SIDE_WIDTH, INDICATOR_SIDE_WIDTH)];
        [_arrowImageView setImage:[UIImage imageNamed:@"arrow.png"]];
        [self addSubview:_arrowImageView];
        [_arrowImageView setHidden:NO];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame image:(UIImage*)image
{
    self = [self initWithFrame:frame];
    [self.arrowImageView setImage:image];
    return self;
}

- (void)turnArrowLeft
{
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI * 0 / 180.0);
    } completion:^(BOOL finished) {
    }];
}

- (void)turnArrowRight
{
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI * 180 / 180.0);
    } completion:^(BOOL finished) {
    }];
}

- (void)startAnimating
{
    [self.arrowImageView setHidden:YES];
    [self.activityIndicator startAnimating];
}

- (void)stopAnimating
{
    [self.arrowImageView setHidden:NO];
    [self.activityIndicator stopAnimating];
}

@end
