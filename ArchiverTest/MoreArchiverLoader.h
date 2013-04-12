//
//  MoreArchiverLoader.h
//  PlistArchiver
//
//  Created by Nice Robin on 13-4-12.
//
//

#import <Foundation/Foundation.h>

@interface MoreArchiverLoader : NSObject{
    NSDictionary *cache;
}
+(MoreArchiverLoader*)singleton;

-(void)loadPath:(NSString*)path;
-(NSData*)getData:(NSString*)name;

+(void)end;
@end
