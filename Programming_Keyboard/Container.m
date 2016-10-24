//
//  ViewController.m
//  Programming_Keyboard
//
//  Created by Junlong Gao on 10/14/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import "Container.h"
#define KEYBOARD_TAG 1
#define CONTROL_TAG 2


@interface Container ()  <UIPopoverPresentationControllerDelegate, CompletionSelectionDelegate>
@property(nonatomic, strong) NSMutableDictionary* keyboardLayout;
@property(nonatomic, strong) NSMutableDictionary* ControlLayout;

@property(nonatomic, strong) NSMutableDictionary* ButtonToSelector;
@property(nonatomic, strong) NSTimer* Timer;

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

- (void)viewDidLayoutSubviews{
    self.keyboardLayout = [NSMutableDictionary new];
    self.ButtonToSelector = [NSMutableDictionary new];
    
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
                    NSLog(@"registered %@\n", button.titleLabel.text);
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
                    NSString* buttonName = button.titleLabel.text;
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

    [button addTarget:self action:NSSelectorFromString(selectorBeginName) forControlEvents: UIControlEventTouchDown];
    [button addTarget:self action:NSSelectorFromString(selectorEndName) forControlEvents:
     UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Completion Selection Delegate
-(void) selectedCompletion:(NSString *)entry
{
    NSLog(@"selected completion %@", entry);
    [self.codes insertText:[entry substringFromIndex:
                            [self.completionEngine from]]];
    [self.completionEngine rewind];
}


// button touch down
-(IBAction)keyboardButtonTouched:(UIButton *)sender{
    NSLog(@"button %@ touched to update current key", sender.titleLabel.text);
    self.currentKey = sender;
}

-(IBAction)MoveCursorUp:(UIButton *)sender{
    NSInteger offset = [self.completionEngine OffsetToPrevLine:self.codes];
    for(NSInteger i = 0; i < -offset; ++i){
        [self MoveCursorLeft:sender];
    }
}

-(IBAction)MoveCursorDown:(UIButton *)sender{
    NSInteger offset = [self.completionEngine OffsetToNextLine:self.codes];
    for(NSInteger i = 0; i < offset; ++i){
        [self MoveCursorRight:sender];
    }
    
}

-(IBAction)MoveCursorLeft:(UIButton *)sender{
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

-(IBAction)MoveCursorRight:(UIButton *)sender{
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
}

//backspace helpers
-(void) BackSpaceButton:(NSTimer*)timer {
    NSInteger rewindOffset = [self.completionEngine inputPressed:@"BackSpace"
                                                       textField:self.codes];
    [self.completionEngine printDebug];
    [self moveCursorByOffset:rewindOffset];
}

//pop up gesture
-(IBAction) CompletionLongPressed:(UILongPressGestureRecognizer *) sender{
    switch(sender.state){
        case UIGestureRecognizerStateBegan:{
            //normal action:
            UIButton* button = sender.view;
            NSLog(@"normal key long press triggered %@", button.titleLabel.text);
            [self keyboardButton:button];
            
            
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

- (void) TouchBegin:(UIButton*)sender {
    NSLog(@"triggered %@", sender.titleLabel.text);
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
