//
//  ViewController.h
//  note_test
//
//  Created by lili on 13-1-9.
//  Copyright (c) 2013年 lili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteCardContainerVC.h"
#import "NoteCardRootVC.h"

//主视图控制器继承笔记本容器控制器
@interface MainVC : NoteCardContainerVC<NoteCardContainerDataSource>
@property(strong,nonatomic)NSArray *noteCardData;//笔记本配置信息
@end
