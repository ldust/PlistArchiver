//
//  main.m
//  ArchiverTest
//
//  Created by Nice Robin on 13-3-25.
//
//

#import <Foundation/Foundation.h>

BOOL notHiddenFile(NSString* path){
    return ![[path lastPathComponent] hasPrefix:@"."];
}
void archiveFolder(NSString *path, NSString *parentKey, NSMutableDictionary *infoDict, NSFileHandle *outputHandle){
    NSRange range = [[infoDict objectForKey:parentKey] rangeValue];
    NSUInteger location = range.location;
    NSUInteger totalSize = range.length;
    NSFileManager *mgr = [NSFileManager defaultManager];
    
    
    for (NSString *item in [mgr contentsOfDirectoryAtPath:path error:nil]) {
        if (notHiddenFile(item)) {
            NSDictionary *attr = [mgr attributesOfItemAtPath:[path stringByAppendingString:item] error:nil];
            if ([[attr objectForKey:NSFileType] isEqualTo:NSFileTypeDirectory]) {
                NSString *subPath = [path stringByAppendingFormat:@"%@/",item];
                NSString *subKey = [parentKey stringByAppendingFormat:@"%@/",item];
                
                NSRange range = NSMakeRange(location, 0);
                [infoDict setObject:[NSValue valueWithRange:range] forKey:subKey];
                archiveFolder(subPath, subKey, infoDict, outputHandle);
                NSUInteger size = [[infoDict objectForKey:subKey] rangeValue].length;
                location += size;
                totalSize += size;
            }else{
                NSString *subPath = [path stringByAppendingString:item];
                NSString *subKey = [parentKey stringByAppendingString:item];
                
                NSData *fileData = [mgr contentsAtPath:subPath];
                [outputHandle writeData:fileData];
                
                NSUInteger fileSize = [fileData length];
                
                NSRange fileRange = NSMakeRange(location, fileSize);
                [infoDict setObject:[NSValue valueWithRange:fileRange] forKey:subKey];
                location += fileSize;
                totalSize += fileSize;
                NSLog(@"add: %@",subKey);
            }
        }
    }
    if (totalSize) {
        [infoDict setObject:[NSValue valueWithRange:NSMakeRange(range.location, totalSize)] forKey:parentKey];
    }else{
        [infoDict removeObjectForKey:parentKey];
        NSLog(@"%@ is an empty folder",path);
    }
    
}
void moreUnarchive(NSString *outPut){
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:outPut];
    NSUInteger pointer = 0;
    
    [handle seekToFileOffset:pointer];
    NSData *ldata = [handle readDataOfLength:sizeof(NSUInteger)];
    NSUInteger l;
    [ldata getBytes:&l range:NSMakeRange(0, sizeof(NSUInteger))];
    
    pointer += sizeof(NSUInteger);
    
    [handle seekToFileOffset:pointer];
    NSData *dictData = [handle readDataOfLength:l];
    NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:dictData];
    pointer += l;
    
    NSArray *positionInfo = [dict objectForKey:@"position.txt"];
    pointer += [[positionInfo objectAtIndex:0] unsignedIntegerValue];
    
    [handle seekToFileOffset:pointer];
    NSData *test = [handle readDataOfLength:[[positionInfo objectAtIndex:1] unsignedIntegerValue]];
    NSString *fnt = [[NSString alloc] initWithData:test encoding:NSASCIIStringEncoding];
    
    //NSLog(@"%@",dict);
}
int main(int argc, const char * argv[]){
    @autoreleasepool {
//        if (argc == 3) {
//            NSString *path = [NSString stringWithCString:argv[1] encoding:NSASCIIStringEncoding];//@"/Users/Ensifix/Desktop/Levels/";
//            NSString *outPut = [NSString stringWithCString:argv[2] encoding:NSASCIIStringEncoding];//@"/Users/Ensifix/Desktop/test.mz";
//            NSString *rootKey = @"/";
//            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:500];
//            [dict setObject:[NSValue valueWithRange:NSMakeRange(0, 0)] forKey:rootKey];
//            
//            NSFileManager *mgr = [NSFileManager defaultManager];
//            if (![mgr fileExistsAtPath:outPut]) {
//                [mgr createFileAtPath:outPut contents:nil attributes:nil];
//            }
//            
//            NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:outPut];
//            
//            archiveFolder(path, rootKey, dict, handle);
//            NSData *dictData = [NSKeyedArchiver archivedDataWithRootObject:dict];
//            [handle writeData:dictData];
//            
//            NSUInteger packSize = [dictData length];
//            [handle writeData:[NSData dataWithBytes:&packSize length:sizeof(NSUInteger)]];
//            NSLog(@"done");
//            [handle closeFile];
//        }
        NSString *outPut = @"/Users/Ensifix/Desktop/test.aa";
        NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:outPut];
        
        unsigned long long offset = [handle seekToEndOfFile];
        [handle seekToFileOffset:offset - sizeof(NSUInteger)];
        NSData *date = [handle readDataOfLength:sizeof(NSUInteger)];
        offset -= sizeof(NSUInteger);
        NSUInteger total;
        [date getBytes:&total range:NSMakeRange(0, sizeof(NSUInteger))];
        NSLog(@"%lu",total);
        
        [handle seekToFileOffset:offset - total];
        NSData *dictData = [handle readDataOfLength:total];
        NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:dictData];
        NSLog(@"%@",dict);
        
        NSRange range = [[dict objectForKey:@"/z.txt"] rangeValue];
        [handle seekToFileOffset:range.location];
        NSData *data = [handle readDataOfLength:range.length];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",string);

    
    }
    return 0;
}















