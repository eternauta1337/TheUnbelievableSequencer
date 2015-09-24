//
//  AEMusicSequence.m
//  TheUnbelievableSequencer
//
//  Created by Alejandro Santander on 9/18/15.
//  Copyright (c) 2015 Alejandro Santander. All rights reserved.
//

#import "AEMusicSequence.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation AEMusicSequence

// ---------------------------------------------------------------------------------------------------------
#pragma mark - INIT
// ---------------------------------------------------------------------------------------------------------

- (instancetype)initWithMidiFile:(NSURL*)fileURL resolution:(int)resolution numTracks:(int)numTracks {
    self = [super init];
    
    _resolution = resolution;
    _numTracks = numTracks;
    
    // Init data.
    _pattern = [NSMutableDictionary dictionary];
    
    [self loadMidiFile:fileURL];
    
    return self;
}

// ---------------------------------------------------------------------------------------------------------
#pragma mark - LOAD MIDI FILES
// ---------------------------------------------------------------------------------------------------------

- (void)loadMidiFile:(NSURL*)fileURL {
    
    // Load and parse the midi data.
    MusicSequence sequence;
    AECheckOSStatus(NewMusicSequence(&sequence), "Error creating music sequence.");
    AECheckOSStatus(MusicSequenceFileLoad(sequence, (__bridge CFURLRef)fileURL, 0, 0), "Error loading midi.");
    self.coreSequence = sequence;
}

- (void)setCoreSequence:(MusicSequence)sequence {
    
    _coreSequence = sequence;
    //    CAShow(_sequence);
    
    [self toggleLooping:YES onSequence:sequence];
    [self getSequenceInfo];
    [self musicSequenceToPattern];
}

- (void)getSequenceInfo {
    
    MusicTrack track;
    
    // Get number of tracks.
    UInt32 numberOfTracks;
    AECheckOSStatus(MusicSequenceGetTrackCount(_coreSequence, &numberOfTracks), "Error getting number of tracks.");
    //    NSLog(@"  numberOfTracks: %d", (unsigned int)numberOfTracks);
    
    // Get tempo info.
    AECheckOSStatus(MusicSequenceGetTempoTrack(_coreSequence, &track), "Error getting tempo track");
    SInt16 ppqn;
    UInt32 length; // number of events in tempo track
    AECheckOSStatus(MusicTrackGetProperty(track, kSequenceTrackProperty_TimeResolution, &ppqn, &length), "Error getting time resolution.");
    //    NSLog(@"  ppqn: %d", ppqn);
    //    NSLog(@"  length: %d", (unsigned int)length);
    
    // Sweep tempo track events.
    MusicEventIterator iterator = NULL;
    NewMusicEventIterator(track, &iterator);
    MusicTimeStamp timestamp = 0; // all extracted time values are in beats (black notes)
    MusicEventType eventType = 0;
    const void *eventData = NULL;
    UInt32 eventDataSize;
    Boolean hasNext = YES;
    int j = 0;
    while(hasNext) {
        
        //        NSLog(@"    event: %d", j);
        
        // Next iteration.
        MusicEventIteratorHasNextEvent(iterator, &hasNext);
        if(j > 1000) { hasNext = false; } // bail out
        
        // Get event info.
        MusicEventIteratorGetEventInfo(iterator, &timestamp, &eventType, &eventData, &eventDataSize);
        //        NSLog(@"    timestamp: %f (beats)", timestamp);
        //        NSLog(@"    eventType: %d", (unsigned int)eventType);
        //            NSLog(@"    eventDataSize: %d", (unsigned int)eventDataSize);
        //            NSLog(@"    eventData: %d", eventData);
        
        // TEMPO EVENT
        if(eventType == kMusicEventType_ExtendedTempo) {
            //            NSLog(@"    TempoEvent");
            
            ExtendedTempoEvent * tempoEvent = (ExtendedTempoEvent*)eventData;
            _sequenceBpm = tempoEvent->bpm;
        }
        
        // Iterate.
        MusicEventIteratorNextEvent(iterator);
        j++;
    }
    //    NSLog(@"  bpm: %f", _bpm);
}

// ---------------------------------------------------------------------------------------------------------
#pragma mark - PATTERN / MIDI SEQUENCE
// ---------------------------------------------------------------------------------------------------------

- (void)toggleNoteOnAtIndexPath:(NSIndexPath*)indexPath on:(BOOL)on {
    
    // Update pattern.
    _pattern[indexPath] = on ? @1 : @0;
    
    // Get track 1. (0 is tempo).
    int trackIndex = 1;
    MusicTrack track;
    AECheckOSStatus(MusicSequenceGetIndTrack(_coreSequence, trackIndex, &track), "Error getting track.");
    
    // Clear MusicTrack at location.
    MusicTimeStamp startTime = indexPath.row * _resolution;
    MusicTimeStamp endTime = startTime + _resolution;
    AECheckOSStatus(MusicTrackClear(track, startTime, endTime), "Error clearing music track.");
    
    // Review section.
    for(int i = 0; i < _numTracks; i++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row inSection:i];
        if(_pattern[path] && [_pattern[path] isEqualToNumber:@1]) {
            MIDINoteMessage note;
            note.note = 36 + i;
            note.channel = 1;
            note.velocity = 100.00;
            note.duration = _resolution;
            AECheckOSStatus(MusicTrackNewMIDINoteEvent(track, startTime, &note), "Error adding note.");
        }
    }
}

- (void)musicSequenceToPattern {
    
    // Get track 1. (0 is tempo).
    int trackIndex = 1;
    MusicTrack track;
    AECheckOSStatus(MusicSequenceGetIndTrack(_coreSequence, trackIndex, &track), "Error getting track.");
    
    // Get track info.
    MusicTimeStamp trackLength = 0;
    UInt32 trackLenLength_size = sizeof(trackLength);
    AECheckOSStatus(MusicTrackGetProperty(track, kSequenceTrackProperty_TrackLength, &trackLength, &trackLenLength_size), "Error getting track info");
    _sequenceLengthInBeats = trackLength;
    
    // Sweep events and convert notes to the grid.
    MusicEventIterator iterator = NULL;
    NewMusicEventIterator(track, &iterator);
    MusicTimeStamp timestamp = 0; // all extracted time values are in beats (black notes)
    MusicEventType eventType = 0;
    const void *eventData = NULL;
    UInt32 eventDataSize;
    Boolean hasNext = YES;
    int j = 0;
    while(hasNext) {
        
        // Next iteration.
        MusicEventIteratorHasNextEvent(iterator, &hasNext);
        if(j > 5000) { hasNext = false; } // bail out
        
        // Get event info.
        MusicEventIteratorGetEventInfo(iterator, &timestamp, &eventType, &eventData, &eventDataSize);
        
        // NOTE EVENT
        if(eventType == kMusicEventType_MIDINoteMessage) {
            
            // Cast message.
            MIDINoteMessage *message = (MIDINoteMessage*)eventData;
            
            // Log note.
            UInt8 note = message->note;
            int noteSection = note - 36;
            int noteRow = (int)(timestamp * (1/_resolution));
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:noteRow inSection:noteSection];
            _pattern[indexPath] = [NSNumber numberWithBool:YES];
        }
        
        // Iterate.
        MusicEventIteratorNextEvent(iterator);
        j++;
    }
}

- (BOOL)isNoteOnAtIndexPath:(NSIndexPath*)indexPath {
    BOOL isOn = NO;
    if(_pattern[indexPath] && [_pattern[indexPath] isEqualToNumber:@1]) {
        isOn = YES;
    }
    return isOn;
}

- (int)numPulses {
    return _sequenceLengthInBeats / _resolution;
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

@end





































