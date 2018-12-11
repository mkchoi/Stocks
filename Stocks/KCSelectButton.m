//
//  KCSelectButton.m
//  Stocks
//
//  Created by Kevin Choi on 22/5/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import "KCSelectButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation KCSelectButton

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
