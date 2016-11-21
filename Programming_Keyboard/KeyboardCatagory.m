//
//  KeyboardCatagory.m
//  Programming_Keyboard
//
//  Created by Junlong Gao on 11/1/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import "Catagories.h"




@implementation Container (KeyboardCatagory)


-(void) SetupKeyboard{
    UITextInputAssistantItem* item = [self.codes inputAssistantItem];
    item.leadingBarButtonGroups = @[];
    item.trailingBarButtonGroups = @[];
    [self FixKeyboard];
    if(self.KeyboardReady) return;
    [self SetSecondKeys];
    self.Shift = 0;
    for(UIView * subview in self.view.subviews){
        if(subview.tag == KEYBOARD_TAG){
            for(UIButton* button in subview.subviews){
                if([button.titleLabel.text isEqualToString:BACKSPACE]){
                    [self.ButtonToSelector setObject:@"BackSpaceButton:"
                                              forKey:button.titleLabel.text];
                    
                    
                }else if (![button.titleLabel.text isEqualToString:ENTER]
                          && ![button.titleLabel.text isEqualToString:SHIFT]

                          
                          && ![button.titleLabel.text isEqualToString:SPACE]){
                        //NSLog(@"registered %@\n", button.titleLabel.text);
                    [self.KeysHasSecondFunctions addObject:button];

                    UILongPressGestureRecognizer*  rec = [[UILongPressGestureRecognizer alloc]
                                                          initWithTarget:self
                                                          action:@selector(BackSpaceLongPressed:)];
                    rec.minimumPressDuration = BACKSPACEDELAY;
                    [rec setDelegate:self];
                    [button addGestureRecognizer:rec];
                    [self.keyboardLayout setObject:rec forKey:button.titleLabel.text];
                    [self.ButtonToSelector setObject:@"BackSpaceButton:"
                                              forKey:button.titleLabel.text];
                }else{
                    if (![button.titleLabel.text isEqualToString:ENTER]
                        && ![button.titleLabel.text isEqualToString:SHIFT]
                        && ![button.titleLabel.text isEqualToString:SPACE]){
                            //NSLog(@"registered %@\n", button.titleLabel.text);
                            //normal keys
                        [self.KeysHasSecondFunctions addObject:button];
                        UILongPressGestureRecognizer*  rec = [[UILongPressGestureRecognizer alloc]
                                                              initWithTarget:self
                                                              action:@selector(CompletionLongPressed:)];
                        rec.minimumPressDuration = COMPLETIONDELAY;
                        [rec setDelegate:self];
                        [button addGestureRecognizer:rec];
                        [self.keyboardLayout setObject:rec forKey:button.titleLabel.text];
                        
                        
                    }
                    UILongPressGestureRecognizer*  DelayedAction = [[UILongPressGestureRecognizer alloc]
                                                                    initWithTarget:self
                                                                    action:@selector(keyboardButton:)];
                    DelayedAction.minimumPressDuration = STANDARDDELAY;
                    [DelayedAction setDelegate:self];
                    [button addGestureRecognizer:DelayedAction];
                    
                }
            }
            
        }
        if(subview.tag == CONTROL_TAG){
            for(UIButton* button in subview.subviews){
                if([button.titleLabel.text isEqualToString:@"Left"]||
                   [button.titleLabel.text isEqualToString:@"Right"]||
                   [button.titleLabel.text isEqualToString:@"Up"]||
                   [button.titleLabel.text isEqualToString:@"Down"]){
                    [self RegisterButton:button
                         toSelectorBegin:@"TouchBegin:"
                           toSelectorEnd:@"TouchEnd:"];
                    [self.ButtonToSelector setObject:[NSString stringWithFormat:@"MoveCursor%@:", button.titleLabel.text]
                                              forKey:button.titleLabel.text];
                    
                }
            }
        }
        
    }
    self.KeyboardReady = YES;

}


-(void) FixKeyboard{
    for(UIView * subview in self.view.subviews){
        if(subview.tag == KEYBOARD_TAG){
            for(UIButton* button in subview.subviews){
                if([button.titleLabel.text isEqualToString:BACKSPACE]){
                    [self.ButtonToSelector setObject:@"BackSpaceButton:"
                                              forKey:button.titleLabel.text];
                    break;
                }
            }
            
        }
        if(subview.tag == CONTROL_TAG){
            for(UIButton* button in subview.subviews){
                if([button.titleLabel.text isEqualToString:@"Left"]||
                   [button.titleLabel.text isEqualToString:@"Right"]||
                   [button.titleLabel.text isEqualToString:@"Up"]||
                   [button.titleLabel.text isEqualToString:@"Down"]){
                    [self.ButtonToSelector setObject:[NSString stringWithFormat:@"MoveCursor%@:", button.titleLabel.text]
                                              forKey:button.titleLabel.text];
                    
                }
            }
        }
        
    }
}


- (void) RegisterButton:(UIButton*) button
        toSelectorBegin:(NSString* ) selectorBeginName
          toSelectorEnd:(NSString* ) selectorEndName{
    
    [button addTarget:self
               action:NSSelectorFromString(selectorBeginName)
     forControlEvents: UIControlEventTouchDown];
    
    [button addTarget:self
               action:NSSelectorFromString(selectorEndName)
     forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
}


    //shift keys:
-(void) ResetLayout{
    self.Shift++;
    NSDictionary* next = self.Switcher[(self.Shift % 2)];
    for(UIButton* button in self.KeysHasSecondFunctions){
        NSString* source = [NSString stringWithString:button.titleLabel.text];
        NSString* target = [next objectForKey:source];
        [button setTitle:target forState:UIControlStateNormal];
        [button setTitle:target forState:UIControlStateSelected];
        [button setTitle:target forState:UIControlStateHighlighted];
    }
    [self.codes becomeFirstResponder];

}

//backspace helpers
-(void) BackSpaceButton:(NSTimer*)timer {
    
    NSInteger rewindOffset = [self.completionEngine inputPressed:BACKSPACE
                                                       textField:self.codes];
    [self.completionEngine printDebug];
    [self moveCursorByOffset:rewindOffset];
    [self.codes becomeFirstResponder];

}

-(IBAction) BackSpacePressed:(UIButton*) button {
    
    NSInteger rewindOffset = [self.completionEngine inputPressed:BACKSPACE
                                                       textField:self.codes];
    [self.completionEngine printDebug];
    [self moveCursorByOffset:rewindOffset];
    [self.codes becomeFirstResponder];
    
}

-(void) BackSpaceLongPressed:(UILongPressGestureRecognizer *) trigger {
    
    UIButton* sender = (UIButton*)trigger.view;
    NSString* input = sender.titleLabel.text;
    switch(trigger.state){
        case UIGestureRecognizerStateBegan:{
            if([input isEqualToString:BACKSPACE]){
                [self TouchBegin:sender];
            }
            break;
        }
        case UIGestureRecognizerStateChanged:
                //NSLog(@"State changed");
            break;
        case UIGestureRecognizerStateEnded:{
            if([input isEqualToString:BACKSPACE]){
                [self TouchEnd:sender];
                break;
            }
        }
        default:
            break;
    }
    [self.codes becomeFirstResponder];
    
}


#pragma mark - Completion Selection Panel Delegate
-(void) selectedCompletion:(NSString *)entry
{
        //NSLog(@"selected completion %@", entry);
    [self.codes insertText:[entry substringFromIndex:
                            [self.completionEngine from]]];
    [self.completionEngine rewind];
    [self.codes becomeFirstResponder];
    self.codes.inputAssistantItem.leadingBarButtonGroups = @[];

}



-(IBAction) CompletionLongPressed:(UILongPressGestureRecognizer *) sender{
    [self.codes becomeFirstResponder];

    switch(sender.state){
        case UIGestureRecognizerStateBegan:{
                //normal action:
                //[self keyboardButton:(UIButton*)sender.view];
            
            
                //init the view
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            self.completionPanel = [storyboard instantiateViewControllerWithIdentifier:@"autoCompletionPanel"];
            self.completionPanel.delegate = self;
            self.completionPanel.modalPresentationStyle = UIModalPresentationPopover;
            
                //populate the completion options
            [self.completionEngine printDebug];
            [self.completionPanel populateCompletion:[self.completionEngine dumpList]];
            
                //start the view
            UIPopoverPresentationController *popController = [self.completionPanel popoverPresentationController];
            [self presentViewController:self.completionPanel
                               animated:YES
                             completion:nil];
            popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            popController.sourceView = self.keyboard;
            popController.sourceRect = self.currentKey.frame;
            popController.delegate = self;
            break;
        }
        case UIGestureRecognizerStateChanged:
                //NSLog(@"State changed");
            break;
        case UIGestureRecognizerStateEnded:
                //NSLog(@"State End");
            break;
        default:
            break;
    }
    [self.codes becomeFirstResponder];
    
}

    // button touch down
-(IBAction)CompletionLanguageSelected:(UIButton *)sender{
        //NSLog(@"button %@ touched to update current key", sender.titleLabel.text);
        //init the view
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.LanguageList = [storyboard instantiateViewControllerWithIdentifier:@"CompletionSelection"];
    self.LanguageList.delegate = self;
    self.LanguageList.modalPresentationStyle = UIModalPresentationPopover;
    
    
        //start the view
    UIPopoverPresentationController *popController = [self.LanguageList popoverPresentationController];
    [self presentViewController:self.LanguageList
                       animated:YES
                     completion:nil];
    popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popController.sourceView = self.controls;
    popController.sourceRect = sender.frame;
    popController.delegate = self;
    [self.codes becomeFirstResponder];
    self.codes.inputAssistantItem.leadingBarButtonGroups = @[];

}

    //keyboard helpers
-(IBAction)keyboardButton:(UILongPressGestureRecognizer *) trigger{
    self.codes.inputAssistantItem.leadingBarButtonGroups = @[];
    UIButton* sender = (UIButton*)trigger.view;
    NSString* input = sender.titleLabel.text;
    switch(trigger.state){
        case UIGestureRecognizerStateBegan:{
            
            if([input isEqualToString:SHIFT]){
                [self ResetLayout]; return;
            }
            
            NSInteger rewindOffset = [self.completionEngine inputPressed:input
                                                               textField:self.codes];
            [self.completionEngine printDebug];
            [self moveCursorByOffset:rewindOffset];
        }
        case UIGestureRecognizerStateChanged:
                //NSLog(@"State changed");
            break;
        case UIGestureRecognizerStateEnded:{
            
        }
            
            break;
        default:
            break;
    }
    [self.codes becomeFirstResponder];
    self.codes.inputAssistantItem.leadingBarButtonGroups = @[];

    
}

-(IBAction)keyboardButtonTouched:(UIButton *)sender{
        //NSLog(@"button %@ touched to update current key", sender.titleLabel.text);
    self.currentKey = sender;
    NSInteger rewindOffset = [self.completionEngine inputPressed:sender.titleLabel.text
                                                       textField:self.codes];
    [self.completionEngine printDebug];
    [self moveCursorByOffset:rewindOffset];
    [self.codes becomeFirstResponder];
    self.codes.inputAssistantItem.leadingBarButtonGroups = @[];


}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    [self.codes becomeFirstResponder];
    self.codes.inputAssistantItem.leadingBarButtonGroups = @[];


    return YES;
}

    // MARK delegations for pop over:
- (void)popoverPresentationControllerDidDismissPopover:
(UIPopoverPresentationController *)popoverPresentationController {
    
        // called when a Popover is dismissed
        NSLog(@"Popover was dismissed with external tap.");
    [self.codes becomeFirstResponder];

}

- (BOOL)popoverPresentationControllerShouldDismissPopover:
(UIPopoverPresentationController *)popoverPresentationController {
    
        // return YES if the Popover should be dismissed
        // return NO if the Popover should not be dismissed
    [self.codes becomeFirstResponder];

    return YES;
}

- (void)popoverPresentationController:(UIPopoverPresentationController *)popoverPresentationController
          willRepositionPopoverToRect:(inout CGRect *)rect
                               inView:(inout UIView *__autoreleasing  _Nonnull *)view {
    
        // called when the Popover changes positon
    [self.codes becomeFirstResponder];

}


#pragma mark - long hold helper
- (void) TouchBegin:(UIButton*)sender {
        //NSLog(@"triggered %@", sender.titleLabel.text);
    NSString* SelectorName = [self.ButtonToSelector objectForKey:sender.titleLabel.text];
    self.Timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:NSSelectorFromString(SelectorName)
                                                userInfo:nil
                                                 repeats:YES];
    [self.codes becomeFirstResponder];

}

- (void) TouchEnd:(UIButton*)sender {
    [self.Timer invalidate];
    self.Timer = nil;
    [self.codes becomeFirstResponder];

}

-(void) SetSecondKeys{
        //first row:
    self.SecondFunctionalKey = [NSMutableDictionary new];
    self.FirstFunctionalKey = [NSMutableDictionary new];
    self.KeysHasSecondFunctions = [NSMutableArray new];
    self.Switcher = [NSMutableArray new];
    [self.SecondFunctionalKey setObject:@"`" forKey:@"~"];
    [self.SecondFunctionalKey setObject:@"!" forKey:@"1"];
    [self.SecondFunctionalKey setObject:@"@" forKey:@"2"];
    [self.SecondFunctionalKey setObject:@"#" forKey:@"3"];
    [self.SecondFunctionalKey setObject:@"$" forKey:@"4"];
    [self.SecondFunctionalKey setObject:@"%" forKey:@"5"];
    [self.SecondFunctionalKey setObject:@"^" forKey:@"6"];
    [self.SecondFunctionalKey setObject:@"&" forKey:@"7"];
    [self.SecondFunctionalKey setObject:@"*" forKey:@"8"];
    [self.SecondFunctionalKey setObject:@"(" forKey:@"9"];
    [self.SecondFunctionalKey setObject:@")" forKey:@"0"];
    [self.SecondFunctionalKey setObject:@"_" forKey:@"-"];
    [self.SecondFunctionalKey setObject:@"+" forKey:@"="];
        //alphabet:
    for(char c = 'a'; c<='z'; ++c){
        NSString *source = [NSString stringWithFormat:@"%c", c];
        NSString *target = [source uppercaseString];
        [self.SecondFunctionalKey setObject:target forKey:source];
    }
        //right part:
    [self.SecondFunctionalKey setObject:@"{" forKey:@"["];
    [self.SecondFunctionalKey setObject:@"}" forKey:@"]"];
    [self.SecondFunctionalKey setObject:@"|" forKey:@"\\"];
    [self.SecondFunctionalKey setObject:@":" forKey:@";"];
    [self.SecondFunctionalKey setObject:@"\"" forKey:@"'"];
    [self.SecondFunctionalKey setObject:@"<" forKey:@","];
    [self.SecondFunctionalKey setObject:@">" forKey:@"."];
    [self.SecondFunctionalKey setObject:@"?" forKey:@"/"];
    
    for(NSString* key in self.SecondFunctionalKey){
        [self.FirstFunctionalKey setObject:key forKey:[self.SecondFunctionalKey objectForKey:key]];
    }
    [self.Switcher addObject:self.FirstFunctionalKey];
    [self.Switcher addObject:self.SecondFunctionalKey];
}

- (IBAction)Clear:(UIButton* )sender{
    self.codes.text = @"";
    [self.completionEngine rewind];
    self.completionEngine.scopeLevel = 0;
}

@end
