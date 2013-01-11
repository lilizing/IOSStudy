//
//  NoteCard.h
//  note_test
//
//  Created by lili on 13-1-9.
//  Copyright (c) 2013年 lili. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NoteCardContainerVC;
@protocol NoteCardDelegate;
@class NoteCard;

//状态枚举
enum {
    NoteCardStateHiddenBottom,    //隐藏到底部
    NoteCardStateHiddenTop,       //隐藏到顶部
    NoteCardStateDefault,         //默认
    NoteCardStateFullScreen       //最大化
};
typedef UInt32 NoteCardState;

//笔记本委托
@protocol NoteCardDelegate <NSObject>

-(void)noteCard:(NoteCard *)noteCard didUpdateToState:(NoteCardState)state fromState:(NoteCardState)fromState;

-(void)noteCard:(NoteCard *)noteCard didUpdatePanPercentage:(CGFloat)percentage;

@end

//笔记本类
@interface NoteCard : UIView
{
    @private
    CGFloat originY;//初始y坐标位置
    CGFloat scalingFactor;//缩放因子
    NSInteger index;//在容器中的索引
}

@property(strong,nonatomic)UINavigationController *navigationController;//为卡片视图关联一个导航控制器
@property(strong,nonatomic)NoteCardContainerVC *containerVC;//放置卡片的容器控制器
@property(strong,nonatomic)id<NoteCardDelegate> delegate;//委托
@property(nonatomic)NoteCardState state;//卡片状态
@property (nonatomic) CGFloat panOriginOffset;//拖动偏移量

//为卡片指定一个导航控制器，因为一个卡片被打开后应该有多级视图，可以通过导航控制器来控制
-(id)initWithNavigationController:(UINavigationController *)nagCtr noteCardContainerVC:(NoteCardContainerVC *)containerVC index:(NSInteger) index;
//改变状态
- (void)setState:(NoteCardState)state animated:(BOOL) animated;
//设置Y轴坐标
-(void)setYCoordinate:(NSInteger)yValue;
//计算移动距离百分比
-(CGFloat)percentageDistanceMoved;

-(CGPoint)origin;

@end
