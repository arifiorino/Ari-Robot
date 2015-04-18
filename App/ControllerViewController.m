//
//  ControllerViewController.m
//  Spy Robot
//
//  Created by Ari Fiorino on 3/27/15.
//  Copyright (c) 2015 Azul Engineering. All rights reserved.
//

#import "ControllerViewController.h"
//#import "ChattyAppDelegate.h"
#import "UITextView+Utils.h"
#import "AppConfig.h"

@implementation ControllerViewController
@synthesize chatRoom;

- (void) viewDidAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [super viewDidAppear:animated];
    
    [self activate];
}

-(void)activate{
    if ( chatRoom != nil ) {
        chatRoom.delegate = self;
        [chatRoom start];
    }
}
-(void)displayChatMessage:(NSString *)message fromUser:(NSString *)userName{
    if(![userName isEqualToString:@"Controller"]){
        [self log:[NSString stringWithFormat:@"Recieved: %@", message]];
    }
}
// Room closed from outside
- (void)roomTerminated:(id)room reason:(NSString*)reason {
    [self log:@"Room Terminated."];
    [self exit:nil];
}
-(void)log:(NSString *)text{
    [logTextView appendTextAfterLinebreak:text];
    [logTextView scrollToBottom];
    NSLog(@"%@",text);
}
- (IBAction)exit:(id)sender{
    [chatRoom stop];
    [messageTextField resignFirstResponder];
    messageTextField.text = @"";
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)upButton:(id)sender{
    [chatRoom broadcastChatMessage:@"u" fromUser:[AppConfig getInstance].name];
}
-(IBAction)leftButton:(id)sender{
    [chatRoom broadcastChatMessage:@"l" fromUser:[AppConfig getInstance].name];
}
-(IBAction)rightButton:(id)sender{
    [chatRoom broadcastChatMessage:@"r" fromUser:[AppConfig getInstance].name];
}
-(IBAction)downButton:(id)sender{
    [chatRoom broadcastChatMessage:@"d" fromUser:[AppConfig getInstance].name];
}
-(IBAction)noButton:(id)sender{
    [chatRoom broadcastChatMessage:@"" fromUser:[AppConfig getInstance].name];
}
#pragma mark -
#pragma mark UITextFieldDelegate Method Implementations

// This is called whenever "Return" is touched on iPhone's keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == messageTextField) {
        [chatRoom broadcastChatMessage:messageTextField.text fromUser:[AppConfig getInstance].name];
        [messageTextField resignFirstResponder];
    }
    return YES;
}

@end