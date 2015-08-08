//
//  SequencerCell.h
//  SequencerExperiment
//
//  Created by Alejandro Santander on 7/20/15.
//  Copyright (c) 2015 Humane Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const SEQUENCER_CELL_NOTIFICATION_TOUCH_DOWN;
extern NSString *const SEQUENCER_CELL_NOTIFICATION_TOUCH_UP;

@interface SequencerCell : UICollectionViewCell

@property (nonatomic) BOOL enabled;
@property NSIndexPath *indexPath;

@end
