//
//  ViewController.m
//  Programming_Keyboard
//
//  Created by Junlong Gao on 10/14/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import "Container.h"

// pop up view
#import "AutoCompletionPanelController.h"

// data helpers
#import "CompletionEngine.h"


@interface Container ()  <UIPopoverPresentationControllerDelegate, CompletionSelectionDelegate>
@property (nonatomic, weak) AutoCompletionPanelController *completionPanel;

@property (nonatomic) CompletionEngine *completionEngine;

//current key
@property (nonatomic, weak) IBOutlet UIButton *currentKey;
// text display:
@property (nonatomic, weak) IBOutlet UITextView *codes;
// keyboard view:
@property (nonatomic, weak) IBOutlet UIView *keyboard;

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





-(NSString*) prevChar{
    UITextRange* selected = [self.codes selectedTextRange];
    if(selected){
        UITextPosition* cur = [self.codes
                               positionFromPosition:selected.start
                               offset:-1];
        if(cur){
            UITextRange *range = [self.codes
                                  textRangeFromPosition:cur
                                  toPosition:selected.start];
            return [self.codes textInRange:range];
        }
    }
    return nil;
}


-(IBAction)moveCursorLeft:(UIButton *)sender{
    NSString* prevChar =[self prevChar];
    if(prevChar){
        NSLog(@"moving left to \"%@\"", [self prevChar]);
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
    NSString* prevChar =[self prevChar];
    if(prevChar){
        NSLog(@"moving right past \"%@\"", [self prevChar]);
        if([prevChar isEqualToString:@"{"]) [self.completionEngine EnterScope];
        if([prevChar isEqualToString:@"}"]) [self.completionEngine LeaveScope];
        NSLog(@"the current scope level is %d", self.completionEngine.scopeLevel);
    }else{
        NSLog(@"no prev");
    }

}

-(void)moveCursorByOffset:(int)offset{
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
    if([input isEqualToString:@"BackSpace"]){
        NSLog(@"test length: %d", [self.codes.text length]);
        NSString* prevChar = [self prevChar];
        NSLog(@"%@", [self.codes selectedTextRange]);
        
        [self.codes  deleteBackward];
        
        
        if([prevChar isEqualToString:@"{"] ||
            [prevChar isEqualToString:@"}"]){
            NSLog(@"%@", [self.codes selectedTextRange]);
            
            UITextPosition* cursor = [self.codes selectedTextRange].start;
            NSInteger rewindOffset = [self.codes.text length] - [self.codes selectedRange].location;
            NSLog(@"rewind offset = %ld", (long)rewindOffset);
            NSInteger Bracelocation =
            [self.codes offsetFromPosition:self.codes.beginningOfDocument
                                toPosition:cursor];
            NSString* newCode = nil;
            if([prevChar isEqualToString:@"{"]){
                newCode = [self.completionEngine
                              fixScopeLeft:self.codes.text
                              from:Bracelocation];
            }else{
                newCode = [self.completionEngine
                              fixScopeRight:self.codes.text
                              from:Bracelocation];
            }
            
            if(newCode == nil) return;
            NSLog(@"replaced scope: %@", newCode);
            self.codes.text = newCode;
            [self moveCursorByOffset:-rewindOffset];
            [self.completionEngine rewind];
            return;
        }
        
        [self.completionEngine popChar];
    }else{
        if([input isEqualToString:@"Enter"]){
            [self.completionEngine rewind];
            [self.codes insertText:[self.completionEngine scopedNewline]];
            return;
        }else if([input isEqualToString:@"Space"]){
            [self.completionEngine rewind];
            [self.codes insertText:@" "];
            return;
        }
        
        NSMutableArray* completionPair = [self.completionEngine completionPair:input];
        NSLog(@"reseted pair: %@", completionPair);
        if(completionPair){
            [self.completionEngine rewind];
            [self.codes insertText:completionPair[0]];
            
            NSInteger offset = [completionPair[1] integerValue];
            NSLog(@"offset by: %d", -offset);
            [self moveCursorByOffset:-offset];
            
            return;
        }
        
        //reaches here, it is not a special char or a completion pair
        //add that to completion engine
        [self.completionEngine addChar:input];
        [self.codes insertText:input];
        
    }
    //debug:
    [self.completionEngine printDebug];
    
    [self.codes becomeFirstResponder];
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
