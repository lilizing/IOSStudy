//
//  MD5Test.m
//  IOSStudy
//
//  Created by lili on 13-1-14.
//  Copyright (c) 2013年 lili. All rights reserved.
//

#import "MD5Test.h"

@implementation MD5Test
-(void)testMD5
{
    NSString *pw = @"I love you";
    DebugLog(@"加密后结果：%@",[pw md5]);
    STAssertEqualObjects(@"E4F58A805A6E1FD0F6BEF58C86F9CEB3", [pw md5], @"md5加密结果不正确");
}
@end
