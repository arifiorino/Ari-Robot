//
//  RobotViewController.h
//  Spy Robot
//
//  Created by Ari Fiorino on 3/27/15.
//  Copyright (c) 2015 Azul Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>
#import "Room.h"
#import "RoomDelegate.h"


@interface RobotViewController : UIViewController <RoomDelegate>{
    AudioComponentInstance toneUnit;
    Room* chatRoom;
    IBOutlet UITextView *outputTextView;
@public
    double amplitude;
    double frequency;
    double sampleRate;
    double theta;
    bool playingToSpeakers;
}
@property(nonatomic,strong) Room* chatRoom;
@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;
-(void)activate;
-(IBAction)exit:(id)sender;
-(void)playToSpeakers;
-(void)playToHeadphones;
- (void)play;
- (void)stop;
@end
