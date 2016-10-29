//
//  CompletionLanguageSelectionController.h
//  Programming_Keyboard
//
//  Created by Junlong Gao on 10/29/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CompletionLanguageDelegate <NSObject>
-(void) SelectedLanguage:(NSString *)language;

@end

@interface CompletionLanguageSelectionController : UITableViewController
@property (nonatomic, weak) id<CompletionLanguageDelegate> delegate;

@end
