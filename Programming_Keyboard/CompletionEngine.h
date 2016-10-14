//
//  CompletionEngine.h
//  Programming_Keyboard
//
//  Created by Junlong Gao on 10/14/16.
//  Copyright © 2016 fingerWizards. All rights reserved.
//

#ifndef CompletionEngine_h
#define CompletionEngine_h
#import <UIKit/UIKit.h>

@interface CompletionEngine : NSObject

@end
/*
the completion engine is responsible for 
 (1) consuming schema and internally store a trie
 (2) a simple interface to travel through the trie
 (3) dump the list of all word with the current prefix
*/

#endif /* CompletionEngine_h */
