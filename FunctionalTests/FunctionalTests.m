//
//  FunctionalTests.m
//  FunctionalTests
//
//  Created by Junlong Gao on 10/22/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIGestureRecognizerSubclass.h> //set state to be writable

#import "Catagories.h"



@interface FunctionalTests : XCTestCase
@property (nonatomic, strong) Container* app;
@property (nonatomic, strong) UITextView* codes;
@property (nonatomic, strong) NSMutableDictionary* keyboard;
@end

@implementation FunctionalTests

- (void)setUp {
    [super setUp];
    self.app = [Container new];
    [self.app viewDidLoad];
    self.codes = [UITextView new];
    self.app.codes = self.codes;
    self.app.completionEngine = [[CompletionEngine alloc] initWithDemo];
    self.keyboard = [NSMutableDictionary new];
    for(int c = 0; c < 256; ++c){
        UIButton *sampleButton = [[UIButton alloc] init];
        NSString *title = [NSString stringWithFormat:@"%c", (char)c];
        [sampleButton setTitle:title forState:UIControlStateNormal];
        [self.keyboard setObject:sampleButton forKey:title];
    }
    {
        UIButton *sampleButton = [[UIButton alloc] init];
        NSString *title = [NSString stringWithFormat:BACKSPACE];
        [sampleButton setTitle:title forState:UIControlStateNormal];
        [self.keyboard setObject:sampleButton forKey:title];
    }
    {
        UIButton *sampleButton = [[UIButton alloc] init];
        NSString *title = [NSString stringWithFormat:ENTER];
        [sampleButton setTitle:title forState:UIControlStateNormal];
        [self.keyboard setObject:sampleButton forKey:title];
    }
}

- (void) pressKey:(NSString*) name{
    if([name isEqualToString:BACKSPACE]){
        [self.app BackSpaceButton:nil]; return;
    }
    UILongPressGestureRecognizer *trigger = [UILongPressGestureRecognizer  new];
    UIButton* sender = [self.keyboard objectForKey:name];
    [sender addGestureRecognizer:trigger];
    trigger.state = UIGestureRecognizerStateBegan;
    [self.app keyboardButton:trigger];
}

- (void) assertString:(NSString*) target{
    NSLog(@"\n%@", self.app.codes.text);
    XCTAssert([self.app.codes.text isEqualToString:target]);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (NSInteger) getIndex{
    return [self.codes offsetFromPosition:self.codes.beginningOfDocument
                          toPosition:[self.codes selectedTextRange].start];
}

- (void) moveCursor:(NSInteger) offset{
    if(offset > 0){
        for(int i = 0; i < offset; ++i){
            [self.app MoveCursorRight:nil];
        }
    }else{
        for(int i = 0; i < -offset; ++i){
            [self.app MoveCursorLeft:nil];
        }
    }
}

- (void)testSampleInput {
    [self pressKey:@"a"];
    [self assertString:@"a"];
}

- (void)testSampleScope {
    [self pressKey:@"{"];
    [self assertString:@"{\n    \n}"];
    XCTAssert([self getIndex] == 6);//wind to correct position
    
    [self moveCursor:2];
    [self pressKey:BACKSPACE];
    [self assertString:@"\n\n"];
    XCTAssert([self getIndex] == 2);//wind to correct position
    
    [self pressKey:@"{"];
    [self assertString:@"\n\n{\n    \n}"];
    XCTAssert([self getIndex] == 8);//wind to correct position
    
    [self pressKey:@"{"];
    [self assertString:@"\n\n{\n    {\n        \n    }\n}"];
    XCTAssert([self getIndex] == 18);//wind to correct position
}

- (void)testDeletingInnerScope {
    [self pressKey:@"{"];
    [self assertString:@"{\n    \n}"];
    XCTAssert([self getIndex] == 6);//wind to correct position
    
    [self pressKey:@"{"];
    [self assertString:@"{\n    {\n        \n    }\n}"];
    XCTAssert([self getIndex] == 16);//wind to correct position
    
    [self pressKey:ENTER];
    [self assertString:@"{\n    {\n        \n        \n    }\n}"];
    XCTAssert([self getIndex] == 25);//wind to correct position
    
    [self pressKey:@"{"];
    [self assertString:@"{\n    {\n        \n        {\n            \n        }\n    }\n}"];
    XCTAssert([self getIndex] == 39);//wind to correct position
    
    [self moveCursor:-13];
    [self pressKey:BACKSPACE];
    [self assertString:@"{\n    {\n        \n        \n        \n    \n    }\n}"];
    XCTAssert([self getIndex] == 25);//wind to correct position

}

- (void)testMovingUp {
    [self pressKey:@"{"];
    [self assertString:@"{\n    \n}"];
    XCTAssert([self getIndex] == 6);//wind to correct position
    
    [self.app MoveCursorUp:nil];
    XCTAssert([self getIndex] == 1);
    
    [self.app MoveCursorDown:nil];
    XCTAssert([self getIndex] == 3);
}

- (void) testSimpleMoveUp {
    [self pressKey:@"a"];
    [self pressKey:ENTER];
    [self pressKey:@"b"];
    XCTAssert([self getIndex] == 3);
    
    [self.app MoveCursorLeft:nil];
    XCTAssert([self getIndex] == 2);

    [self.app MoveCursorUp:nil];
    XCTAssert([self getIndex] == 0);

}

- (void)testMovingDown {
    [self pressKey:@"{"];
    [self assertString:@"{\n    \n}"];
    XCTAssert([self getIndex] == 6);//wind to correct position
    
    [self.app MoveCursorDown:nil];
    XCTAssert([self getIndex] == 8);
    
    [self.app MoveCursorUp:nil];
    XCTAssert([self getIndex] == 3);
}

- (void)testClearMovingDown {
    [self testMovingDown];
    [self.app Clear:nil];
    [self testMovingDown];
}

@end
