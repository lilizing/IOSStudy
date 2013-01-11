//
//  ViewController.m
//  note_test
//
//  Created by lili on 13-1-9.
//  Copyright (c) 2013年 lili. All rights reserved.
//

#import "MainVC.h"

@interface MainVC ()

@end

@implementation MainVC

- (void)viewDidLoad
{
    //设置主控制器背景
    UIImage *image = [UIImage imageNamed:@"default"];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:image]];
    
    //初始化笔记本配置信息
    NSString *plistPath = [[NSBundle mainBundle]pathForResource:@"NavigationControllerData" ofType:@"plist"];
    self.noteCardData = [[NSArray alloc]initWithContentsOfFile:plistPath];
    
    DebugLog(@"笔记本配置信息：%@",self.noteCardData);
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - 数据源方法

-(NSInteger)numberOfNoteCards
{
    return [self.noteCardData count];
}

-(UIViewController *)noteCardRootVCForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [self.noteCardData objectAtIndex:indexPath.row];
    NSString *text = [[NSString alloc]initWithFormat:@"卡片_%d",indexPath.row];
    NoteCardRootVC *vc = [[NoteCardRootVC alloc]initWithNibName:@"NoteCardRootVC" bundle:nil displayText:text];
    vc.info = dict;
    return vc;
}

@end
