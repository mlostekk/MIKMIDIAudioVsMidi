//
//  ViewController.m
//  MIKMIDITest
//
//  Created by Martin Mlostek on 20.02.17.
//  Copyright © 2017 nomad5. All rights reserved.
//

#import "ViewController.h"
#import "MIKMIDISequencer.h"
#import "MIKMIDISequence.h"
#import "MIKMIDIClock.h"
#import <AVFoundation/AVFoundation.h>

@implementation ViewController
    {
        NSTimer          *updateTimer;
        AVAudioPlayer    *audioPlayer;
        MIKMIDISequencer *midiSequencer;
    }

    /****************************************************************************************************************************
     */
    - (void)viewDidLoad
    {
        [super viewDidLoad];
        // audio
        NSURL *audioFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"REFERENCE" ofType:@"mp3"]];
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFile error:nil];
        // midi
        NSURL *midiFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"REFERENCE" ofType:@"mid"]];
        midiSequencer = [MIKMIDISequencer sequencerWithSequence:[MIKMIDISequence sequenceWithFileAtURL:midiFile error:nil]];
        midiSequencer.preRoll              = 0;
        // timer
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                               target:self
                               selector:@selector(timerUpdate)
                               userInfo:nil
                               repeats:true];
        [[NSRunLoop currentRunLoop] addTimer:updateTimer forMode:NSRunLoopCommonModes];
    }

    /****************************************************************************************************************************
     */
    - (IBAction)onPlayButtonPressed
    {
        // midi
        [midiSequencer stop];
        midiSequencer.currentTimeStamp = 0;
        [midiSequencer startPlayback];
        // audio
        [audioPlayer stop];
        audioPlayer.currentTime = 0;
        [audioPlayer play];
    }

    /****************************************************************************************************************************
     */
    - (void)timerUpdate
    {
        // audio
        NSTimeInterval msAudio = audioPlayer.currentTime * 1000;
        _audioMs.text = [NSString stringWithFormat:@"%.2f", msAudio];
        // midi
        MIKMIDIClock *clock = midiSequencer.syncedClock;
        MIDITimeStamp midiTimestamp = [clock midiTimeStampsPerMusicTimeStamp:midiSequencer.currentTimeStamp];
        NSTimeInterval msMidi = 1000.0 * MIKMIDIClockSecondsPerMIDITimeStamp() * midiTimestamp;
        _midiMs.text = [NSString stringWithFormat:@"%.2f", msMidi];
        // diff
        _diffMs.text = [NSString stringWithFormat:@"%.2f", msAudio - msMidi];
    }

@end
