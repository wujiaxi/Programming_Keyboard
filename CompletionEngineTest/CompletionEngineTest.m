//
//  CompletionEngineTest.m
//  CompletionEngineTest
//
//  Created by Junlong Gao on 10/22/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CompletionEngine.h"
#import "Catagories.h"
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

-(void)MoveCursorByOffset:(NSInteger)offset{
    UITextRange* selected = [self.codes selectedTextRange];
    if(selected){
        UITextPosition* next = [self.codes
                                positionFromPosition:selected.start
                                offset:offset];
        if(next){
            self.codes.selectedTextRange = [self.codes textRangeFromPosition:next
                                                                  toPosition:next];
        }
    }
}

- (void)testCompletionSmoke1 {
    [self.completionEngine inputPressed:@"a" textField:self.codes];
    XCTAssert([self.codes.text isEqualToString:@"a"]);
    [self.completionEngine inputPressed:BACKSPACE textField:self.codes];
    XCTAssert([self.codes.text isEqualToString:@""]);
}

- (void)testFindPreviousLineCursor {
    [self.codes insertText:@"\n\n"];
    XCTAssert([self.completionEngine OffsetToNextLine:self.codes] == 0);
    XCTAssert([self.completionEngine OffsetToPrevLine:self.codes] == -1);
}

- (void)testFindNextLineCursor {
    [self.codes insertText:@"\n\n"];
    [self MoveCursorByOffset:-1];
    XCTAssert([self.completionEngine OffsetToNextLine:self.codes] == 1);
    XCTAssert([self.completionEngine OffsetToPrevLine:self.codes] == 0);
}

- (void)testMultipleMotionBack {
    [self.codes insertText:@"b\na\ncdefg\nabc"];
    XCTAssert([self.completionEngine OffsetToPrevLine:self.codes] == -6);
    [self MoveCursorByOffset:-6];
    XCTAssert([self.completionEngine OffsetToPrevLine:self.codes] == -4);
    [self MoveCursorByOffset:-4];
    XCTAssert([self.completionEngine OffsetToPrevLine:self.codes] == -2);
}

- (void)testMultipleMotionForward {
    [self.codes insertText:@"b\na\ncdefg\nabc"];
    XCTAssert([self.completionEngine OffsetToPrevLine:self.codes] == -6);
    [self MoveCursorByOffset:-7];
    XCTAssert([self.completionEngine OffsetToNextLine:self.codes] == 6);
}

- (void)testMotionForwardOverflow {
    [self.codes insertText:@"ab\nb"];
    [self MoveCursorByOffset:-2];
    XCTAssert([self.completionEngine OffsetToNextLine:self.codes] == 2);
}

- (void)testMotionBackwardOverflow {
    [self.codes insertText:@"a\nab"];
    XCTAssert([self.completionEngine OffsetToPrevLine:self.codes] == -3);
}

@end
