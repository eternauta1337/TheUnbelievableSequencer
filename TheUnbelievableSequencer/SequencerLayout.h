//
//  SequencerLayout.h
//  TheUnbelievableSequencer
//
//  Created by Alejandro Santander on 7/21/15.
//  Copyright (c) 2015 Humane Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SequencerLayout : UICollectionViewLayout

- (instancetype)initWithNumberOfKeys:(int)keys numberOfPulses:(int)pulses collectionViewSize:(CGSize)size;

@end
