//
//  CompletionEngine.h
//  Programming_Keyboard
//
//  Created by Junlong Gao on 10/14/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#ifndef CompletionEngine_h
#define CompletionEngine_h
#import <UIKit/UIKit.h>
/*
 the completion engine is maintains the state
 of the current code
 1) code
 2) cursor position
 3) indentation levels
 */
@interface CompletionEngine : NSObject

@property (nonatomic) int scopeLevel;

- (id) initWithArray:(NSArray *) schema;

- (id) initWithDemo;

- (NSInteger) inputPressed:(NSString*) input
                 textField:(UITextView*) code;


//add a char to the current search state
- (void) addChar:(NSString *) c;

//remove the last char from the current search state
- (void) popChar;

-(UITextPosition*) cursor:(UITextView*) codes
             with:(NSInteger) offset;

-(NSString*) prevChar:(UITextView*) codes;

//dump the list of words that fits the current search state;
- (NSArray<NSString*> *) dumpList;

//reset the state into empty
- (void) rewind;

- (void) printDebug;

// this returns the current completion prefix starting index
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

    //cursor control:
- (NSInteger) OffsetToPrevLine:(UITextView*) codes;
- (NSInteger) OffsetToNextLine:(UITextView*) codes;


@end


#endif /* CompletionEngine_h */
