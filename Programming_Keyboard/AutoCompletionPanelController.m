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
    self.completionList = list;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"auto completion did load");
    self.preferredContentSize = CGSizeMake(480, 380);
    
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


//MARK: - Table View Data Source and Delegate
- (NSInteger)tableView:(UITableView *)tableView
            numberOfRowsInSection:(NSInteger)section{
    if(self.completionList){
        return [self.completionList count];
    }
    return 0;
}

-(UITableViewCell *) tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"AutoCompletionEntry"
                            forIndexPath:indexPath];
    
    cell.textLabel.text = self.completionList[indexPath.row];
    cell.detailTextLabel.text = @"";
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate selectedCompletion:self.completionList[indexPath.row]];
    if(self.presentingViewController)
        [self dismissViewControllerAnimated:NO completion:NULL];
    else
        [self.navigationController popViewControllerAnimated:YES];
    
}

@end
