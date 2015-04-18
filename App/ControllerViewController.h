//
//  ControllerViewController.h
//  Spy Robot
//
//  Created by Ari Fiorino on 3/27/15.
//  Copyright (c) 2015 Azul Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Room.h"
#import "RoomDelegate.h"

@interface ControllerViewController : UIViewController <RoomDelegate, UITextFieldDelegate> {
    Room* chatRoom;
    IBOutlet UITextView* logTextView;
    IBOutlet UITextField* messageTextField;
}

@property(nonatomic,strong) Room* chatRoom;
-(void)activate;
-(IBAction)exit:(id)sender;
-(IBAction)upButton:(id)sender;
-(IBAction)leftButton:(id)sender;
-(IBAction)rightButton:(id)sender;
-(IBAction)downButton:(id)sender;
-(IBAction)noButton:(id)sender;
-(void)log:(NSString*)text;
@end
