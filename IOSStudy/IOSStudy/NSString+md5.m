//
//  NSString+md5.m
//  IOSStudy
//
//  Created by lili on 13-1-14.
//  Copyright (c) 2013年 lili. All rights reserved.
//

#import "NSString+md5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (md5)
- (NSString *) md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash uppercaseString];
}
@end
