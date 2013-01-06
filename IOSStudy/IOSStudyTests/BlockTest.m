//
//  BlockTest.m
//  IOSStudy
//
//  Created by lili on 13-1-6.
//  Copyright (c) 2013年 lili. All rights reserved.
//

#import "BlockTest.h"

@implementation BlockTest

//测试block访问局部变量
-(void)testBlock_Local
{
    //基本类型的局部变量
    int intA = 1;
    __block int intB = 1;
    
    //对象类型的局部变量
    A *objA = [[A alloc]init];
    __block A *objB = [[A alloc]init];
    
    objA.name = @"lili";
    
    int a = [objA retainCount];
    
    //NSLog(@"%d",(int)[objA retainCount]);//结果:1
    
    void (^aBlock)(void)=^{
        //intA = 2;//不可被修改，编译不通过
        intB = 2;//__block声明的变量可以被修改
        
        STAssertEquals(1, intA, @"结论：block中会创建局部变量的副本（栈空间副本），何况基本类型本身就是在栈空间，所以外部对intA的修改不影响block中intA的访问结果");
        
        //objA = [[A alloc]init];//不可被修改，编译不通过
        objA.age = 1;//objA不能修改，但是他的成员变量可以修改
        
        objB = [[A alloc]init];//__block声明的对象可以重新赋值（即，可以被修改）
        
        //NSLog(@"%d",(int)[objA retainCount]);//结果:1，由此可见block中引用外部对象类型的局部变量，并未对该对象做retain
        STAssertEquals(a, (int)[objA retainCount], @"结论：block中访问对象类型的局部变量，并未对该对象做retain");
        
        STAssertEquals(@"lili", objA.name, @"结论：block中访问对象类型的局部变量，会重新开辟新的变量栈空间（block中的localA变量是新的一块栈空间），与该局部变量指向同一堆对象，因此外部对该变量重新赋值，不影响block对该局部变量的访问结果");
        
        
    };
    
    aBlock();
    
    intA = 2;
    
    //对objA重新赋值
    objA = [[A alloc]init];
    objA.name = @"tata";
    
    aBlock();
}
@end
