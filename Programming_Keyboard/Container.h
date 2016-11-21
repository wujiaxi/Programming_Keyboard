//
//  ViewController.h
//  Programming_Keyboard
//
//  Created by Junlong Gao on 10/14/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MaterialControls/MDButton.h>

#import "AppDelegate.h"
#import "GTMAppAuth.h"
#import "GTMSessionFetcher.h"
#import "GTMSessionFetcherService.h"

#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLRDrive.h"

// pop up view


// data helpers
#import "CompletionEngine.h"
#import "DriveModel.h"
#import "CompletionLanguageSelectionController.h"
#import "AutoCompletionPanelController.h"


@interface Container : UIViewController
@property (nonatomic, weak) CompletionLanguageSelectionController *LanguageList;
@property (nonatomic, weak) AutoCompletionPanelController *completionPanel;
@property (nonatomic, strong) CompletionEngine *completionEngine;
@property(nonatomic) BOOL DriveLoading;
@property (nonatomic) BOOL KeyboardReady;

@property (nonatomic, weak) IBOutlet UIButton *currentKey;
@property (nonatomic, weak) IBOutlet UIView *keyboard;
@property(nonatomic, strong) NSMutableDictionary* ControlLayout;
@property(nonatomic, strong) NSTimer* Timer;
@property(nonatomic, strong) NSMutableDictionary* keyboardLayout;
@property(nonatomic, strong) NSMutableDictionary* ButtonToSelector;
@property (nonatomic, weak) IBOutlet UITextView *codes;
@property (nonatomic, weak) IBOutlet UIView *controls;

@property (nonatomic, strong) GTMAppAuthFetcherAuthorization *authorization;
@property (nonatomic, strong) GTLRDriveService *service;
@property (nonatomic, strong) DriveModel *driveModel;

@property (nonatomic, strong) NSMutableDictionary* FirstFunctionalKey;
@property (nonatomic, strong) NSMutableDictionary* SecondFunctionalKey;
@property (nonatomic, strong) NSMutableArray* KeysHasSecondFunctions;
@property (nonatomic, strong) NSMutableArray* Switcher;
@property (nonatomic) NSInteger Shift;

@end

