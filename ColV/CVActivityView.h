//
//  CVActivityView.h
//  ColV
//
//  Created by Igor Bogatchuk on 3/7/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CVActivityView : UIView

@property (nonatomic, strong) UIActivityIndicatorView* activityIndicator;

- (void)turnArrowLeft;
- (void)turnArrowRight;

- (void)startAnimating;
- (void)stopAnimating;

- (id)initWithFrame:(CGRect)frame image:(UIImage*)image;

@end
