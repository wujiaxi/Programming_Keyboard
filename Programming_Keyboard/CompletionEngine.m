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


//current state is a list of trie node representing the
//set of autocompletions
@property (nonatomic, strong) Trie* currentState;
@end

@implementation CompletionEngine

- (id) initWithArray:(NSArray *) schema{
    if(self = [super init]){
        NSLog(@"init with array");
        self.limit = 1;
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
    NSArray *sample = @[@"vector<int>",
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
@end
