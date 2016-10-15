//
//  AutoCompletionPanelController.h
//  Programming_Keyboard
//
//  Created by Junlong Gao on 10/14/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CompletionSelectionDelegate <NSObject>
-(void) selectedCompletion:(NSString *)entry;

@end

@interface AutoCompletionPanelController : UITableViewController
@property (nonatomic, strong) NSArray* completionList;
@property (nonatomic, weak) id<CompletionSelectionDelegate> delegate;

-(void) populateCompletion:(NSArray*) list;
@end
