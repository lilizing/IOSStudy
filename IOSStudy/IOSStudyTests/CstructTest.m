//
//  CstructTest.m
//  IOSStudy
//
//  Created by lili on 13-1-15.
//  Copyright (c) 2013年 lili. All rights reserved.
//

#import "CstructTest.h"
#include <string.h>
#define STU struct stu
#define LEN sizeof(struct stu)
struct stu{
    int age;
    char *name;
    struct stu *next;
};
@implementation CstructTest

-(void)testStu{
//    struct stu boy = {11,"lili"};
//    struct stu *p = &boy;
//    printf("年龄：%d\n",boy.age);
//    printf("姓名:%s\n",p->name);
//    
//    STU *p1 = (STU*)malloc(LEN);
//    p1 = &boy;
//    printf("动态内存地址：%u\n",p1);
//    free(p1);
//    
//    char *c1 = "lili";
//    char *c2 = " love yoyo";
//    char *pc = (char *)malloc(100);
//    //char *result = c1;
//    assert((c1!=NULL)&&(c2!=NULL));
//    while (*c1!='\0') {
//        printf("结果：%s\n",c1++);
//        
//    }
//    pc = c1;
//    printf("首地址：%d\n",pc);
//    printf("内容：%s\n",pc);
    printf("-1左移7位，结果：%d\n",-1<<8);
}

@end
