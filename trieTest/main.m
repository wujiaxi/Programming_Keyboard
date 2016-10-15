//
//  main.m
//  trieTest
//
//  Created by Junlong Gao on 10/14/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../Programming_Keyboard/CompletionEngine.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSArray *testcase = @[@"vector<int>",
                              @"vector<string>",
                              @"unordered_set<string>",
                              @"unordered_set<int>"];
        CompletionEngine *engine = [[CompletionEngine alloc] initWithArray:testcase];
        [engine addChar:@"v"];
        NSArray<NSString*>* rst = [engine dumpList];
        for(NSString* s in rst){
            NSLog(@"%@", s);
        }
        [engine addChar:@"e"];
        [engine addChar:@"c"];
        [engine addChar:@"t"];
        [engine addChar:@"o"];
        [engine addChar:@"r"];
        [engine addChar:@"<"];
        [engine addChar:@"i"];
        rst = [engine dumpList];
        for(NSString* s in rst){
            NSLog(@"%@", s);
        }
        [engine popChar];
        rst = [engine dumpList];
        for(NSString* s in rst){
            NSLog(@"%@", s);
        }

    }
    return 0;
}
