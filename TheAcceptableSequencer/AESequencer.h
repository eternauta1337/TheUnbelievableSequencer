//
//  AESequencer.h
//  TheAcceptableSequencer
//
//  Created by Alejandro Santander on 8/1/15.
//  Copyright (c) 2015 Palebluedot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AEAudioUnitChannel.h"
#import "AEAudioController.h"

@interface AESequencer : AEAudioUnitChannel

- (instancetype)initWithAudioController:(AEAudioController*)audioController;

@end
