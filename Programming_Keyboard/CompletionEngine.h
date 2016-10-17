//
//  CompletionEngine.h
//  Programming_Keyboard
//
//  Created by Junlong Gao on 10/14/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#ifndef CompletionEngine_h
#define CompletionEngine_h

@interface CompletionEngine : NSObject
@property (nonatomic) int scopeLevel;

- (id) initWithArray:(NSArray *) schema;

- (id) initWithDemo;

//add a char to the current search state
- (void) addChar:(NSString *) c;

//remove the last char from the current search state
- (void) popChar;

//dump the list of words that fits the current search state;
- (NSArray<NSString*> *) dumpList;

//reset the state into empty
- (void) rewind;

- (void) printDebug;

- (NSUInteger) from;

- (Boolean) isCompletionPair:(NSString*) lhs;
- (NSArray* ) completionPair:(NSString*) lhs;

- (NSString*) scopedNewline;

//scope control
- (void) LeaveScope;
- (void) EnterScope;
- (NSString*) fixScopeLeft:(NSString*) code
                  from:(NSInteger) leftBrace;
- (NSString*) fixScopeRight:(NSString*) code
                      from:(NSInteger) rightBrace;

@end
/*
the completion engine is responsible for 
 (1) consuming schema and internally store a trie
 (2) a simple interface to travel through the trie
 (3) dump the list of all word with the current prefix
*/

#endif /* CompletionEngine_h */
