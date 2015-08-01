//
//  AESequencer.m
//  TheAcceptableSequencer
//
//  Created by Alejandro Santander on 8/1/15.
//  Copyright (c) 2015 Palebluedot. All rights reserved.
//

#import "AESequencer.h"

@implementation AESequencer

// ---------------------------------------------------------------------------------------------------------
#pragma mark - INIT
// ---------------------------------------------------------------------------------------------------------

- (instancetype)initWithAudioController:(AEAudioController*)audioController {
    
    // Init AUSampler audio unit.
    AudioComponentDescription component = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple, kAudioUnitType_MusicDevice, kAudioUnitSubType_Sampler);
    NSError *error = NULL;
    self = [super initWithComponentDescription:component audioController:audioController error:&error];
    if(error) NSLog(@"-> AUSampler creation error: %@", error);
    else NSLog(@"-> AUSampler started ok.");
    
    return self;
}

@end
