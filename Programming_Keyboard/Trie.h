//
//  Trie.h
//  Programming_Keyboard
//
//  Created by Junlong Gao on 10/14/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#ifndef Trie_h
#define Trie_h

@interface Trie:NSObject
//children nodes
@property (nonatomic, strong) NSMutableDictionary *children;

//its key. in our usage it is a char
@property (nonatomic) char key;

//if it is the end node of a word, value will be the
//word, otherwise(it is just a prefix) this will be nil
@property (nonatomic) NSString *value;

//point to its parent
@property (nonatomic, weak) Trie* p;

- (void) addWord:(NSString *)word
           sofar:(NSString *)path;

- (id) initWithKey:(char)key;

- (NSMutableArray<NSString*>*) collect;
@end
#endif /* Trie_h */
