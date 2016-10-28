//
//  ViewController.m
//  Programming_Keyboard
//
//  Created by Junlong Gao on 10/14/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import "Container.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"
#define KEYBOARD_TAG 1
#define CONTROL_TAG 2

static NSString *const kKeychainItemName = @"Drive API";
static NSString *const kClientID = @"55359119705-ucdj2bdv598gdpbpn57on3pd2fsa8ka6.apps.googleusercontent.com";


@interface Container ()  <UIPopoverPresentationControllerDelegate,
                            CompletionSelectionDelegate,
                            FileSyncDelegate>

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

    //init data structure
    self.completionEngine = [[CompletionEngine alloc] initWithDemo];
    
    //init google dirve
    self.service = [[GTLServiceDrive alloc] init];
    self.service.authorizer =
    [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                          clientID:kClientID
                                                      clientSecret:nil];
    self.driveModel = [[DriveModel alloc] init];
    self.driveModel.delegate = self;
    self.driveModel.service = self.service;
    
}

- (void)viewDidLayoutSubviews{
    self.keyboardLayout = [NSMutableDictionary new];
    self.ButtonToSelector = [NSMutableDictionary new];
    if (!self.service.authorizer.canAuthorize) {
        // Not yet authorized, request authorization by pushing the login UI onto the UI stack.
        [self presentViewController:[self createAuthController] animated:YES completion:nil];
    }
    [self.driveModel SetupSketch];
    
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
                    [self.ButtonToSelector setObject:[NSString stringWithFormat:@"MoveCursor%@:", button.titleLabel.text]
                                              forKey:button.titleLabel.text];

                }
            }
        }
    }
    [self.codes becomeFirstResponder];
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

// Creates the auth controller for authorizing access to Drive API.
- (GTMOAuth2ViewControllerTouch *)createAuthController {
    GTMOAuth2ViewControllerTouch *authController;
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    NSArray *scopes = [NSArray arrayWithObjects:kGTLAuthScopeDriveMetadata, kGTLAuthScopeDrive, nil];
    authController = [[GTMOAuth2ViewControllerTouch alloc]
                      initWithScope:[scopes componentsJoinedByString:@" "]
                      clientID:kClientID
                      clientSecret:nil
                      keychainItemName:kKeychainItemName
                      delegate:self
                      finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}

// Handle completion of the authorization process, and update the Drive API
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error {
    if (error != nil) {
        [self showAlert:@"Authentication Error" message:error.localizedDescription];
        self.service.authorizer = nil;
    }
    else {
        self.service.authorizer = authResult;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:title
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok =
    [UIAlertAction actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
     {
         [alert dismissViewControllerAnimated:YES completion:nil];
     }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
}

//file handler

- (void) populateTextField:(NSString*) data{
    self.codes.text = data;
}

-(IBAction)CommitButton:(UIButton *)sender{
    [self.driveModel commit:self.codes.text];
}


@end
