//
//  ViewController.h
//  Programming_Keyboard
//
//  Created by Junlong Gao on 10/14/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"

// pop up view
#import "AutoCompletionPanelController.h"
#import "CompletionLanguageSelectionController.h"

// data helpers
#import "CompletionEngine.h"
#import "DriveModel.h"

@interface Container : UIViewController
@property (nonatomic, weak) AutoCompletionPanelController *completionPanel;
@property (nonatomic, weak) CompletionLanguageSelectionController *LanguageList;

@property (nonatomic) CompletionEngine *completionEngine;

//current key
@property (nonatomic, weak) IBOutlet UIButton *currentKey;
// text display:
@property (nonatomic, weak) IBOutlet UITextView *codes;
// keyboard view:
@property (nonatomic, weak) IBOutlet UIView *keyboard;

@property (nonatomic, weak) IBOutlet UIView *controls;


-(void)moveCursorByOffset:(NSInteger)offset;

// button touch down
-(IBAction)keyboardButtonTouched:(UIButton *)sender;

-(IBAction)MoveCursorLeft:(UIButton *)sender;

-(IBAction)MoveCursorRight:(UIButton *)sender;

-(IBAction)MoveCursorDown:(UIButton *)sender;

-(IBAction)MoveCursorUp:(UIButton *)sender;


//keyboard helpers
-(IBAction)keyboardButton:(UIButton *)sender;
-(void) BackSpaceButton:(NSTimer*)timer;

//pop up gesture
-(IBAction) CompletionLongPressed:(UILongPressGestureRecognizer *) sender;

@property (nonatomic, strong) GTLServiceDrive *service;
@property (nonatomic, strong) DriveModel *driveModel;

@end

