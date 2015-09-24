//
//  AESequencer.m
//  TheUnbelievableSequencer
//
//  Created by Alejandro Santander on 8/1/15.
//  Copyright (c) 2015 Palebluedot. All rights reserved.
//

#import "AESequencerChannel.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation AESequencerChannel {
    AEAudioController *_audioController;
    MusicPlayer _player;
}

// ---------------------------------------------------------------------------------------------------------
#pragma mark - INIT
// ---------------------------------------------------------------------------------------------------------

- (instancetype)init {
    
    NSLog(@"AESequencerChannel - init()");
    
    _isPlaying = NO;
    _playrate = 1;
    
    // Init as an AUSampler audio unit channel.
    AudioComponentDescription componentDescription = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple, kAudioUnitType_MusicDevice, kAudioUnitSubType_Sampler);
    self = [super initWithComponentDescription:componentDescription];
    
    // Create a MusicPlayer to control playback.
    AECheckOSStatus(NewMusicPlayer(&_player), "Error creating music player.");
    
    return self;
}

- (void)setupWithAudioController:(AEAudioController *)audioController {
    [super setupWithAudioController:audioController];
    
    // Keep a reference to the audio controller.
    // (knowledge of the audio graph is needed)
    _audioController = audioController;
}

// ---------------------------------------------------------------------------------------------------------
#pragma mark - INTERFACE
// ---------------------------------------------------------------------------------------------------------

- (void)setVolume:(float)volume onTrack:(int)trackIndex {
    
}

- (void)play {
    if(_isPlaying) return;
    AECheckOSStatus(MusicPlayerStart(_player), "Error starting music player.");
    _isPlaying = YES;
}

- (void)stop {
    if(!_isPlaying) return;
    MusicPlayerStop(_player);
    _isPlaying = NO;
}

- (float)playbackPosition {
    
    // Get position.
    MusicTimeStamp time;
    AECheckOSStatus(MusicPlayerGetTime(_player, &time), "Error getting position");
    
    // Calculate position in loop.
    float loopPos = (float)time / (float)_sequence.sequenceLengthInBeats;
    loopPos = loopPos - floorf(loopPos);
    
    return loopPos;
}

- (void)setPlayrate:(float)playrate {
    if(playrate == _playrate) return;
    _playrate = playrate;
    MusicPlayerSetPlayRateScalar(_player, (Float64)_playrate);
    _bpm = _playrate * _sequence.sequenceBpm;;
}

- (void)setBpm:(float)bpm {
    float ratio = bpm / _bpm;
    [self setPlayrate:ratio];
    _bpm = bpm;
}

// ---------------------------------------------------------------------------------------------------------
#pragma mark - LOAD SEQUENCE
// ---------------------------------------------------------------------------------------------------------

- (void)setSequence:(AEMusicSequence *)sequence {
    _sequence = sequence;
    
    // Use a proxy to route notes from the player to the sampler.
    AECheckOSStatus(MusicSequenceSetAUGraph(_sequence.coreSequence, _audioController.audioGraph), "Error connecting sampler to sequence.");
    //    CAShow(_audioController.audioGraph);
    
    // Load the sequence on the player.
    AECheckOSStatus(MusicPlayerSetSequence(_player, sequence.coreSequence), "Error setting music sequence.");
    AECheckOSStatus(MusicPlayerPreroll(_player), "Error preparing the music player.");
}

// ---------------------------------------------------------------------------------------------------------
#pragma mark - LOAD SOUNDS
// ---------------------------------------------------------------------------------------------------------

- (void)setPreset:(NSURL*)fileURL {
    _preset = fileURL;
    
    // Prepare preset object.
    AUSamplerInstrumentData auPreset = {0};
    auPreset.fileURL = (__bridge CFURLRef)(fileURL);
    auPreset.instrumentType = kInstrumentType_AUPreset;
    
    // Load preset.
    AECheckOSStatus(AudioUnitSetProperty(self.audioUnit,
                                    kAUSamplerProperty_LoadInstrument,
                                    kAudioUnitScope_Global,
                                    0,
                                    &auPreset,
                                    sizeof(auPreset)), "Error loading preset.");
}

@end
























