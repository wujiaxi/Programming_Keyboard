//
//  KeyboardCatagory.h
//  Programming_Keyboard
//
//  Created by Junlong Gao on 11/1/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Container.h"

@interface Container (KeyboardCatagory)

-(void) SetupKeyboard;
-(void) SetSecondKeys;

-(void) BackSpaceButton:(NSTimer*)timer;
-(IBAction) CompletionLongPressed:(UILongPressGestureRecognizer *) sender;

-(IBAction)keyboardButton:(UILongPressGestureRecognizer *) trigger;
-(IBAction)keyboardButtonTouched:(UIButton *)sender;

-(IBAction)CompletionLanguageSelected:(UIButton *)sender;
-(void) selectedCompletion:(NSString *)entry;

- (void) RegisterButton:(UIButton*) button
        toSelectorBegin:(NSString* ) selectorBeginName
          toSelectorEnd:(NSString* ) selectorEndName;

- (void) TouchBegin:(UIButton*)sender;
- (void) TouchEnd:(UIButton*)sender;



@end
