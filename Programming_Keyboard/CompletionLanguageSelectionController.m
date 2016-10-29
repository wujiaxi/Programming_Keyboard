//
//  CompletionLanguageSelectionController.m
//  Programming_Keyboard
//
//  Created by Junlong Gao on 10/29/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import "CompletionLanguageSelectionController.h"

@interface CompletionLanguageSelectionController ()
@property (nonatomic, strong) NSArray<NSString*>* AvailableList;
@end

@implementation CompletionLanguageSelectionController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.AvailableList = @[@"cpp", @"java", @"go"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.AvailableList count];;
}

-(UITableViewCell *) tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"AvailableLanguageEntry"
                                                                 forIndexPath:indexPath];
    
    cell.textLabel.text = self.AvailableList[indexPath.row];
    cell.detailTextLabel.text = @"";
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate SelectedLanguage:self.AvailableList[indexPath.row]];
    if(self.presentingViewController)
        [self dismissViewControllerAnimated:NO completion:NULL];
    else
        [self.navigationController popViewControllerAnimated:YES];
    
}
@end
