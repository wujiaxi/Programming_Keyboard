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
#import "KeyboardState.h"


@interface Container ()  <UIPopoverPresentationControllerDelegate>
@property (nonatomic, weak) AutoCompletionPanelController *completionPanel;

@property (nonatomic) CompletionEngine *completionEngine;
@property (nonatomic) KeyboardState *keyboardState;

//current key
@property (nonatomic, weak) IBOutlet UIButton *currentKey;
@end

@implementation Container

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"main container init");
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
            popController.sourceView = self.currentKey;
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
