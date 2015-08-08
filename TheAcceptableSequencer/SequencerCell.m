//
//  SequencerCell.m
//  SequencerExperiment
//
//  Created by Alejandro Santander on 7/20/15.
//  Copyright (c) 2015 Humane Engineering. All rights reserved.
//

#import "SequencerCell.h"

NSString *const SEQUENCER_CELL_NOTIFICATION_TOUCH_DOWN = @"SEQUENCER_CELL_NOTIFICATION_TOUCH_DOWN";
NSString *const SEQUENCER_CELL_NOTIFICATION_TOUCH_UP = @"SEQUENCER_CELL_NOTIFICATION_TOUCH_UP";

@implementation SequencerCell {
    UIColor *_color;
    UIButton *_button;
    BOOL _needsButtonSize;
}

// -------------------------------------------------------------------------------------------
#pragma mark - INIT
// -------------------------------------------------------------------------------------------

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _needsButtonSize = YES;
    
    // Bg Color.
    self.enabled = NO;
    
    // Interaction.
    _button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [_button addTarget:self action:@selector(onTouchDown) forControlEvents:UIControlEventTouchDown];
    [_button addTarget:self action:@selector(onTouchUp) forControlEvents:UIControlEventTouchUpInside];
    [_button addTarget:self action:@selector(onTouchUp) forControlEvents:UIControlEventTouchUpOutside];
    _button.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_button];
}

// ---------------------------------------------------------------------------------------------------------
#pragma mark - GESTURES
// ---------------------------------------------------------------------------------------------------------

- (void)onTouchDown {
    
    // Notify.
    [[NSNotificationCenter defaultCenter] postNotificationName:SEQUENCER_CELL_NOTIFICATION_TOUCH_DOWN
                                                        object:self
                                                      userInfo:@{@"indexPath":_indexPath}];
}

- (void)onTouchUp {
    
    // Notify.
    [[NSNotificationCenter defaultCenter] postNotificationName:SEQUENCER_CELL_NOTIFICATION_TOUCH_UP
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
    
    if(_needsButtonSize) {
        [self fitButton];
        _needsButtonSize = NO;
    }
    
    // Draw bg square with border.
    float inflate = 1;
    CGRect rect1 = CGRectMake(inflate, inflate, rect.size.width - 2 * inflate, rect.size.height - 2 * inflate);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [_color setStroke];
    [_color setFill];
    CGContextFillRect(context, rect1);
}

// ---------------------------------------------------------------------------------------------------------
#pragma mark - UTILS
// ---------------------------------------------------------------------------------------------------------

- (void)fitButton {
    if(_button) {
        _button.frame = self.contentView.frame;
    }
}

@end
















