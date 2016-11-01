//
//  CompletionEngine.m
//  Programming_Keyboard
//
//  Created by Junlong Gao on 10/14/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CompletionEngine.h"
#import "Trie.h"

@interface CompletionEngine ()
@property (nonatomic, strong) Trie* dict;
@property (nonatomic, strong) NSMutableString* prefix;
@property (nonatomic) int limit;
@property (nonatomic) int nullCount;
@property (nonatomic) NSMutableSet* completionPair;
//current state is a list of trie node representing the
//set of autocompletions
@property (nonatomic, strong) Trie* currentState;
@end

@implementation CompletionEngine

- (id) initWithArray:(NSArray *) schema{
    if(self = [super init]){
        self.completionPair = [NSMutableSet setWithArray:
                               @[@"(",@")", @"[", @"]", @"\"", @"'", @"{"]];
        //NSLog(@"init with array");
        self.limit = 1;
        self.scopeLevel = 0;
        self.dict = [[Trie alloc] initWithKey:'\0'];
        for(int i = 0; i < [schema count]; ++i){
            [self.dict addWord:schema[i]
                         sofar:schema[i]];
        }
        [self rewind];
    }
    return self;
}

- (id) initWithDemo{
    NSArray *sample = @[@"#include ",
                        @"<iostream>",
                        @"using",
                        @"namespace",
                        @"std",
                        @"int",
                        @"main",
                        @"cout<< ",
                        @"<<endl;",
                        @"vector<int>",
                        @"vector<string>",
                        @"unordered_set<string>",
                        @"unordered_set<int>"];
    return [self initWithArray:sample];
}

- (id) init{
    if(self = [super init]){
        self.completionPair = [NSMutableSet setWithArray:
                               @[@"(",@")", @"[", @"]", @"\"", @"'", @"{"]];
        self.limit = 1;
        self.scopeLevel = 0;
        [self rewind];
    }
    return self;
}

- (void) SwitchCompletionFromFile:(NSString *)file{
    NSArray *schema=[file componentsSeparatedByString:@"\n"];
    self.dict = [[Trie alloc] initWithKey:'\0'];
    for(int i = 0; i < [schema count]; ++i){
        [self.dict addWord:schema[i]
                     sofar:schema[i]];
    }
    [self rewind];
}

- (NSInteger) inputPressed:(NSString*) input
            textField:(UITextView*) code{
    NSString* prevChar =[self prevChar:code];
    if([input isEqualToString:@"⇦"]){
        //NSLog(@"test length: %lu", (unsigned long)[code.text length]);
        //NSLog(@"%@", [code selectedTextRange]);
        
        
        //fix scope
        if([prevChar isEqualToString:@"{"] ||
           [prevChar isEqualToString:@"}"]){
            //NSLog(@"%@", [code selectedTextRange]);
            
            UITextPosition* cursor = [code selectedTextRange].start;
            NSInteger Bracelocation =
                    [code offsetFromPosition:code.beginningOfDocument
                                  toPosition:cursor] - 1;
            NSInteger offset = [code offsetFromPosition:code.endOfDocument
                                              toPosition:cursor];
            
            //cursor postion is always the index of the char after the cursor(the index
            //where new char will be inserted
            
            NSString* newCode = nil;
            if([prevChar isEqualToString:@"{"]){
                newCode = [self fixScopeLeft:code.text from:Bracelocation];
                offset -= ([newCode length] - [code.text length]) + 1;
            }else{
                newCode = [self fixScopeRight:code.text from:Bracelocation];
            }
            
            if(newCode){
                //NSLog(@"replaced scope: %@", newCode);
                code.text = newCode;
                [self rewind];
                return offset;
            }
        }
        //plain deletion
        [code deleteBackward];
        [self popChar];
        return 0;
        
    }else{
        //white chars
        if([input isEqualToString:@"↵"]){
            [self rewind];
            [code insertText:[self scopedNewline]];
            return 0;
        }else if([input isEqualToString:@" "]){
            [self rewind];
            [code insertText:@" "];
            return 0;
        }else if([input isEqualToString:@"⇪"]){
            NSLog(@"shift pressed");
            return 0;
        }
        
        //trivial chars - check pairs first
        NSArray* completionPair = [self completionPair:input];
        //NSLog(@"reseted pair: %@", completionPair);
        if(completionPair){
            [self rewind];
            [code insertText:completionPair[0]];
            NSInteger offset = [completionPair[1] integerValue];
            //NSLog(@"offset by: %ld", (long)-offset);
            return -offset;
        }
        
        //reaches here, it is not a special char or a completion pair
        //add that to completion engine
        [self addChar:input];
        [code insertText:input];
        return 0;
    }
    return 0;
}


-(void) rewind{
    self.prefix = [NSMutableString new];
    self.nullCount = 0;
    self.currentState = self.dict;
}

-(NSArray*) dumpList{
    if([self.prefix length] < self.limit || self.nullCount){
        return nil;
    }
    return [self.currentState collect];
}

- (void) addChar:(NSString*) c{
    [self.prefix appendString:c];
    Trie* next = [self.currentState.children objectForKey:c];
    if(next){
        self.currentState = next;
    }else{
        self.nullCount++;
    }
}

- (void) popChar{
    if([self.prefix length] == 0){
        return;
    }
    [self.prefix deleteCharactersInRange:NSMakeRange([self.prefix length]-1, 1)];
    if(self.nullCount){
        self.nullCount--;
    }else{
        self.currentState = self.currentState.p;
    }
}

- (void) printDebug{
    NSArray* rst = [self dumpList];
    if(rst){
        for(NSString* s in rst){
            NSLog(@"%@", s);
        }
    }else{
        NSLog(@"no completion available");
    }
}

- (NSUInteger) from{
    if(self.prefix){
        return [self.prefix length];
    }
    return 0;
}

- (NSString*) scopedNewline{
    NSMutableString* toInsert = [NSMutableString stringWithString:@"\n"];
    for(int i = 0; i < self.scopeLevel; ++i){
        for(int j = 0; j < 4; ++j){
            [toInsert appendString:@" "];
        }
    }
    return toInsert;
}

- (NSArray*) completionPair:(NSString*) lhs{
    if(![self isCompletionPair:lhs]) return nil;
    if([lhs isEqualToString:@"("]) { return @[@"()", @"1"];};
    if([lhs isEqualToString:@"["]) { return @[@"[]", @"1"];};
    if([lhs isEqualToString:@"\""]) { return @[@"\"\"", @"1"];};
    if([lhs isEqualToString:@"'"]) { return @[@"''", @"1"];};
    if([lhs isEqualToString:@"{"]) {
        NSMutableString* toInsert = [NSMutableString stringWithString:@"{"];
        NSString* outerLevelNextline = [self scopedNewline];
        self.scopeLevel++;
        [toInsert appendString:[self scopedNewline]];
        [toInsert appendString:outerLevelNextline];
        [toInsert appendString:@"}"];
        return @[toInsert, [NSString stringWithFormat:@"%d",((self.scopeLevel - 1)*4 + 2)]];;
    };

    return nil;
}

- (Boolean) isCompletionPair:(NSString*) lhs{
    return [self.completionPair containsObject:lhs];
}

- (void) LeaveScope{
    if(self.scopeLevel>0) self.scopeLevel--;
}

- (void) EnterScope{
    self.scopeLevel++;
}

- (NSString*) fixScopeLeft:(NSString*) code
                  from:(NSInteger) leftBrace{
    [self LeaveScope];
    int tomatch = 0;
    NSInteger rightBrace = leftBrace + 1;
    for(NSInteger i = rightBrace; i < [code length]; ++i){
        if([code characterAtIndex:i] == '}'){
            if(tomatch) tomatch--;
            else {rightBrace = i; break;}
        }
        if([code characterAtIndex:i] == '{'){
            tomatch++;
        }
    }
    if(rightBrace < 0
       || rightBrace >= [code length]
       || [code characterAtIndex:rightBrace] != '}') return nil;
    
    return [self fixScopeFrom:leftBrace to:rightBrace of:code];
}

- (NSString*) fixScopeRight:(NSString*) code
                      from:(NSInteger) rightBrace{
    NSInteger leftBrace = rightBrace - 1;
    int tomatch = 0;
    for(NSInteger i = leftBrace; i >= 0; --i){
        if([code characterAtIndex:i] == '{'){
            if(tomatch) tomatch--;
            else {leftBrace = i; break;}
        }
        if([code characterAtIndex:i] == '}'){
            tomatch++;
        }
    }
    if(leftBrace < 0
       || leftBrace >= [code length]
       || [code characterAtIndex:leftBrace] != '{') return nil;
    
    return [self fixScopeFrom:leftBrace to:rightBrace of:code];
}

- (NSString* ) fixScopeFrom:(NSInteger) leftBrace
                         to:(NSInteger) rightBrace
                         of:(NSString*) code{
    NSMutableString* target = [NSMutableString stringWithString:code];
    [target replaceOccurrencesOfString:@"{"
                            withString:@""
                               options:nil
                                 range:NSMakeRange(leftBrace, 1)];
    [target replaceOccurrencesOfString:@"\n    "
                            withString:@"\n"
                               options:nil
                                 range:NSMakeRange(leftBrace, rightBrace - leftBrace-([code length] - [target length]))];
    [target replaceOccurrencesOfString:@"}"
                            withString:@""
                               options:nil
                                 range:NSMakeRange(rightBrace-([code length] - [target length]), 1)];
    return target;
}

-(UITextPosition*) cursor:(UITextView*) codes
                     with:(NSInteger) offset{
    UITextRange* selected = [codes selectedTextRange];
    if(selected){
        UITextPosition* cur = [codes
                               positionFromPosition:selected.start
                               offset:offset];
        if(cur){
            return cur; //[codes textInRange:range];
        }
    }
    return nil;
}

-(NSString*) prevChar:(UITextView*) codes{
    UITextPosition* prevCursor = [self cursor:codes with:-1];
    if(prevCursor){
        UITextRange *range = [codes
                              textRangeFromPosition:prevCursor
                              toPosition:[codes selectedTextRange].start];
        return [codes textInRange:range];
    }
    return nil;
}

//cursor control:
//the value cur cursor will be [0... textlength], where
//the last value indicates the cursor is at the end of the text
//value is the index to the right of the actual cursor
- (NSInteger) OffsetToLineOffset:(NSInteger) offset
                            code:(UITextView*) codes{
    NSInteger CurrentLineCursor = [codes offsetFromPosition:codes.beginningOfDocument
                                                 toPosition:[codes selectedTextRange].start];
    NSInteger target = CurrentLineCursor;
    NSInteger PrevLineEnd = CurrentLineCursor - 1;
    NSString* text = codes.text;
    while(PrevLineEnd >= 0 && [text characterAtIndex:PrevLineEnd]!='\n'){
        --PrevLineEnd;
    }
    NSInteger LineOffset = CurrentLineCursor - PrevLineEnd - 1;

    if(offset > 0){
        for(NSInteger i = CurrentLineCursor; i <= [text length]; ++i){
            if(i < [text length] && [text characterAtIndex:i] == '\n' ){
                offset--;
            }
            if(offset == 0 || i == [text length]){
                target = MIN(i+1, (NSInteger)[text length]); break;
            }
        }
    }else{
        offset--;
        for(NSInteger i = CurrentLineCursor - 1; i >= 0; --i){
            if([text characterAtIndex:i] == '\n' ){
                offset++;
            }
            if(offset == 0 || i == 0){
                target = i+1; break;
            }
        }
    }
    for(NSInteger i = target; i <= [text length]; ++i){
        if(i == [text length] || [text characterAtIndex:i] == '\n'){
            LineOffset = MIN(LineOffset, i - target);
            break;
        }
    }
       
    return (target - CurrentLineCursor) + LineOffset;
}

- (NSInteger) OffsetToPrevLine:(UITextView*) codes{
    return [self OffsetToLineOffset:-1 code:codes];
    
}

- (NSInteger) OffsetToNextLine:(UITextView*) codes{
    return [self OffsetToLineOffset:1 code:codes];
}

@end
