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

@interface AESequencerChannel : AEAudioUnitChannel

- (instancetype)initWithAudioController:(AEAudioController*)audioController;

// Load sequences.
- (void)loadSequence:(MusicSequence)sequence;
- (void)loadMidiFile:(NSURL*)fileURL;

// Load sounds.
- (void)loadPreset:(NSURL*)fileURL;

// Playback.
- (void)play;
- (void)stop;

@end
