//
//  DriveCatagory.m
//  Programming_Keyboard
//
//  Created by Junlong Gao on 11/1/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import "Catagories.h"
#import <AppAuth/AppAuth.h>
#import <GTMAppAuth/GTMAppAuth.h>
#import <QuartzCore/QuartzCore.h>



@implementation Container(DriveCatagory)

/*
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
*/
- (void)setGtmAuthorization:(GTMAppAuthFetcherAuthorization*)authorization {
    if ([self.authorization isEqual:authorization]) {
        return;
    }
    self.authorization = authorization;
    self.service.authorizer = authorization;
}

- (void)authWithAutoCodeExchange {
    NSURL *issuer = [NSURL URLWithString:kIssuer];
    NSURL *redirectURI = [NSURL URLWithString:kRedirectURI];
    [OIDAuthorizationService discoverServiceConfigurationForIssuer:issuer
                                                        completion:^(OIDServiceConfiguration *_Nullable configuration, NSError *_Nullable error)
     {
         
         if (!configuration) {
             //[self logMessage:@"Error retrieving discovery document: %@", [error localizedDescription]];
             [self setGtmAuthorization:nil];
             return;
         }
         
         //[self logMessage:@"Got configuration: %@", configuration];
         
         // builds authentication request
         NSArray *scopes = [NSArray arrayWithObjects:kGTLRAuthScopeDriveMetadata, kGTLRAuthScopeDrive, kGTLRAuthScopeDriveFile, nil];

         OIDAuthorizationRequest *request =
         [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                       clientId:kClientID
                                                         scopes:scopes
                                                    redirectURL:redirectURI
                                                   responseType:OIDResponseTypeCode
                                           additionalParameters:nil];
         // performs authentication request
         AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
         NSLog(@"Initiating authorization request with scope: %@", request.scope);

         //[self logMessage:@"Initiating authorization request with scope: %@", request.scope];
         
         appDelegate.currentAuthorizationFlow =
         [OIDAuthState authStateByPresentingAuthorizationRequest:request
                                        presentingViewController:self
                                                        callback:^(OIDAuthState *_Nullable authState,
                                                                   NSError *_Nullable error)
          {
              if (authState) {
                  GTMAppAuthFetcherAuthorization *authorization =
                  [[GTMAppAuthFetcherAuthorization alloc] initWithAuthState:authState];
                  
                  [self setGtmAuthorization:authorization];
                  [self.driveModel SetupSketch];

                  //[self logMessage:@"Got authorization tokens. Access token: %@",
                  // authState.lastTokenResponse.accessToken];
              } else {
                  [self setGtmAuthorization:nil];
                  NSLog(@"Authorization error: %@", [error localizedDescription]);
                  //[self logMessage:@"Authorization error: %@", [error localizedDescription]];
              }
          }];
     }];
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
    //[GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
    [[self service] setAuthorizer:nil];
    self.DriveLoading = YES;
    //[self presentViewController:[self createAuthController] animated:YES completion:nil];
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
