//
//  main.m
//  trieTest
//
//  Created by Junlong Gao on 10/14/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../Programming_Keyboard/CompletionEngine.h"
bool hasString(NSString* target, NSArray* list){
    for(NSString* s in list){
        if ([s isEqualToString:target]) {
            return true;
        }
    }
    return false;
}

void listEqual(NSArray* list1, NSArray* list2){
    if(list1 == nil || list2 == nil){
        assert((list1==nil) && (list2==nil));
    }
    for(NSString* s in list1){
        assert(hasString(s, list2));
    }
    for(NSString* s in list2){
        assert(hasString(s, list1));
    }
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        //test case 1:
        {
            NSArray *testcase = @[@"vector<int>",
                                  @"vector<string>",
                                  @"unordered_set<string>",
                                  @"unordered_set<int>"];
            CompletionEngine *engine = [[CompletionEngine alloc] initWithArray:testcase];
            //add char
            [engine addChar:@"v"];
            NSArray<NSString*>* rst = [engine dumpList];
            NSArray* expected = @[@"vector<int>",
                                  @"vector<string>"];
            listEqual(rst, expected);
            
            //add more
            [engine addChar:@"e"];
            [engine addChar:@"c"];
            [engine addChar:@"t"];
            [engine addChar:@"o"];
            [engine addChar:@"r"];
            [engine addChar:@"<"];
            [engine addChar:@"i"];
            rst = [engine dumpList];
            expected = @[@"vector<int>"];
            listEqual(rst, expected);
            
            
            [engine popChar];
            rst = [engine dumpList];
            expected = @[@"vector<int>",
                                  @"vector<string>"];
            listEqual(rst, expected);

            expected = nil;
            [engine addChar:@"j"];
            rst = [engine dumpList];
            listEqual(rst, expected);

        }
        NSLog(@"all testcases passed");

    }
    return 0;
}

