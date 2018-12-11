//
//  KCButton.m
//  Stocks
//
//  Created by Kevin Choi on 11/5/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import "KCButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation KCButton

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
    
    //[self.layer setBorderWidth:1.0f];
    //[self.layer setBorderColor:[[UIColor blackColor] CGColor]];
    //[self.layer setBorderColor:[[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] CGColor]];
    [self.layer setCornerRadius:10];
    [self.layer setBackgroundColor:[[UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0] CGColor]];
    
}


@end
