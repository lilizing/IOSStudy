//
//  NoteCard.m
//  note_test
//
//  Created by lili on 13-1-9.
//  Copyright (c) 2013年 lili. All rights reserved.
//

#import "NoteCard.h"
#import<QuartzCore/QuartzCore.h>
#import "NoteCardContainerVC.h"

#define kDefaultCornerRadius 5.0//默认圆角尺寸
#define kDefaultAnimationDuration 0.3//定义动画时长
#define kDefaultMaximizedScalingFactor 1.0//定义最大缩放比例
#define kDefaultShadowEnabled YES//开启阴影效果
#define kDefaultShadowColor [UIColor redColor]//阴影的颜色
#define kDefaultShadowOffset CGSizeMake(0, -5)//阴影偏移量
#define kDefaultShadowRadius 7.0//阴影半径
#define kDefaultShadowOpacity 0.60//阴影透明度

@interface NoteCard()
//收缩卡片，缩放
-(void) shrinkCardToScaledSize:(BOOL) animated;
//展开卡片，最大化
-(void) expandCardToFullSize:(BOOL) animated;
@end

@implementation NoteCard

-(id)initWithNavigationController:(UINavigationController *)nagCtr noteCardContainerVC:(NoteCardContainerVC *)containerVC index:(NSInteger) _index
{
    
    
    index = _index;
    originY = [containerVC defaultVerticalOriginForIndex:index];
    self.containerVC = containerVC;
    self.navigationController = nagCtr;
    
    //    CGSize a = CGSizeMake(1.0, 2.0);
    //    size = a;
    //    NSLog(@"---%d",(int)&a);
    //    NSLog(@"---%d",(int)&size);
    
    if(self=[super initWithFrame:self.navigationController.view.bounds])
    {
        //设置自动调整子视图的高度宽度
        [self setAutoresizesSubviews:YES];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        
        //将导航控制器的根视图加入到当前视图中
        [self addSubview:self.navigationController.view];
        //DebugLog(@"导航条高度：%f",self.navigationController.navigationBar.frame.size.height);
        
        [self.navigationController.view.layer setCornerRadius: kDefaultCornerRadius];//设置圆角
        [self.navigationController.view setClipsToBounds:YES];
        
        /*
         1、拍击UITapGestureRecognizer (任意次数的拍击)
         2、向里或向外捏UIPinchGestureRecognizer (用于缩放)
         3、摇动或者拖拽UIPanGestureRecognizer (拖动)
         4、擦碰UISwipeGestureRecognizer (以任意方向)
         5、旋转UIRotationGestureRecognizer (手指朝相反方向移动)
         6、长按UILongPressGestureRecognizer (长按)
         */
        //长按
        UILongPressGestureRecognizer *pressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
        [pressGesture setMinimumPressDuration:0.2];
        
        
        //滑动
        UIPanGestureRecognizer *tapGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        
        [self.navigationController.navigationBar addGestureRecognizer:pressGesture];
        [self.navigationController.navigationBar addGestureRecognizer:tapGesture];
        
        [self setState:NoteCardStateDefault animated:NO];
    }
    return self;
}

- (void) setState:(NoteCardState)state animated:(BOOL) animated{
    if(animated){
        [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
            [self setState:state animated:NO];//通过递归方式，来重用代码
        }];
        return;
    }
    if (state == NoteCardStateFullScreen) {
        [self expandCardToFullSize: animated];
        [self setYCoordinate: 0];
    }else if (state == NoteCardStateDefault) {
        [self shrinkCardToScaledSize: animated];
        [self setYCoordinate: originY];
    }else if(state == NoteCardStateHiddenTop){//隐藏到顶部
        [self setYCoordinate:0];
    }else if(state == NoteCardStateHiddenBottom){//隐藏到底部
        [self setYCoordinate:self.containerVC.view.frame.size.height + abs(kDefaultShadowOffset.height)*3];
    }
    NoteCardState fromState = self.state;
    self.state = state;
    if([self.delegate respondsToSelector:@selector(noteCard:didUpdateToState:fromState:)]){
        [self.delegate noteCard:self didUpdateToState:self.state fromState:fromState];
    }
}

-(CGFloat) percentageDistanceMoved
{
    return self.frame.origin.y/originY;
}

//平移触摸回调
-(void)tapAction:(UIPanGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.containerVC.view];
    CGPoint movedPoint = [recognizer translationInView:self];
    if(recognizer.state == UIGestureRecognizerStateBegan){
        if(self.state == NoteCardStateFullScreen){
            [self shrinkCardToScaledSize:YES];
        }
        self.panOriginOffset = [recognizer locationInView:self].y;
    }else if(recognizer.state == UIGestureRecognizerStateChanged){
        if (movedPoint.y > 0) {
            if((self.state == NoteCardStateFullScreen && self.frame.origin.y < originY)||(self.state == NoteCardStateDefault && self.frame.origin.y > originY)){
                if([self.delegate respondsToSelector:@selector(noteCard:didUpdatePanPercentage:)]){
                    [self.delegate noteCard:self didUpdatePanPercentage:[self percentageDistanceMoved]];
                }
            }
        }
        [self setYCoordinate:location.y - self.panOriginOffset];
    }else if(recognizer.state == UIGestureRecognizerStateEnded){
        if([self shouldReturnToState:self.state movedPoint:[recognizer translationInView:self]]){
            [self setState:self.state animated:YES];
        }else{
            [self setState:self.state == NoteCardStateFullScreen ? NoteCardStateDefault : NoteCardStateFullScreen animated:YES];
        }
        
    }
}

//长按回调
-(void)longPressAction:(UILongPressGestureRecognizer *)recognizer
{
    if(self.state == NoteCardStateDefault &&recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self setState:NoteCardStateFullScreen animated:YES];
    }
}

//设置Y轴坐标
-(void)setYCoordinate:(NSInteger)yValue
{
    [self setFrame:CGRectMake(self.frame.origin.x, yValue, self.frame.size.width, self.frame.size.height)];
}

//设置Frame
-(void) setFrame:(CGRect)frame {
    [super setFrame: frame];
    [self redrawShadow];
}

//画阴影
-(void)redrawShadow
{
    if(kDefaultShadowEnabled){
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:[self bounds] cornerRadius:kDefaultCornerRadius];
        [self.layer setShadowOpacity: kDefaultShadowOpacity];
        [self.layer setShadowOffset: kDefaultShadowOffset];
        [self.layer setShadowRadius: kDefaultShadowRadius];
        [self.layer setShadowColor: [kDefaultShadowColor CGColor]];
        [self.layer setShadowPath: [path CGPath]];
    }
}

//收缩卡片，缩放
-(void) shrinkCardToScaledSize:(BOOL) animated
{
    if (!scalingFactor) {
        scalingFactor =  [self.containerVC scalingFactorForIndex: index];
    }
    if(animated){
        [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
            [self shrinkCardToScaledSize:NO];
        }];
        return;
    }
    [self setTransform:CGAffineTransformMakeScale(scalingFactor, scalingFactor)];
}

//展开卡片，最大化
-(void) expandCardToFullSize:(BOOL) animated
{
    if(animated){
        [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
            [self expandCardToFullSize:NO];
        }];
        return;
    }
    [self setTransform:CGAffineTransformMakeScale(kDefaultMaximizedScalingFactor, kDefaultMaximizedScalingFactor)];
}

//根据移动量判断是否返回当前状态
-(BOOL)shouldReturnToState:(NoteCardState)state movedPoint:(CGPoint)point
{
    if(state == NoteCardStateFullScreen||state == NoteCardStateDefault){
        return ABS(point.y) < self.navigationController.navigationBar.frame.size.height;
    }
    return NO;
}

//封装指定y坐标值的坐标结构
-(CGPoint) origin {
    return CGPointMake(0, originY);
}

@end
