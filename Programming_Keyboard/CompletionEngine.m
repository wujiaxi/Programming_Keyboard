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
                               @[@"(",@")", @"[", @"]", @"\"", @"'"]];
        NSLog(@"init with array");
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
    if(![self completionPair]) return nil;
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
    NSRange searchRange = NSMakeRange(leftBrace, code.length - leftBrace);
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

    NSMutableString* target = [NSMutableString stringWithString:code];
    [target replaceOccurrencesOfString:@"}"
                            withString:@""
                               options:nil
                                 range:NSMakeRange(rightBrace, 1)];
    [target replaceOccurrencesOfString:@"\n    "
                            withString:@"\n"
                               options:nil
                                 range:NSMakeRange(leftBrace, rightBrace - leftBrace - 1)];
    return target;
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
    
    NSMutableString* target = [NSMutableString stringWithString:code];
    [target replaceOccurrencesOfString:@"{"
                            withString:@""
                               options:nil
                                 range:NSMakeRange(leftBrace, 1)];
    [target replaceOccurrencesOfString:@"\n    "
                            withString:@"\n"
                               options:nil
                                 range:NSMakeRange(leftBrace, rightBrace - leftBrace - 1)];
    return target;
}

@end
