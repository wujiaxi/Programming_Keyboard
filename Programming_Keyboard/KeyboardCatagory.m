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
    if(self.KeyboardReady) return;
    for(UIView * subview in self.view.subviews){
        if(subview.tag == KEYBOARD_TAG){
            for(UIButton* button in subview.subviews){
                if([button.titleLabel.text isEqualToString:@"BackSpace"]){
                    [self RegisterButton:button
                         toSelectorBegin:@"TouchBegin:"
                           toSelectorEnd:@"TouchEnd:"];
                    [self.ButtonToSelector setObject:@"BackSpaceButton:"
                                              forKey:button.titleLabel.text];
                    
                }else if (![button.titleLabel.text isEqualToString:@"Enter"]){
                        //NSLog(@"registered %@\n", button.titleLabel.text);
                    UILongPressGestureRecognizer*  rec = [[UILongPressGestureRecognizer alloc]
                                                          initWithTarget:self
                                                          action:@selector(CompletionLongPressed:)];
                    [button addGestureRecognizer:rec];
                    [self.keyboardLayout setObject:rec forKey:button.titleLabel.text];
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


//backspace helpers
-(void) BackSpaceButton:(NSTimer*)timer {
    NSInteger rewindOffset = [self.completionEngine inputPressed:@"BackSpace"
                                                       textField:self.codes];
    [self.completionEngine printDebug];
    [self moveCursorByOffset:rewindOffset];
}


#pragma mark - Completion Selection Panel Delegate
-(void) selectedCompletion:(NSString *)entry
{
        //NSLog(@"selected completion %@", entry);
    [self.codes insertText:[entry substringFromIndex:
                            [self.completionEngine from]]];
    [self.completionEngine rewind];
}



-(IBAction) CompletionLongPressed:(UILongPressGestureRecognizer *) sender{
    switch(sender.state){
        case UIGestureRecognizerStateBegan:{
                //normal action:
            [self keyboardButton:(UIButton*)sender.view];
            
            
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
}

    //keyboard helpers
-(IBAction)keyboardButton:(UIButton *)sender{
    NSString* input = sender.titleLabel.text;
        //NSLog(@"button %@ touched up", input);
    NSInteger rewindOffset = [self.completionEngine inputPressed:input
                                                       textField:self.codes];
    [self.completionEngine printDebug];
    [self moveCursorByOffset:rewindOffset];
}

-(IBAction)keyboardButtonTouched:(UIButton *)sender{
        //NSLog(@"button %@ touched to update current key", sender.titleLabel.text);
    self.currentKey = sender;
}

    // MARK delegations for pop over:
- (void)popoverPresentationControllerDidDismissPopover:
(UIPopoverPresentationController *)popoverPresentationController {
    
        // called when a Popover is dismissed
        NSLog(@"Popover was dismissed with external tap.");
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:
(UIPopoverPresentationController *)popoverPresentationController {
    
        // return YES if the Popover should be dismissed
        // return NO if the Popover should not be dismissed
    return YES;
}

- (void)popoverPresentationController:(UIPopoverPresentationController *)
popoverPresentationController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView *__autoreleasing  _Nonnull *)view {
    
        // called when the Popover changes positon
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
}

- (void) TouchEnd:(UIButton*)sender {
    [self.Timer invalidate];
    self.Timer = nil;
}


@end
