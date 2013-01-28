//
//  FontTest.m
//  IOSStudy
//
//  Created by lili on 13-1-17.
//  Copyright (c) 2013年 lili. All rights reserved.
//

#import "FontTest.h"

@implementation FontTest
-(void)testFonts
{
    for(NSString *familyName in [UIFont familyNames]){
        NSLog(@"Font FamilyName = %@",familyName); //*输出字体族科名字
        
        for(NSString *fontName in [UIFont fontNamesForFamilyName:familyName]){
            NSLog(@"\t%@",fontName);         //*输出字体族科下字样名字
        }
    }
}
@end
