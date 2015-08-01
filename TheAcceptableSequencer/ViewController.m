//
//  ViewController.m
//  TheAcceptableSequencer
//
//  Created by Alejandro Santander on 8/1/15.
//  Copyright (c) 2015 Palebluedot. All rights reserved.
//

#import "ViewController.h"
#import "AEAudioController.h"
#import "AESequencer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init audio engine.
    AEAudioController *audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription]];
    NSError *error = nil;
    [audioController start:&error];
    if(error) NSLog(@"-> AEAudioController start error: %@", error.localizedDescription);
    else NSLog(@"-> AEAudioController started ok.");
    
    // Init sequencer.
    AESequencer *sequencer = [[AESequencer alloc] initWithAudioController:audioController];
}

@end
