//
//  AppDelegate.m
//  PlistArchiver
//
//  Created by Nice Robin on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "NSData+AES256.h"

@interface FileInputView : NSBox
@property(nonatomic,assign)id<FileInputViewDelegate>delegate;
@end

@implementation FileInputView
@synthesize delegate;
-(id)initWithFrame:(NSRect)frameRect{
    if (self = [super initWithFrame:frameRect]) {
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    }
    return self;
}
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
	NSPasteboard *pboard = [sender draggingPasteboard];
	NSDragOperation sourceDragMask = [sender draggingSourceOperationMask];
        
	if ([[pboard types] containsObject:NSFilenamesPboardType]) {
		if (sourceDragMask & NSDragOperationLink) {
			return NSDragOperationLink;
		}
	}
	return NSDragOperationNone;
}
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
	NSPasteboard *pboard = [sender draggingPasteboard];
        
	if ([sender draggingSource] != self) {
		if ([[pboard types] containsObject:NSFilenamesPboardType]) {
			NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
            [delegate dropOver:files];
		}
	}
	return YES;
}
@end

@implementation AppDelegate
@synthesize input;
@synthesize output;
@synthesize drop;
@synthesize window = _window;
- (void)dealloc
{
    [fileNames release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    drop.delegate = self;
    processing = NO;
}
-(void)dropOver:(NSArray *)info{
    if (processing) {
        return;
    }
    fileNames = [info retain];
    NSMutableString *str = [[NSMutableString alloc] initWithCapacity:500];
    for (NSString *filepath in fileNames) {
        filepath = [filepath lastPathComponent];
        if ([filepath length] >= 12) {
            filepath = [NSString stringWithFormat:@"%@...%@",[filepath substringToIndex:8], [filepath pathExtension]];
        }
        [str appendFormat:@"%@\n",filepath];
    }
    [input setStringValue:str];
    [str release];
}
-(void)processCore{
    NSUInteger pointer = 0;
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:1000];
    NSMutableString *config = [[NSMutableString alloc] initWithCapacity:500];
    for (NSString *filepath in fileNames) {
        NSData *temp = [NSData dataWithContentsOfFile:filepath];
        [data appendData:temp];
        
        NSString *purename = [[[filepath lastPathComponent] stringByDeletingPathExtension] uppercaseString];
        [config appendFormat:@"#define arch_%@ NSMakeRange(%ld, %ld)\n",purename,pointer,[temp length]];
        pointer += [temp length];
    }
    NSString *savePath = [[fileNames objectAtIndex:0] stringByDeletingLastPathComponent];
    [data writeToFile:[NSString stringWithFormat:@"%@/info.ifs",savePath] atomically:YES];
    [config writeToFile:[NSString stringWithFormat:@"%@/info.txt",savePath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    [data release];
    [config release];
    
    [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];
}
-(void)processCore2{
    NSUInteger pointer = 0;
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:1000];
    NSMutableString *config = [[NSMutableString alloc] initWithCapacity:500];
    [config appendString:@"Encryption\n"];
    for (NSString *filepath in fileNames) {
        NSData *temp = [NSData dataWithContentsOfFile:filepath];
        [data appendData:temp];
        
        NSString *purename = [[[filepath lastPathComponent] stringByDeletingPathExtension] uppercaseString];
        [config appendFormat:@"#define arch_%@ NSMakeRange(%ld, %ld)\n",purename,pointer,[temp length]];
        pointer += [temp length];
    }
    
    NSString *savePath = [[fileNames objectAtIndex:0] stringByDeletingLastPathComponent];
    NSData *data2 = [data AES256EncryptWithKey:@"abc"]; 
    
    [data2 writeToFile:[NSString stringWithFormat:@"%@/data",savePath] atomically:YES];
    [config writeToFile:[NSString stringWithFormat:@"%@/data.txt",savePath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    [data release];
    [config release];
    
    [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];
}
-(void)processDone{
    output.backgroundColor = [NSColor greenColor];
    output.stringValue = @"Done...";
    processing = NO;
}
- (IBAction)process:(id)sender{
    processing = YES;
    output.backgroundColor = [NSColor redColor];
    output.stringValue = @"Processing...";
    [self performSelectorInBackground:@selector(processCore) withObject:nil];
}
- (IBAction)processEncryption:(id)sender{
    processing = YES;
    output.backgroundColor = [NSColor redColor];
    output.stringValue = @"Processing...";
    [self performSelectorInBackground:@selector(processCore2) withObject:nil];
}
@end
