//
//  FunctionalTests.m
//  FunctionalTests
//
//  Created by Junlong Gao on 10/22/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../Programming_Keyboard/Container.h"

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
        NSString *title = [NSString stringWithFormat:@"BackSpace"];
        [sampleButton setTitle:title forState:UIControlStateNormal];
        [self.keyboard setObject:sampleButton forKey:title];
    }
    {
        UIButton *sampleButton = [[UIButton alloc] init];
        NSString *title = [NSString stringWithFormat:@"Enter"];
        [sampleButton setTitle:title forState:UIControlStateNormal];
        [self.keyboard setObject:sampleButton forKey:title];
    }
}

- (void) pressKey:(NSString*) name{
    [self.app keyboardButton:[self.keyboard objectForKey:name]];
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
                               toPosition:[self.app.completionEngine cursor:self.codes with:0]];
}

- (void) moveCursor:(NSInteger) offset{
    if(offset > 0){
        for(int i = 0; i < offset; ++i){
            [self.app moveCursorRight:nil];
        }
    }else{
        for(int i = 0; i < -offset; ++i){
            [self.app moveCursorLeft:nil];
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
    [self pressKey:@"BackSpace"];
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
    
    [self pressKey:@"Enter"];
    [self assertString:@"{\n    {\n        \n        \n    }\n}"];
    XCTAssert([self getIndex] == 25);//wind to correct position
    
    [self pressKey:@"{"];
    [self assertString:@"{\n    {\n        \n        {\n            \n        }\n    }\n}"];
    XCTAssert([self getIndex] == 39);//wind to correct position
    
    [self moveCursor:-13];
    [self pressKey:@"BackSpace"];
    [self assertString:@"{\n    {\n        \n        \n        \n    \n    }\n}"];
    XCTAssert([self getIndex] == 25);//wind to correct position

}

@end
