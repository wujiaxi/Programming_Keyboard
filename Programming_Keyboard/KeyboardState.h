//
//  KeyboardState.h
//  Programming_Keyboard
//
//  Created by Junlong Gao on 10/14/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#ifndef KeyboardState_h
#define KeyboardState_h

#import <UIKit/UIKit.h>

@interface KeyboardState : NSObject
@property NSMutableString* buffer;

-(id) initWithBlank;

-(void) keyPush:(NSString *) value;

-(void) keyPop;

-(void) append:(NSString *) word;

@end
/*
 the keyboard is responsible for
 (1) monitoring the most recent white character (start of the prefix)
 (2) talk to trie for any newly input character
 (3) rewind to white character to start a new
 (4) internally maintain buffer
 */

#endif /* KeyboardState_h */
