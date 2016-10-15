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


@interface Container ()  <UIPopoverPresentationControllerDelegate>
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
    NSArray *sample = @[@"vector<int>",
                          @"vector<string>",
                          @"unordered_set<string>",
                          @"unordered_set<int>"];
    self.completionEngine = [[CompletionEngine alloc] initWithArray:sample];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// button touch down
-(IBAction)keyboardButtonTouched:(UIButton *)sender{
    NSLog(@"button %@ touched to update current key", sender.titleLabel.text);
    self.currentKey = sender;
}

-(IBAction)moveCursorLeft:(UIButton *)sender{
    UITextRange* selected = self.codes.selectedTextRange;
    if(selected){
        UITextPosition* next = [self.codes
                                positionFromPosition:selected.start
                                offset:-1];
        if(next){
            self.codes.selectedTextRange = [self.codes textRangeFromPosition:next
                                                                  toPosition:next];
        }
    }
}

-(IBAction)moveCursorRight:(UIButton *)sender{
    UITextRange* selected = [self.codes selectedTextRange];
    if(selected){
        UITextPosition* next = [self.codes
                                positionFromPosition:selected.start
                                offset:+1];
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
        [self.codes  deleteBackward];
    }else if([input isEqualToString:@"Enter"]){
        [self.codes insertText:@"\n"];
    }else if([input isEqualToString:@"Space"]){
        [self.codes insertText:@" "];
    }else{
        [self.codes insertText:input];
    }
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
            self.completionPanel.modalPresentationStyle = UIModalPresentationPopover;
            UIPopoverPresentationController *popController = [self.completionPanel popoverPresentationController];
            
            //populate the completion options
            NSArray *list = @[@"vector<string>", @"vector<int>"];
            [self.completionPanel populateCompletion:list];
            
            //start the view
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
- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    
    // called when a Popover is dismissed
    NSLog(@"Popover was dismissed with external tap.");
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    
    // return YES if the Popover should be dismissed
    // return NO if the Popover should not be dismissed
    return YES;
}

- (void)popoverPresentationController:(UIPopoverPresentationController *)popoverPresentationController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView *__autoreleasing  _Nonnull *)view {
    
    // called when the Popover changes positon
}
@end
