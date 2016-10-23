//
//  ViewController.h
//  Programming_Keyboard
//
//  Created by Junlong Gao on 10/14/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import <UIKit/UIKit.h>
// pop up view
#import "AutoCompletionPanelController.h"

// data helpers
#import "CompletionEngine.h"
@interface Container : UIViewController
@property (nonatomic, weak) AutoCompletionPanelController *completionPanel;

@property (nonatomic) CompletionEngine *completionEngine;

//current key
@property (nonatomic, weak) IBOutlet UIButton *currentKey;
// text display:
@property (nonatomic, weak) IBOutlet UITextView *codes;
// keyboard view:
@property (nonatomic, weak) IBOutlet UIView *keyboard;

-(void)moveCursorByOffset:(NSInteger)offset;

// button touch down
-(IBAction)keyboardButtonTouched:(UIButton *)sender;

-(IBAction)MoveCursorLeft:(UIButton *)sender;

-(IBAction)MoveCursorRight:(UIButton *)sender;

//keyboard helpers
-(IBAction)keyboardButton:(UIButton *)sender;
-(void) BackSpaceButton:(NSTimer*)timer;

//pop up gesture
-(IBAction) CompletionLongPressed:(UILongPressGestureRecognizer *) sender;

@end

