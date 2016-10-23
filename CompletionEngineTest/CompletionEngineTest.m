//
//  CompletionEngineTest.m
//  CompletionEngineTest
//
//  Created by Junlong Gao on 10/22/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../Programming_Keyboard/CompletionEngine.h"

@interface CompletionEngineTest : XCTestCase
@property (nonatomic, strong) CompletionEngine* completionEngine;
@property (nonatomic, strong) UITextView* codes;

@end

@implementation CompletionEngineTest

- (void)setUp {
    [super setUp];
    self.completionEngine = [[CompletionEngine alloc] initWithDemo];
    self.codes = [UITextView new];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
}

- (void)testCompletionSmoke1 {
    [self.completionEngine inputPressed:@"a" textField:self.codes];
    XCTAssert([self.codes.text isEqualToString:@"a"]);
    [self.completionEngine inputPressed:@"BackSpace" textField:self.codes];
    XCTAssert([self.codes.text isEqualToString:@""]);
}

@end
