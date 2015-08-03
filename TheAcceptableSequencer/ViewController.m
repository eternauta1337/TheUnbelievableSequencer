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

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init audio engine.
    AEAudioController *audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription]];
    NSError *error = nil;
    [audioController start:&error];
    if(error) NSLog(@"  AEAudioController start error: %@", error.localizedDescription);
    else NSLog(@"  AEAudioController started ok.");
    
    // Init the sequencer.
    AESequencerChannel *sequencer = [[AESequencerChannel alloc] initWithAudioController:audioController];
    [audioController addChannels:@[sequencer]];
    
    // Load a sequence.
    NSURL *midiURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Midis/underfx" ofType:@"mid"]];
    [sequencer loadMidiFile:midiURL];
    
    // Load sounds.
    NSURL *presetURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Presets/Wacko" ofType:@"aupreset"]];
    [sequencer loadPreset:presetURL];
    
    // Start the sequencer.
    [sequencer play];
}

@end

















