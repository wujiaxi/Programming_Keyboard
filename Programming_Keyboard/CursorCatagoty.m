//
//  CursorCatagoty.m
//  Programming_Keyboard
//
//  Created by Junlong Gao on 11/1/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import "Catagories.h"



@implementation Container(CursorCatagoty)
-(IBAction)MoveCursorUp:(UIButton *)sender{
    NSInteger offset = [self.completionEngine OffsetToPrevLine:self.codes];
    for(NSInteger i = 0; i < -offset; ++i){
        [self MoveCursorLeft:sender];
    }
    [self.codes becomeFirstResponder];

}

-(IBAction)MoveCursorDown:(UIButton *)sender{
    NSInteger offset = [self.completionEngine OffsetToNextLine:self.codes];
    for(NSInteger i = 0; i < offset; ++i){
        [self MoveCursorRight:sender];
    }
    [self.codes becomeFirstResponder];

}

-(IBAction)MoveCursorLeft:(UIButton *)sender{
    NSString* prevChar =[self.completionEngine prevChar:self.codes];
    if(prevChar){
            //NSLog(@"moving left to \"%@\"", prevChar);
        if([prevChar isEqualToString:@"{"]) [self.completionEngine LeaveScope];
        if([prevChar isEqualToString:@"}"]) [self.completionEngine EnterScope];
            //NSLog(@"the current scope level is %d", self.completionEngine.scopeLevel);
    }
    [self moveCursorByOffset:-1];
    [self.completionEngine rewind];
    [self.completionEngine printDebug];
    [self.codes becomeFirstResponder];

}

-(IBAction)MoveCursorRight:(UIButton *)sender{
    [self moveCursorByOffset:1];
    [self.completionEngine rewind];
    [self.completionEngine printDebug];
    NSString* prevChar =[self.completionEngine prevChar:self.codes];
    if(prevChar){
            //NSLog(@"moving right past \"%@\"", prevChar);
        if([prevChar isEqualToString:@"{"]) [self.completionEngine EnterScope];
        if([prevChar isEqualToString:@"}"]) [self.completionEngine LeaveScope];
    }
    [self.codes becomeFirstResponder];

}




#pragma mark - helpers
-(void)moveCursorByOffset:(NSInteger)offset{
    UITextRange* selected = [self.codes selectedTextRange];
    if(selected){
        UITextPosition* next = [self.codes
                                positionFromPosition:selected.start
                                offset:offset];
        if(next){
            self.codes.selectedTextRange = [self.codes textRangeFromPosition:next
                                                                  toPosition:next];
        }
    }
}

@end
