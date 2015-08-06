//
//  ViewController.m
//  TheAcceptableSequencer
//
//  Created by Alejandro Santander on 8/1/15.
//  Copyright (c) 2015 Palebluedot. All rights reserved.
//

#import "ViewController.h"
#import "AEAudioController.h"
#import "AESequencerChannel.h"

@interface ViewController ()

@end

@implementation ViewController {
    AEAudioController *_audioController;
    AESequencerChannel *_sequencer;
}

// ---------------------------------------------------------------------------------------------------------
#pragma mark - LIFE CYCLE
// ---------------------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init audio engine.
    _audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription]];
    NSError *error = nil;
    [_audioController start:&error];
    if(error) NSLog(@"  AEAudioController start error: %@", error.localizedDescription);
    else NSLog(@"  AEAudioController started ok.");
    
    // Init the sequencer.
    _sequencer = [[AESequencerChannel alloc] initWithAudioController:_audioController];
    [_audioController addChannels:@[_sequencer]];
    
    // Load a sequence.
    NSURL *midiURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Midis/pattern1" ofType:@"mid"]];
    [_sequencer loadMidiFile:midiURL];
    
    // Load sounds.
    NSURL *presetURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Presets/SimpleDrums" ofType:@"aupreset"]];
    [_sequencer loadPreset:presetURL];
    
    // Start the sequencer.
    [_sequencer play];
}

@end

















