//
//  GCDTest.m
//  IOSStudy
//
//  Created by lili on 13-1-7.
//  Copyright (c) 2013年 lili. All rights reserved.
//

#import "GCDTest.h"

@implementation GCDTest

//dispatch_async 函数会立即返回, block会在后台异步执行
-(void)testDispatch_async
{
    DebugLog(@"----11---");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DebugLog(@"---33---");
    });
    DebugLog(@"----22---");
}

//和dispatch_async相同，但是它会等待block中的代码执行完成并返回
-(void)testDispatch_sync
{
    DebugLog(@"----1---");
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DebugLog(@"---3---");
    });
    DebugLog(@"----2---");
}

-(void)testDispatch_group
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
        //[NSThread sleepForTimeInterval:1];
        sleep(1);
        DebugLog(@"---group1");
    });
    dispatch_group_async(group, queue, ^{
        //[NSThread sleepForTimeInterval:2];
        sleep(2);
        DebugLog(@"---group2");
    });
    dispatch_group_async(group, queue, ^{
        //[NSThread sleepForTimeInterval:3];
        sleep(3);
        DebugLog(@"---group3");
    });
    //__block BOOL flag = YES;
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        DebugLog(@"---updateUi");
        //flag = NO;
    });  
    dispatch_release(group);
    [[NSRunLoop currentRunLoop]run];
   
}

-(void)testDispatch_barrier_async
{
    dispatch_queue_t queue = dispatch_queue_create("gcdtest.rongfzh.yc", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:2];
        DebugLog(@"dispatch_async1");
    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:4];
        DebugLog(@"dispatch_async2");
    });
    dispatch_barrier_async(queue, ^{
        DebugLog(@"dispatch_barrier_async");
        [NSThread sleepForTimeInterval:4];
        
    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        DebugLog(@"dispatch_async3");  
    });
}


@end
