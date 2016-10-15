//
//  KeyboardState.m
//  Programming_Keyboard
//
//  Created by Junlong Gao on 10/14/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeyboardState.h"

@interface KeyboardState ()
@end

@implementation KeyboardState
-(id) initWithBlank{
    if(self = [super init]){
        self.buffer = [NSMutableString new];
    }
    return self;
}

-(void) keyPush:(NSString *)value{
    [self.buffer appendString:value];
}

-(void) keyPop{
    if([self.buffer length]){
        [self.buffer deleteCharactersInRange:NSMakeRange([self.buffer length]-1, 1)];
    }
}

-(void) append:(NSString *)word{
    return;
}
@end
