//
//  CursorCatagoty.h
//  Programming_Keyboard
//
//  Created by Junlong Gao on 11/1/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Container.h"

@interface Container(CursorCatagoty)
-(void)moveCursorByOffset:(NSInteger)offset;

    // button touch down
    //-(IBAction)keyboardButtonTouched:(UIButton *)sender;

-(IBAction)MoveCursorLeft:(UIButton *)sender;

-(IBAction)MoveCursorRight:(UIButton *)sender;

-(IBAction)MoveCursorDown:(UIButton *)sender;

-(IBAction)MoveCursorUp:(UIButton *)sender;
@end
