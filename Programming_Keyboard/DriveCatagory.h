//
//  DriveCatagory.h
//  Programming_Keyboard
//
//  Created by Junlong Gao on 11/1/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Container.h"


/*! @brief The OIDC issuer from which the configuration will be discovered.
 */
static NSString *const kIssuer = @"https://accounts.google.com";

/*! @brief The OAuth client ID.
 @discussion For Google, register your client at
 https://console.developers.google.com/apis/credentials?project=_
 The client should be registered with the "iOS" type.
 */
static NSString *const kClientID = @"992765400465-7hsltj7oo2b0g4kmk1ilo3gendc3i5no.apps.googleusercontent.com";

/*! @brief The OAuth redirect URI for the client @c kClientID.
 @discussion With Google, the scheme of the redirect URI is the reverse DNS notation of the
 client ID. This scheme must be registered as a scheme in the project's Info
 property list ("CFBundleURLTypes" plist key). Any path component will work, we use
 'oauthredirect' here to help disambiguate from any other use of this scheme.
 */
static NSString *const kRedirectURI =
@"com.googleusercontent.apps.992765400465-7hsltj7oo2b0g4kmk1ilo3gendc3i5no:/oauthredirect";

static NSString *const kKeychainItemName = @"Drive API Quickstart";
//static NSString *const kClientID = @"55359119705-ucdj2bdv598gdpbpn57on3pd2fsa8ka6.apps.googleusercontent.com";

@interface Container(DriveCatagory)

/*
- (GTMOAuth2ViewControllerTouch *)createAuthController;
    
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error;
*/

- (void)authWithAutoCodeExchange;

- (void)showAlert:(NSString *)title message:(NSString *)message;

- (void) populateTextField:(NSString*) data;
 
- (IBAction)signoutButtonClicked:(id)sender;


- (void) populateCompletion:(NSString *) name
             withCompletion:(NSString *) data;

-(IBAction)CommitButton:(UIButton *)sender;

- (void) SelectedLanguage:(NSString *)language;

@end
