//
//  RobotViewController.m
//  Spy Robot
//
//  Created by Ari Fiorino on 3/27/15.
//  Copyright (c) 2015 Azul Engineering. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

#import "RobotViewController.h"
//#import "ChattyAppDelegate.h"
#import "UITextView+Utils.h"
#import "AppConfig.h"


OSStatus RenderTone(
                    void *inRefCon,
                    AudioUnitRenderActionFlags 	*ioActionFlags,
                    const AudioTimeStamp 		*inTimeStamp,
                    UInt32 						inBusNumber,
                    UInt32 						inNumberFrames,
                    AudioBufferList 			*ioData)

{
    // Fixed amplitude is good enough for our purposes
    

    
    // Get the tone parameters out of the view controller
    
    RobotViewController *viewController =
    (__bridge RobotViewController *)inRefCon;
    double theta = viewController->theta;
    double theta_increment = 2.0 * M_PI * viewController->frequency / viewController->sampleRate;
    double amplitude = viewController->amplitude;
    
    
    // This is a mono tone generator so we only need the first buffer
    const int channel = 0;
    Float32 *buffer = (Float32 *)ioData->mBuffers[channel].mData;
    
    // Generate the samples
    for (UInt32 frame = 0; frame < inNumberFrames; frame++)
    {
        buffer[frame] = sin(theta) * amplitude;
        
        theta += theta_increment;
        if (theta > 2.0 * M_PI)
        {
            theta -= 2.0 * M_PI;
        }
    }
    
    // Store the theta back in the view controller
    viewController->theta = theta;
    
    return noErr;
}

void ToneInterruptionListener(void *inClientData, UInt32 inInterruptionState)
{
    RobotViewController *viewController =
    (__bridge RobotViewController *)inClientData;
    
    [viewController stop];
}


@implementation RobotViewController
@synthesize chatRoom;

- (void) viewDidAppear:(BOOL)animated {
    playingToSpeakers=false;
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    _synthesizer = [[AVSpeechSynthesizer alloc] init];
    sampleRate = 44100;
    frequency=0;
    amplitude=1;
    
    OSStatus result = AudioSessionInitialize(NULL, NULL, ToneInterruptionListener, (__bridge void *)(self));
    if (result == kAudioSessionNoError)
    {
        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
    }
    AudioSessionSetActive(true);
    
    [self activate];
    [self play];
}

-(void)activate{
    if ( chatRoom != nil ) {
        chatRoom.delegate = self;
        [chatRoom start];
    }
}
-(void)playToSpeakers{
    playingToSpeakers=true;
    AVAudioSession* session = [AVAudioSession sharedInstance];
    NSError* error;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord
                   error:&error];
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
                               error:&error];
    [session setActive:YES error:&error];
}
-(void)playToHeadphones{
    playingToSpeakers=false;
    AVAudioSession* session = [AVAudioSession sharedInstance];
    NSError* error;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord
                   error:&error];
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone
                               error:&error];
    [session setActive:YES error:&error];
}
-(void)displayChatMessage:(NSString *)message fromUser:(NSString *)userName{
    if([message isEqual:@"u"]){
        frequency=1000;
        if(playingToSpeakers){
            [self playToHeadphones];
        }
    }else if([message isEqual:@"d"]){
        frequency=2000;
        if(playingToSpeakers){
            [self playToHeadphones];
        }
    }else if([message isEqual:@"r"]){
        frequency=3000;
        if(playingToSpeakers){
            [self playToHeadphones];
        }
    }else if([message isEqual:@"l"]){
        frequency=4000;
        if(playingToSpeakers){
            [self playToHeadphones];
        }
    }else if([message isEqual:@""]){
        frequency=0;
        if(playingToSpeakers){
            [self playToHeadphones];
        }
    }else{
        [self playToSpeakers];
        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:message];
        utterance.rate=.1;
        utterance.voice=[AVSpeechSynthesisVoice voiceWithLanguage:@"en-gb"];
        [_synthesizer speakUtterance:utterance];
        [self log:message];
    }
}
// Room closed from outside
- (void)roomTerminated:(id)room reason:(NSString*)reason {
    [self log:@"Room Terminated."];
    [self exit:nil];
}
-(void)log:(NSString *)text{
    outputTextView.text=text;
    //[outputTextView scrollToBottom];
    NSLog(@"%@",text);
}
- (IBAction)exit:(id)sender{
    [chatRoom stop];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createToneUnit{
    // Configure the search parameters to find the default playback output unit
    // (called the kAudioUnitSubType_RemoteIO on iOS but
    // kAudioUnitSubType_DefaultOutput on Mac OS X)
    AudioComponentDescription defaultOutputDescription;
    defaultOutputDescription.componentType = kAudioUnitType_Output;
    defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    defaultOutputDescription.componentFlags = 0;
    defaultOutputDescription.componentFlagsMask = 0;
    
    // Get the default playback output unit
    AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
    NSLog(@"%d", defaultOutput==nil);
    
    // Create a new unit based on this that we'll use for output
    OSErr err = AudioComponentInstanceNew(defaultOutput, &toneUnit);
    NSLog(@"%hd", err);
    
    // Set our tone rendering function on the unit
    AURenderCallbackStruct input;
    input.inputProc = RenderTone;
    input.inputProcRefCon = (__bridge void *)(self);
    err = AudioUnitSetProperty(toneUnit,
                               kAudioUnitProperty_SetRenderCallback,
                               kAudioUnitScope_Input,
                               0,
                               &input,
                               sizeof(input));
    
    // Set the format to 32 bit, single channel, floating point, linear PCM
    const int four_bytes_per_float = 4;
    const int eight_bits_per_byte = 8;
    AudioStreamBasicDescription streamFormat;
    streamFormat.mSampleRate = sampleRate;
    streamFormat.mFormatID = kAudioFormatLinearPCM;
    streamFormat.mFormatFlags =
    kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    streamFormat.mBytesPerPacket = four_bytes_per_float;
    streamFormat.mFramesPerPacket = 1;
    streamFormat.mBytesPerFrame = four_bytes_per_float;
    streamFormat.mChannelsPerFrame = 1;
    streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
    err = AudioUnitSetProperty (toneUnit,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Input,
                                0,
                                &streamFormat,
                                sizeof(AudioStreamBasicDescription));
    NSLog(@"%hd", err);
}

- (void)play{
        [self createToneUnit];
        
        // Stop changing parameters on the unit
        OSErr err = AudioUnitInitialize(toneUnit);
        NSLog(@"Error initializing unit: %hd", err);
        
        // Start playback
        err = AudioOutputUnitStart(toneUnit);
        NSLog(@"Error starting unit: %hd", err);
    
}

- (void)stop{
    AudioOutputUnitStop(toneUnit);
    AudioUnitUninitialize(toneUnit);
    AudioComponentInstanceDispose(toneUnit);
    toneUnit = nil;
}


@end