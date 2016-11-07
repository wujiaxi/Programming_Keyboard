//
//  DriveCatagory.m
//  Programming_Keyboard
//
//  Created by Junlong Gao on 11/1/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import "Catagories.h"



@implementation Container(DriveCatagory)

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
        self.DriveLoading = NO;
            //[self.driveModel SetupSketch];
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
#pragma mark - delegate method from drive model
- (void) populateTextField:(NSString*) data{
    self.codes.text = data;
    [self.driveModel SetupCompletion:@"cpp"];
}


- (IBAction)signoutButtonClicked:(id)sender {
        // Sign out
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
    [[self service] setAuthorizer:nil];
    self.DriveLoading = YES;
    [self presentViewController:[self createAuthController] animated:YES completion:nil];
}



- (void) populateCompletion:(NSString *) name
             withCompletion:(NSString *) data{
        //NSLog(@"swich to %@", name);
    [self.completionEngine SwitchCompletionFromFile:data];
}

#pragma mark - UIevent button touched
-(IBAction)CommitButton:(UIButton *)sender{
    [self.driveModel Commit:self.codes.text];
}


- (void) SelectedLanguage:(NSString *)language{
    [self.driveModel SetupCompletion:language];
}



@end
