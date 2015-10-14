//
//  AESequencer.h
//  TheUnbelievableSequencer
//
//  Created by Alejandro Santander on 8/1/15.
//  Copyright (c) 2015 Palebluedot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TheAmazingAudioEngine.h"
#import "AEMusicSequence.h"

@interface AESequencerChannel : AEAudioUnitChannel

- (instancetype)initWithSequence:(AEMusicSequence*)sequence preset:(NSURL*)preset;

@property (nonatomic) float bpm;
@property (nonatomic) float playrate;
@property float playbackPosition;
@property (readonly) BOOL isPlaying;

@property (nonatomic) AEMusicSequence *sequence;
@property (nonatomic) NSURL *preset;

- (void)setVolume:(float)volume onTrack:(int)trackIndex;
- (void)play;
- (void)stop;

@end
