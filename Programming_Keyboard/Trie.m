//
//  Trie.m
//  Programming_Keyboard
//
//  Created by Junlong Gao on 10/14/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Trie.h"


@implementation Trie

// designated initializer, initializes our array of children and sets the key
- (id) initWithKey:(char)key{
    if(self = [super init]){
        self.value = nil;
        self.key = key;
        self.children = [NSMutableDictionary new];
    }
    return self;
}

- (void) addWord:(NSString *)word
           sofar:(NSString *) path{
    // no more characters left, this is our base case
    // path is the actual word
    if(! word.length){
        self.value = path;
        return;
    }
    NSString* next = [word substringToIndex:1];
    Trie *childToUse = [self.children objectForKey:next];
    if(!childToUse){
        childToUse = [[Trie alloc] initWithKey:[next characterAtIndex:0]];
        [self.children setObject:childToUse
                          forKey:next];
        childToUse.p = self;
    }
    // we now have a node, add the rest of the word into our trie recursively
    [childToUse addWord:[word substringFromIndex:1]
                  sofar:path];
}

- (NSMutableArray<NSString *> *) collect{
    NSMutableArray* q = [NSMutableArray new];
    NSMutableArray* ret = [NSMutableArray new];
    [q addObject:self];
    while ([q count] > 0) {
        Trie* top = [q objectAtIndex:0];
        [q removeObjectAtIndex:0];
        if(top.value != nil){
            [ret addObject:top.value];
        }
        for(Trie* key in top.children){
            [q addObject:[top.children objectForKey:key] ];
            
        }
    }
    return ret;
}

@end
