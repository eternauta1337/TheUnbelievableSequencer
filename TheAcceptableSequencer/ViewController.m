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
@property (strong, nonatomic) IBOutlet UIView *playheadView;
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
    [self initPlayhead];
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
    _sequencer = [[AESequencerChannel alloc] initWithAudioController:_audioController withPatternResolution:0.25 withNumTracks:5];
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

- (void)initCollectionView {
 
    // Hook up.
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    // Custom layout.
    SequencerLayout *layout = [[SequencerLayout alloc] initWithNumberOfKeys:_sequencer.numTracks numberOfPulses:_sequencer.numPulses collectionViewSize:_collectionView.frame.size];
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
    return _sequencer.numTracks;
}

// # ITEMS PER SECTION
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _sequencer.numPulses;
}

// ---------------------------------------------------------------------------------------------------------
#pragma mark - PLAYHEAD
// ---------------------------------------------------------------------------------------------------------

- (void)initPlayhead {
    
    // Query the sequencer position at a fixed time interval.
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.05
                                             target:self
                                           selector:@selector(onTimerTick:)
                                           userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)onTimerTick:(NSTimer*)timer {
    [self updatePlayheadPosition];
}

- (void)updatePlayheadPosition {
    
    // Position playhead view.
    float x = _sequencer.playbackPosition * _collectionView.contentSize.width - _collectionView.contentOffset.x;
    _playheadView.frame = CGRectMake(x, 0, _playheadView.frame.size.width, _playheadView.frame.size.height);
}

@end

















