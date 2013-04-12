//
//  NSData+AES256.h
//  PlistArchiver
//
//  Created by Nice Robin on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES256)
-(NSData *)AES256EncryptWithKey:(NSString *)key;
-(NSData *)AES256DecryptWithKey:(NSString *)key;
@end
