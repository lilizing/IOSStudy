//
//  NoteCardContainerVC.m
//  note_test
//
//  Created by lili on 13-1-9.
//  Copyright (c) 2013年 lili. All rights reserved.
//

#import "NoteCardContainerVC.h"

#define kDefaultMinimizedScalingFactor 0.98//默认最小缩放因子
#define kDefaultNavigationControllerToolbarHeight 44//导航条高度
#define kDefaultNavigationBarOverlap 0.90 //非重叠比例
#define kDefaultVerticalOrigin 100 //卡片放置起始位置



@interface NoteCardContainerVC ()

@end

@implementation NoteCardContainerVC

- (void)viewDidLoad
{
	[self reloadData];
    [super viewDidLoad];
    [self reloadInputViews];
}

//重载数据
-(void)reloadData
{
    totalCards = [self numberOfNoteCards];
    NSMutableArray *ncs = [[NSMutableArray alloc]initWithCapacity:totalCards];
    for (NSInteger i=0; i<totalCards; i++) {
        
        UIViewController *vc = [self noteCardRootVCForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        UINavigationController *nagVC = [[UINavigationController alloc]initWithRootViewController:vc];
        
        DebugLog(@"rect NoteCardContainerVC: %@,%@", NSStringFromCGRect(self.view.bounds),NSStringFromCGRect(self.view.frame));
        
        DebugLog(@"rect nagVC默认: %@,%@", NSStringFromCGRect(nagVC.view.bounds),NSStringFromCGRect(nagVC.view.frame));
        
        nagVC.view.frame = self.view.bounds;
        NoteCard *noteCard  = [[NoteCard alloc]initWithNavigationController:nagVC noteCardContainerVC:self index:i];
        
        [noteCard setDelegate:self];
        
        [ncs addObject:noteCard];
        
        //添加子控制器缓存起来
        [self addChildViewController:nagVC];
        [nagVC didMoveToParentViewController:self];
        
    }
    self.noteCards = [NSArray arrayWithArray:ncs];
}


-(void)reloadInputViews
{
    [super reloadInputViews];
    for (NoteCard* card in self.noteCards) {
        [card.navigationController willMoveToParentViewController:nil];
        [card removeFromSuperview];
    }
    for(NoteCard *card in self.noteCards)
    {
        [self.view addSubview:card];
    }
}


//计算卡片默认纵向位置
-(CGFloat)defaultVerticalOriginForIndex:(NSInteger)index
{
    CGFloat originOffset = 0;
    for (int i=0; i<index; i++) {
        CGFloat scalingFactor = [self scalingFactorForIndex:i];
        originOffset += scalingFactor * kDefaultNavigationControllerToolbarHeight * kDefaultNavigationBarOverlap;
    }
    DebugLog(@"位置:%d,%f",index,kDefaultVerticalOrigin + originOffset);
    return kDefaultVerticalOrigin + originOffset;
}

//计算卡片缩放因子
-(CGFloat)scalingFactorForIndex:(NSInteger)index
{
    return powf(kDefaultMinimizedScalingFactor,totalCards-index);
}

#pragma mark - 数据源方法默认实现
//返回笔记本个数
-(NSInteger)numberOfNoteCards
{
    return [self.dataSource numberOfNoteCards];
}

//返回笔记本根视图控制器
-(UIViewController *)noteCardRootVCForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataSource noteCardRootVCForRowAtIndexPath:indexPath];
}


-(NSArray *)noteCardAboveCards:(NoteCard *)noteCard
{
    NSInteger index = [self.noteCards indexOfObject:noteCard];
    __weak NoteCardContainerVC *wself = self;
    return [self.noteCards filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NoteCard *currentCard, NSDictionary *bindings) {
        __strong NoteCardContainerVC *sself = wself;
        NSInteger currentIndex = [sself.noteCards indexOfObject:currentCard];
        return index > currentIndex;
    }]];
}

-(NSArray *)noteCardBottomCards:(NoteCard *)noteCard
{
    NSInteger index = [self.noteCards indexOfObject:noteCard];
    __weak NoteCardContainerVC *wself = self;
    return [self.noteCards filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NoteCard *currentCard, NSDictionary *bindings) {
        __strong NoteCardContainerVC *sself = wself;
        NSInteger currentIndex = [sself.noteCards indexOfObject:currentCard];
        return index < currentIndex;
    }]];
}

#pragma mark - NoteCard委托方法
-(void)noteCard:(NoteCard *)noteCard didUpdateToState:(NoteCardState)state fromState:(NoteCardState)fromState
{
    NSArray *aboveCards = [self noteCardAboveCards:noteCard];
    NSArray *bottomCards = [self noteCardBottomCards:noteCard];
    if(fromState == NoteCardStateDefault && state == NoteCardStateFullScreen){
        for(NoteCard *currentCard in aboveCards){
            [currentCard setState:NoteCardStateHiddenTop animated:YES];
        }
        for(NoteCard *currentCard in bottomCards){
            [currentCard setState:NoteCardStateHiddenBottom animated:YES];
        }
    }else if(fromState == NoteCardStateFullScreen && state == NoteCardStateDefault){
        for(NoteCard *currentCard in aboveCards){
            [currentCard setState:NoteCardStateDefault animated:YES];
        }
        for(NoteCard *currentCard in bottomCards){
            [currentCard setState:NoteCardStateDefault animated:YES];
        }
    }else if(fromState == NoteCardStateDefault && state == NoteCardStateDefault){
        for(NoteCard *currentCard in bottomCards){
            [currentCard setState:NoteCardStateDefault animated:YES];
        }
    }
    if([self.delegate respondsToSelector:@selector(noteCard:didUpdateToState:fromState:)]){
        [self.delegate noteCard:noteCard didUpdateToState:state fromState:fromState];
    }
}

-(void)noteCard:(NoteCard *)noteCard didUpdatePanPercentage:(CGFloat)percentage
{
    if(noteCard.state == NoteCardStateFullScreen){
        NSArray *aboveCards = [self noteCardAboveCards:noteCard];
        for(NoteCard *currentCard in aboveCards){
            CGFloat yCoordicate = currentCard.origin.y * percentage;
            [currentCard setYCoordinate:yCoordicate];
        }
    }else if(noteCard.state == NoteCardStateDefault){
        NSArray *bottomCards = [self noteCardBottomCards:noteCard];
        for(NoteCard *currentCard in bottomCards){
            CGFloat yChange = noteCard.frame.origin.y - noteCard.origin.y;
            CGFloat yCoordicate = currentCard.origin.y + yChange;
            [currentCard setYCoordinate:yCoordicate];
        }
    }
}
@end
