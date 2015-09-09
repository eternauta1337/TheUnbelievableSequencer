//
//  AESequencer.h
//  TheAcceptableSequencer
//
//  Created by Alejandro Santander on 8/1/15.
//  Copyright (c) 2015 Palebluedot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TheAmazingAudioEngine.h"

@interface AESequencerChannel : AEAudioUnitChannel

- (instancetype)initWithPatternResolution:(float)resolution withNumTracks:(int)numTracks;

// Load sequences.
- (void)loadSequence:(MusicSequence)sequence;
- (void)loadMidiFile:(NSURL*)fileURL;

// Load sounds.
- (void)loadPreset:(NSURL*)fileURL;
- (void)setVolume:(float)volume onTrack:(int)trackIndex;

// Playback.
- (void)play;
- (void)stop;
@property (nonatomic) float bpm;
@property (nonatomic) float playrate;
@property (readonly) float playbackPosition;
@property (readonly) BOOL isPlaying;

// Pattern.
@property NSMutableDictionary *pattern;
@property (readonly) int patternLengthInBeats;
@property (readonly) float resolution;
@property (readonly) int numTracks;
@property (readonly) int numPulses;
- (BOOL)isNoteOnAtIndexPath:(NSIndexPath*)indexPath;
- (void)toggleNoteOnAtIndexPath:(NSIndexPath*)indexPath on:(BOOL)on;

@end
