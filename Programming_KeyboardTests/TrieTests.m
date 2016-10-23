//
//  Programming_KeyboardTests.m
//  Programming_KeyboardTests
//
//  Created by Junlong Gao on 10/22/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../Programming_Keyboard/CompletionEngine.h"
@interface TrieTests : XCTestCase
@property (nonatomic, strong) NSString* testcases;
@property (nonatomic, strong) CompletionEngine* testObj;
@property (nonatomic, strong) UITextView* codes;

@end


@implementation TrieTests

- (void) list1:(NSArray*) list1
       equalTo:(NSArray*) list2{
    if(list1 == nil || list2 == nil){
        XCTAssert((list1==nil) && (list2==nil));
    }
    for(NSString* s in list1){
        XCTAssert([self hasString:s at:list2]);
    }
    for(NSString* s in list2){
        XCTAssert([self hasString:s at:list1]);
    }
}

- (bool) hasString:(NSString*) target
                at:(NSArray*) list{
    for(NSString* s in list){
        if ([s isEqualToString:target]) {
            return true;
        }
    }
    return false;
}

- (void)setUp {
    [super setUp];
    self.codes = [UITextView new];
    self.testcases = @[@"vector<int>",
                       @"vector<string>",
                       @"unordered_set<string>",
                       @"unordered_set<int>"];
    self.testObj = [[CompletionEngine alloc] initWithArray:_testcases];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTrieSmoke1 {
    [self.testObj addChar:@"v"];
    [self list1:[self.testObj dumpList]
        equalTo:@[@"vector<int>",
                  @"vector<string>"]];
}

- (void)testTrieSmoke2 {
    [self.testObj addChar:@"v"];
    [self.testObj addChar:@"e"];
    [self.testObj addChar:@"c"];
    [self.testObj addChar:@"t"];
    [self.testObj addChar:@"o"];
    [self.testObj addChar:@"r"];
    [self.testObj addChar:@"<"];
    [self.testObj addChar:@"i"];
    
    [self list1:[self.testObj dumpList]
        equalTo:@[@"vector<int>"]];
}

- (void)testTrieSmoke3 {
    [self.testObj addChar:@"v"];
    [self.testObj addChar:@"e"];
    [self.testObj addChar:@"c"];
    [self.testObj addChar:@"t"];
    [self.testObj addChar:@"o"];
    [self.testObj addChar:@"r"];
    [self.testObj addChar:@"<"];
    [self.testObj addChar:@"i"];
    
    NSArray* expected = @[@"vector<int>"];
    [self list1:[self.testObj dumpList] equalTo:expected];
    
    [self.testObj popChar];
    [self list1:[self.testObj dumpList]
        equalTo:@[@"vector<int>",
                  @"vector<string>"]];
}



@end
