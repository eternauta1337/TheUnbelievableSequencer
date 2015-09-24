//
//  SequencerCell.m
//  TheUnbelievableSequencer
//
//  Created by Alejandro Santander on 7/20/15.
//  Copyright (c) 2015 Humane Engineering. All rights reserved.
//

#import "SequencerCell.h"

NSString *const SEQUENCER_CELL_NOTIFICATION_TOUCH_DOWN = @"SEQUENCER_CELL_NOTIFICATION_TOUCH_DOWN";

@implementation SequencerCell {
    UIColor *_color;
}

// -------------------------------------------------------------------------------------------
#pragma mark - INIT
// -------------------------------------------------------------------------------------------

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.enabled = NO;
    
    // Tap.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [self addGestureRecognizer:tap];
}

// ---------------------------------------------------------------------------------------------------------
#pragma mark - GESTURES
// ---------------------------------------------------------------------------------------------------------

- (void)handleTap {
    
    // Notify.
    [[NSNotificationCenter defaultCenter] postNotificationName:SEQUENCER_CELL_NOTIFICATION_TOUCH_DOWN
                                                        object:self
                                                      userInfo:@{@"indexPath":_indexPath}];
}

// ---------------------------------------------------------------------------------------------------------
#pragma mark - INTERFACE
// ---------------------------------------------------------------------------------------------------------

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    _color = _enabled ? [UIColor redColor] : [UIColor darkGrayColor];
    [self setNeedsDisplay];
}

// -------------------------------------------------------------------------------------------
#pragma mark - CUSTOM DRAWING
// -------------------------------------------------------------------------------------------

- (void)drawRect:(CGRect)rect {
    
    // Draw bg square with border.
    float inflate = 1;
    CGRect rect1 = CGRectMake(inflate, inflate, rect.size.width - 2 * inflate, rect.size.height - 2 * inflate);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [_color setStroke];
    [_color setFill];
    CGContextFillRect(context, rect1);
}

@end
















