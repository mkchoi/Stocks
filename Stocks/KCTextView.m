//
//  KCTextView.m
//  Stocks
//
//  Created by Kevin Choi on 16/2/15.
//  Copyright (c) 2015 Kevin Choi. All rights reserved.
//

#import "KCTextView.h"
#import <QuartzCore/QuartzCore.h>

@implementation KCTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    [self.layer setBorderWidth:1.0f];
    [self.layer setBorderColor:[[UIColor blackColor] CGColor]];
}


@end
