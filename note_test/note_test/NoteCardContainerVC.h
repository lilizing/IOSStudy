//
//  NoteCardContainerVC.h
//  note_test
//
//  Created by lili on 13-1-9.
//  Copyright (c) 2013年 lili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteCard.h"

@protocol NoteCardContainerDataSource;
@protocol NoteCardContainerDelegate;
@class NoteCardContainerVC;

//笔记本容器控制器数据源委托
@protocol NoteCardContainerDataSource <NSObject>

//返回笔记本个数
-(NSInteger)numberOfNoteCards;

//返回笔记本根视图控制器
-(UIViewController *)noteCardRootVCForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol NoteCardContainerDelegate <NSObject>

-(void)noteCard:(NoteCard *)noteCard didUpdateToState:(NoteCardState)state fromState:(NoteCardState)fromState;

@end

//卡片容器控制器，实现卡片委托
@interface NoteCardContainerVC : UIViewController<NoteCardDelegate>
{
    NSInteger totalCards;
}

@property(strong,nonatomic) NSArray *noteCards;

@property(assign,nonatomic) id<NoteCardContainerDataSource> dataSource;//数据源

@property(assign,nonatomic) id<NoteCardContainerDelegate> delegate;

-(CGFloat)defaultVerticalOriginForIndex:(NSInteger)index;
-(CGFloat)scalingFactorForIndex:(NSInteger)index;
@end


