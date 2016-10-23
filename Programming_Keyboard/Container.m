//
//  ViewController.m
//  Programming_Keyboard
//
//  Created by Junlong Gao on 10/14/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import "Container.h"



@interface Container ()  <UIPopoverPresentationControllerDelegate, CompletionSelectionDelegate>

@end

@implementation Container



- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"main container init");
    
    self.codes.inputView = [UIView new];
    [self.codes becomeFirstResponder];

    //init data structure
    self.completionEngine = [[CompletionEngine alloc] initWithDemo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Completion Selection Delegate
-(void) selectedCompletion:(NSString *)entry
{
    NSLog(@"selected completion %@", entry);
    [self.codes insertText:[entry substringFromIndex:[self.completionEngine from]]];
    [self.completionEngine rewind];
}


// button touch down
-(IBAction)keyboardButtonTouched:(UIButton *)sender{
    NSLog(@"button %@ touched to update current key", sender.titleLabel.text);
    self.currentKey = sender;
}

-(IBAction)moveCursorLeft:(UIButton *)sender{
    NSString* prevChar =[self.completionEngine prevChar:self.codes];
    if(prevChar){
        NSLog(@"moving left to \"%@\"", prevChar);
        if([prevChar isEqualToString:@"{"]) [self.completionEngine LeaveScope];
        if([prevChar isEqualToString:@"}"]) [self.completionEngine EnterScope];
        NSLog(@"the current scope level is %d", self.completionEngine.scopeLevel);
    }else{
        NSLog(@"no prev");
    }
    [self moveCursorByOffset:-1];
    [self.completionEngine rewind];
    [self.completionEngine printDebug];

}

-(IBAction)moveCursorRight:(UIButton *)sender{
    [self moveCursorByOffset:1];
    [self.completionEngine rewind];
    [self.completionEngine printDebug];
    NSString* prevChar =[self.completionEngine prevChar:self.codes];
    if(prevChar){
        NSLog(@"moving right past \"%@\"", prevChar);
        if([prevChar isEqualToString:@"{"]) [self.completionEngine EnterScope];
        if([prevChar isEqualToString:@"}"]) [self.completionEngine LeaveScope];
        NSLog(@"the current scope level is %d", self.completionEngine.scopeLevel);
    }else{
        NSLog(@"no prev");
    }

}

-(void)moveCursorByOffset:(NSInteger)offset{
    UITextRange* selected = [self.codes selectedTextRange];
    if(selected){
        UITextPosition* next = [self.codes
                                positionFromPosition:selected.start
                                offset:offset];
        if(next){
            self.codes.selectedTextRange = [self.codes textRangeFromPosition:next
                                                                  toPosition:next];
        }
    }
}

//keyboard helpers
-(IBAction)keyboardButton:(UIButton *)sender{
    NSString* input = sender.titleLabel.text;
    NSLog(@"button %@ touched up", input);
    NSInteger rewindOffset = [self.completionEngine inputPressed:input
                                                       textField:self.codes];
    [self.completionEngine printDebug];
    
    [self moveCursorByOffset:rewindOffset];
    
    //[self.codes becomeFirstResponder];
}



//pop up gesture
-(IBAction) longPressed:(UILongPressGestureRecognizer *) sender{
    switch(sender.state){
        case UIGestureRecognizerStateBegan:{
            NSLog(@"long press triggered");
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
            NSLog(@"%f %f", self.currentKey.frame.origin.x, self.currentKey.frame.origin.y);
            NSLog(@"%@", self.currentKey);
            popController.sourceRect = self.currentKey.frame;
            popController.delegate = self;
            break;
        }
        case UIGestureRecognizerStateChanged:
            NSLog(@"State changed");
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"State End");
            break;
        default:
            break;
    }
    
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
@end
