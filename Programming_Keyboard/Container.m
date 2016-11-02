//
//  ViewController.m
//  Programming_Keyboard
//
//  Created by Junlong Gao on 10/14/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import "Container.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "Catagories.h"
#import "GTLDrive.h"



@interface Container ()  <UIPopoverPresentationControllerDelegate,
                            CompletionLanguageDelegate,
                            CompletionSelectionDelegate,
                            UIGestureRecognizerDelegate,
                            FileSyncDelegate>

@end

@implementation Container

- (void)viewDidLoad {
    [super viewDidLoad];
    self.DriveReady = NO;
    self.KeyboardReady = NO;
    
    //NSLog(@"main container init");
    
    self.codes.inputView = [UIView new];
    self.codes.autocorrectionType = UITextAutocorrectionTypeNo;


    //init data structure
    self.completionEngine = [[CompletionEngine alloc] init];
    
    //init google dirve
    self.service = [[GTLServiceDrive alloc] init];
    self.service.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                          clientID:kClientID
                                                      clientSecret:nil];
    self.driveModel = [[DriveModel alloc] init];
    self.driveModel.delegate = self;
    self.driveModel.service = self.service;
}

#pragma mark - initialization
- (void)viewDidLayoutSubviews{
    self.keyboardLayout = [NSMutableDictionary new];
    self.ButtonToSelector = [NSMutableDictionary new];
    if (!self.service.authorizer.canAuthorize && !self.DriveReady) {
        // Not yet authorized, request authorization by pushing the login UI onto the UI stack.
        [self presentViewController:[self createAuthController] animated:YES completion:nil];
    }else{
        self.DriveReady = YES;
        [self.driveModel SetupSketch];
    }
    
    [self SetupKeyboard];
    [self.codes becomeFirstResponder];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
