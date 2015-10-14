//
//  ViewController.m
//  TheUnbelievableSequencer
//
//  Created by Alejandro Santander on 8/1/15.
//  Copyright (c) 2015 Palebluedot. All rights reserved.
//

#import "ViewController.h"
#import "AEAudioController.h"
#import "AESequencerChannel.h"
#import "AEMusicSequence.h"
#import "SequencerLayout.h"
#import "SequencerCell.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIButton *playbackBtn;
@property (strong, nonatomic) IBOutlet UILabel *tempoLabel;
@property (strong, nonatomic) IBOutlet UISlider *tempoSlider;
@end

@implementation ViewController {
    AEAudioController *_audioController;
    AESequencerChannel *_sequencer;
    NSTimer *_timer;
    UIView *_playheadView;
}

// ---------------------------------------------------------------------------------------------------------
#pragma mark - INIT
// ---------------------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTheAmazingAudioEngine];
    [self initTheUnbelievableSequencer];
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

- (void)initTheUnbelievableSequencer {
    
    // Load a sequence.
    NSURL *midiURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Midis/pattern1" ofType:@"mid"]];
    AEMusicSequence *sequence = [[AEMusicSequence alloc] initWithMidiFile:midiURL resolution:0.25 numTracks:5];
    
    // Load a sound bank.
    NSURL *preset = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Presets/SimpleDrums" ofType:@"aupreset"]];

    // The sequencer is just like any other TAAE channel.
    _sequencer = [[AESequencerChannel alloc] initWithSequence:sequence preset:preset];
    [_audioController addChannels:@[_sequencer]];
}

- (void)initCollectionView {
    
    // Hook up.
    _collectionView.dataSource = self;
    
    // Custom layout.
    SequencerLayout *layout = [[SequencerLayout alloc] initWithNumberOfKeys:_sequencer.sequence.numTracks
                                                             numberOfPulses:_sequencer.sequence.numPulses
                                                         collectionViewSize:_collectionView.frame.size];
    [_collectionView setCollectionViewLayout:layout];
    
    // Listen to notifications from cells.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCellTouchDown:)
                                                 name:SEQUENCER_CELL_NOTIFICATION_TOUCH_DOWN object:nil];
}

- (void)initPlayhead {
    
    // Playhead is a simple view inside the collection.
    _playheadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, _collectionView.frame.size.height)];
    _playheadView.backgroundColor = [UIColor cyanColor];
    [_collectionView addSubview:_playheadView];
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
    [_sequencer.sequence toggleNoteOnAtIndexPath:indexPath on:cell.enabled];
}

// ---------------------------------------------------------------------------------------------------------
#pragma mark - ACTIONS
// ---------------------------------------------------------------------------------------------------------

- (IBAction)onPlaybackBtnTapped:(id)sender {
    if(_sequencer.isPlaying) {
        [_sequencer stop];
        [self stopTimer];
        [_playbackBtn setTitle:@"Play" forState:UIControlStateNormal];
    }
    else {
        [_sequencer play];
        [self startTimer];
        [_playbackBtn setTitle:@"Stop" forState:UIControlStateNormal];
    }
}

- (IBAction)onTempoSldrChanged:(id)sender {
    _sequencer.playrate = _tempoSlider.value;
    _tempoLabel.text = [NSString stringWithFormat:@"%dbpm", (int)roundf(_sequencer.bpm)];
}

// -------------------------------------------------------------------------------------------
#pragma mark - COLLECTION VIEW DATA SOURCE
// -------------------------------------------------------------------------------------------

// CELLS
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get cell.
    SequencerCell *cell = (SequencerCell*)[_collectionView dequeueReusableCellWithReuseIdentifier:@"SequencerCell" forIndexPath:indexPath];
    
    // Configure cell.
    cell.enabled = [_sequencer.sequence isNoteOnAtIndexPath:indexPath];
    cell.indexPath = indexPath;
    
    return cell;
}

// # SECTIONS
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _sequencer.sequence.numTracks;
}

// # ITEMS PER SECTION
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _sequencer.sequence.numPulses;
}

// ---------------------------------------------------------------------------------------------------------
#pragma mark - PLAYHEAD
// ---------------------------------------------------------------------------------------------------------

- (void)startTimer {
    
    // Query the sequencer position at a fixed time interval.
    _timer = [NSTimer timerWithTimeInterval:0.01
                                     target:self
                                   selector:@selector(onTimerTick:)
                                   userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    if(_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)onTimerTick:(NSTimer*)timer {
    [self updatePlayheadPosition];
    [self compensateMusicPlayeriOS9LoopBug];
}

- (void)updatePlayheadPosition {
    
    // Position playhead view.
    float inLoop = _sequencer.playbackPosition - floorf(_sequencer.playbackPosition);
    float x = inLoop * _collectionView.contentSize.width;
    _playheadView.frame = CGRectMake(x, 0, _playheadView.frame.size.width, _playheadView.frame.size.height);
}

- (void)compensateMusicPlayeriOS9LoopBug {
//    NSLog(@"compensateMusicPlayeriOS9LoopBug() - pos: %f", _sequencer.playbackPosition);
    if(_sequencer.playbackPosition >= 1.0) {
        _sequencer.playbackPosition = 0;
    }
}

@end

















