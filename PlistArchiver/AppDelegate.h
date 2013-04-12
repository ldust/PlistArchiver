//
//  AppDelegate.h
//  PlistArchiver
//
//  Created by Nice Robin on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class FileInputView;
@protocol FileInputViewDelegate <NSObject>
-(void)dropOver:(NSArray*)info;
@end

@interface AppDelegate : NSObject <NSApplicationDelegate,FileInputViewDelegate>{
    NSArray *fileNames;
    BOOL processing;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *input;
@property (assign) IBOutlet NSTextField *output;
@property (assign) IBOutlet FileInputView *drop;
- (IBAction)process:(id)sender;
- (IBAction)processEncryption:(id)sender;
@end