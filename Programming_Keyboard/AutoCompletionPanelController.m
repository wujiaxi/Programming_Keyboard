//
//  AutoCompletionPanelController.m
//  Programming_Keyboard
//
//  Created by Junlong Gao on 10/14/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import "AutoCompletionPanelController.h"

@interface AutoCompletionPanelController ()

@end

@implementation AutoCompletionPanelController
-(void) populateCompletion:(NSArray*) list{
    NSLog(@"incommint autocompletion list:");
    for (int i = 0; i < [list count]; ++i) {
        NSLog(@"%@", list[i]);
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"auto completion did load");
    self.preferredContentSize = CGSizeMake(320, 480);
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(CGSize)contentSizeForViewInPopover
{
    return self.view.bounds.size;
}

@end
