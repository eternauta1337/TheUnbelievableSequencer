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
#import "SequencerLayout.h"
#import "SequencerCell.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@end

@implementation ViewController {
    AEAudioController *_audioController;
    AESequencerChannel *_sequencer;
}

// ---------------------------------------------------------------------------------------------------------
#pragma mark - INIT
// ---------------------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init.
    [self initTheAmazingAudioEngine];
    [self initTheAcceptableSequencer];
    [self initCollectionView];
}

- (void)initTheAmazingAudioEngine {
    
    // Init TAAE normally.
    _audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription]];
    NSError *error = nil;
    [_audioController start:&error];
    if(error) NSLog(@"  AEAudioController start error: %@", error.localizedDescription);
    else NSLog(@"  AEAudioController started ok.");
}

- (void)initTheAcceptableSequencer {
    
    // The sequencer is just like any other TAAE channel.
    _sequencer = [[AESequencerChannel alloc] initWithAudioController:_audioController andPatternResolution:0.5];
    [_audioController addChannels:@[_sequencer]];
    
    // Load a sequence.
    NSURL *midiURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Midis/pattern1" ofType:@"mid"]];
    [_sequencer loadMidiFile:midiURL];
    
    // Load a sound bank.
    NSURL *presetURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Presets/SimpleDrums" ofType:@"aupreset"]];
    [_sequencer loadPreset:presetURL];
    
    // Start the sequencer.
    [_sequencer play];
}

#define NUM_KEYS 10
#define NUM_PULSES 32

- (void)initCollectionView {
 
    // Hook up.
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    // Custom layout.
    SequencerLayout *layout = [[SequencerLayout alloc] initWithNumberOfKeys:NUM_KEYS numberOfPulses:NUM_PULSES collectionViewSize:_collectionView.frame.size];
    [_collectionView setCollectionViewLayout:layout];
    
    // Listen to notifications from cells.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCellTouchDown:)
                                                 name:SEQUENCER_CELL_NOTIFICATION_TOUCH_DOWN object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(onCellTouchUp:)
//                                                 name:SEQUENCER_CELL_NOTIFICATION_TOUCH_UP object:nil];
}

// -------------------------------------------------------------------------------------------
#pragma mark - NOTIFICATIONS
// -------------------------------------------------------------------------------------------

- (void)onCellTouchDown:(NSNotification*)notification {
    
    // Get cell.
    SequencerCell *cell = (SequencerCell*)notification.object;
    
    // Toggle cell.
    cell.enabled = !cell.enabled;
    
    // Get index path.
    NSIndexPath *indexPath = notification.userInfo[@"indexPath"];
    
    // Affect pattern.
    [_sequencer toggleNoteOnAtIndexPath:indexPath on:cell.enabled];
}

// -------------------------------------------------------------------------------------------
#pragma mark - COLLECTION VIEW DATA SOURCE
// -------------------------------------------------------------------------------------------

// CELLS
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get cell.
    SequencerCell *cell = (SequencerCell*)[_collectionView dequeueReusableCellWithReuseIdentifier:@"SequencerCell" forIndexPath:indexPath];
    
    // Configure cell.
    cell.enabled = [_sequencer isNoteOnAtIndexPath:indexPath];
    cell.indexPath = indexPath;
    
    return cell;
}

// # SECTIONS
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return NUM_KEYS;
}

// # ITEMS PER SECTION
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return NUM_PULSES;
}

@end

















