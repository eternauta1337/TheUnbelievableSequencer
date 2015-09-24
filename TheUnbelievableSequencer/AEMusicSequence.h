//
//  AEMusicSequence.h
//  TheUnbelievableSequencer
//
//  Created by Alejandro Santander on 9/18/15.
//  Copyright (c) 2015 Alejandro Santander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TheAmazingAudioEngine.h"

@interface AEMusicSequence : NSObject

- (instancetype)initWithMidiFile:(NSURL*)fileURL resolution:(int)resolution numTracks:(int)numTracks;

@property NSMutableDictionary *pattern;
@property (readonly) int sequenceLengthInBeats;
@property (readonly) float sequenceBpm;
@property (readonly) float resolution;
@property (readonly) int numTracks;
@property (readonly) int numPulses;
@property (nonatomic) MusicSequence coreSequence;

- (void)loadMidiFile:(NSURL*)fileURL;
- (BOOL)isNoteOnAtIndexPath:(NSIndexPath*)indexPath;
- (void)toggleNoteOnAtIndexPath:(NSIndexPath*)indexPath on:(BOOL)on;

@end
