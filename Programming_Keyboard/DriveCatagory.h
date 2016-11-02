//
//  DriveCatagory.h
//  Programming_Keyboard
//
//  Created by Junlong Gao on 11/1/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Container.h"



static NSString *const kKeychainItemName = @"Drive API";
static NSString *const kClientID = @"55359119705-ucdj2bdv598gdpbpn57on3pd2fsa8ka6.apps.googleusercontent.com";

@interface Container(DriveCatagory)


- (GTMOAuth2ViewControllerTouch *)createAuthController;
    
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error;

- (void)showAlert:(NSString *)title message:(NSString *)message;

- (void) populateTextField:(NSString*) data;
 
- (IBAction)signoutButtonClicked:(id)sender;


- (void) populateCompletion:(NSString *) name
             withCompletion:(NSString *) data;

-(IBAction)CommitButton:(UIButton *)sender;

- (void) SelectedLanguage:(NSString *)language;

@end
