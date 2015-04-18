//
//  ChattyViewController.m
//  Chatty
//
//  Copyright (c) 2009 Peter Bakhyryev <peter@byteclub.com>, ByteClub LLC
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//  
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.

#import "ChattyViewController.h"
#import "ControllerViewController.h"
#import "RobotViewController.h"
#import "LocalRoom.h"
#import "RemoteRoom.h"
#import "AppConfig.h"


// Private properties
@interface ChattyViewController ()
@property(nonatomic,strong) ServerBrowser* serverBrowser;
@end


@implementation ChattyViewController

@synthesize serverBrowser;

// View loaded
- (void)viewDidLoad {
  [connectionTitle setText:[NSString stringWithFormat:@"%@ Connection", [AppConfig getInstance].name]];
    
  serverBrowser = [[ServerBrowser alloc] init];
  serverBrowser.delegate = self;
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self activate];
}
-(IBAction)Connect:(id)sender{
    if([[AppConfig getInstance].name isEqualToString:@"Robot"]){
        [self joinChatRoom];
    }else{
        [self createNewChatRoom];
    }
}

- (void)activate {
  [serverBrowser start];
}
- (void)createNewChatRoom{
  
  [self performSegueWithIdentifier:@"toController" sender:self];
}


- (void)joinChatRoom{
    if(serverBrowser.servers.count==0){
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There are no chat rooms available" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    return;
  }
  
  [self performSegueWithIdentifier:@"toRobot" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqual:@"toRobot"]){
        NSNetService* selectedServer = [serverBrowser.servers objectAtIndex:0];
        RemoteRoom* room = [[RemoteRoom alloc] initWithNetService:selectedServer];
        RobotViewController *chatRoom=segue.destinationViewController;
        chatRoom.chatRoom=room;
    }else{
        LocalRoom* room = [[LocalRoom alloc] init];
        ControllerViewController *chatRoom=segue.destinationViewController;
        chatRoom.chatRoom=room;
    }
    [serverBrowser stop];
}
#pragma mark -
#pragma mark ServerBrowserDelegate Method Implementations

- (void)updateServerList {
  //[serverList reloadData];
}


@end
