//
//  AESequencer.m
//  TheAcceptableSequencer
//
//  Created by Alejandro Santander on 8/1/15.
//  Copyright (c) 2015 Palebluedot. All rights reserved.
//

#import "AESequencerChannel.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation AESequencerChannel {
    AEAudioController *_audioController;
    MusicPlayer _player;
    MusicSequence _sequence;
    BOOL _isPlaying;
}

// ---------------------------------------------------------------------------------------------------------
#pragma mark - INIT
// ---------------------------------------------------------------------------------------------------------

- (instancetype)initWithAudioController:(AEAudioController*)audioController {
    
    _audioController = audioController;
    
    // Defaults.
    _isPlaying = NO;
    
    // Init as an AUSampler audio unit channel.
    AudioComponentDescription component = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple, kAudioUnitType_MusicDevice, kAudioUnitSubType_Sampler);
    NSError *error = NULL;
    self = [super initWithComponentDescription:component audioController:audioController error:&error];
    if(error) NSLog(@"  AUSampler creation error: %@", error);
    else NSLog(@"  AUSampler started ok.");
    
    // Create a MusicPlayer to control playback.
    NewMusicPlayer(&_player);
    
    return self;
}

// ---------------------------------------------------------------------------------------------------------
#pragma mark - LOAD MIDI FILES
// ---------------------------------------------------------------------------------------------------------

- (void)loadMidiFile:(NSURL*)fileURL {
    
    // Load and parse the midi data.
    MusicSequence sequence;
    NewMusicSequence(&sequence);
    MusicSequenceFileLoad(sequence, (__bridge CFURLRef)fileURL, 0, 0);
    [self loadSequence:sequence];
}

- (void)loadSequence:(MusicSequence)sequence {
    
    _sequence = sequence;
    
    // Tell the sequence that it will be played by the sampler.
    CheckError(MusicSequenceSetAUGraph(_sequence, _audioController.audioGraph), "Error connecting sampler.");
    
    // Load the sequence on the player.
    MusicPlayerSetSequence(_player, _sequence);
    MusicPlayerPreroll(_player);
    [self toggleLooping:YES onSequence:sequence];
}

// ---------------------------------------------------------------------------------------------------------
#pragma mark - LOAD PRESETS
// ---------------------------------------------------------------------------------------------------------

//- (void)loadPreset:(NSURL*)fileURL {
//    
//    // Read preset.
//    const NSDataReadingOptions DataReadingOptions = 0;
//    NSError * outError = nil;
//    NSData * data = [NSData dataWithContentsOfURL:fileURL
//                                          options:DataReadingOptions
//                                            error:&outError];
//    
//    // Convert the data object into a property list
//    CFPropertyListRef presetPropertyList = 0;
//    CFPropertyListFormat dataFormat = 0;
//    CFErrorRef errorRef = 0;
//    presetPropertyList = CFPropertyListCreateWithData (kCFAllocatorDefault,
//                                                       (__bridge CFDataRef)(data),
//                                                       kCFPropertyListImmutable,
//                                                       &dataFormat,
//                                                       &errorRef);
//    const bool status = nil != data;
//    if(!status) {
//        // oops - an error was encountered getting the data see `outError`
//        NSLog(@"Error: %@", outError);
//        return;
//    }
//    
//    // Load preset.
//    CheckError( AudioUnitSetProperty(self.audioUnit,
//                                     kAudioUnitProperty_ClassInfo,
//                                     kAudioUnitScope_Global,
//                                     0,
//                                     &presetPropertyList,
//                                     sizeof(CFPropertyListRef)), "Error loading aupreset." );
//}

- (void)loadPreset:(NSURL*)fileURL {
    
    // Prepare preset object.
    AUSamplerInstrumentData auPreset = {0};
    auPreset.fileURL = (__bridge CFURLRef)fileURL;
    auPreset.instrumentType = kInstrumentType_AUPreset;
    
    // Load preset.
    CheckError(AudioUnitSetProperty(self.audioUnit,
                                    kAUSamplerProperty_LoadInstrument,
                                    kAudioUnitScope_Global,
                                    0,
                                    &auPreset,
                                    sizeof(auPreset)), "Error setting preset.");
}

// ---------------------------------------------------------------------------------------------------------
#pragma mark - PLAYBACK
// ---------------------------------------------------------------------------------------------------------

- (void)play {
    if(_isPlaying) return;
    CheckError(MusicPlayerStart(_player), "Error starting music player.");
    _isPlaying = YES;
}

- (void)stop {
    if(!_isPlaying) return;
    MusicPlayerStop(_player);
    _isPlaying = NO;
}

// ---------------------------------------------------------------------------------------------------------
#pragma mark - UTILS
// ---------------------------------------------------------------------------------------------------------

- (void)toggleLooping:(BOOL)loop onSequence:(MusicSequence)sequence {
    
    // Get number of tracks.
    UInt32 numberOfTracks;
    MusicSequenceGetTrackCount(sequence, &numberOfTracks);
    
    // Sweep tracks.
    MusicTrack track;
    MusicTimeStamp trackLength = 0;
    UInt32 trackLenLength_size = sizeof(trackLength);
    for(UInt32 i = 0; i < numberOfTracks; i++) {
        
        // Get track.
        MusicSequenceGetIndTrack(sequence, i, &track);
        
        // Get track info.
        MusicTrackGetProperty(track, kSequenceTrackProperty_TrackLength, &trackLength, &trackLenLength_size);
        
        // Set new loop info.
        MusicTrackLoopInfo loopInfo = { trackLength, 0 }; // loopDuration:MusicTimeStamp, numberOfLoops:SInt32
        MusicTrackSetProperty(track, kSequenceTrackProperty_LoopInfo, &loopInfo, sizeof(loopInfo));
    }
}

static void CheckError(OSStatus error, const char *operation) {
    if (error == noErr) return;
    
    char errorString[20];
    // see if it appears to be a 4-char-code
    *(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error);
    if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4])) {
        errorString[0] = errorString[5] = '\'';
        errorString[6] = '\0';
    } else
        // no, format it as an integer
        sprintf(errorString, "%d", (int)error);
    
    fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
    
    exit(1);
}

@end
























