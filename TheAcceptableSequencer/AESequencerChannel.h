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

- (instancetype)initWithAudioController:(AEAudioController*)audioController andPatternResolution:(float)resolution;

// Load sequences.
- (void)loadSequence:(MusicSequence)sequence;
- (void)loadMidiFile:(NSURL*)fileURL;

// Load sounds.
- (void)loadPreset:(NSURL*)fileURL;
- (void)loadBank:(NSURL*)bankURL withPatch:(int)presetNumber;

// Playback.
- (void)play;
- (void)stop;

// Pattern.
@property NSMutableDictionary *pattern;
@property int patternLengthInBeats;
- (BOOL)isNoteOnAtIndexPath:(NSIndexPath*)indexPath;
- (void)toggleNoteOnAtIndexPath:(NSIndexPath*)indexPath on:(BOOL)on;

@end
