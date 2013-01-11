//
//  KLNoteViewController.m
//  KLNoteController
//
//  Created by Kieran Lafferty on 2012-12-29.
//  Copyright (c) 2012 Kieran Lafferty. All rights reserved.
//

#import "KLNoteViewController.h"
#import <QuartzCore/QuartzCore.h>

//Layout properties
//相对于前一张卡片的缩放比例
#define kDefaultMinimizedScalingFactor 0.98     //Amount to shrink each card from the previous one
//最大缩放比例
#define kDefaultMaximizedScalingFactor 1.00     //Maximum a card can be scaled to
//定义卡片之间的导航条重叠部分的比例
#define kDefaultNavigationBarOverlap 0.90       //Defines vertical overlap of each navigation toolbar. Slight hack that prevents rounding errors from showing the whitespace between navigation toolbars. Can be customized if require more/less packing of navigation toolbars

//Animation properties
//定义动画时长
#define kDefaultAnimationDuration 0.3           //Amount of time for the animations to occur

//Position for the stack of navigation controllers to originate at
//定义起始位置
#define kDefaultVerticalOrigin 100              //Vertical origin of the controller card stack. Making this value larger/smaller will make the card shift down/up.
//定义导航条高度
#define kDefaultNavigationControllerToolbarHeight 44 //TODO: remove dependancy on this and get directly from the navigationcontroller itself

//Shadow Properties - Note : Disabling shadows greatly improves performance and fluidity of animations
#define kDefaultShadowEnabled YES//阴影
#define kDefaultShadowColor [UIColor blackColor]//阴影的颜色
#define kDefaultShadowOffset CGSizeMake(0, -5)//阴影偏移量
#define kDefaultShadowRadius 7.0//阴影半径
#define kDefaultShadowOpacity 0.60//阴影透明度

//Corner radius properties
#define kDefaultCornerRadius 5.0//阴影圆角

//Gesture properties
#define kDefaultMinimumPressDuration 0.2

@interface KLNoteViewController ()
//Drawing information for the navigation controllers
- (CGFloat) defaultVerticalOriginForIndex: (NSInteger) index;
- (CGFloat) scalingFactorForIndex: (NSInteger) index;
@end

@implementation KLNoteViewController

- (void)viewDidLoad
{
    
    //Populate the navigation controllers to the controller stack
    [self reloadData];
    
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    [self reloadInputViews];
    
    
}

#pragma Drawing Methods - Used to position and present the navigation controllers on screen

//获得卡片的默认的起始位置
- (CGFloat) defaultVerticalOriginForIndex: (NSInteger) index
{
    //Sum up the shrunken size of each of the cards appearing before the current index
    CGFloat originOffset = 0;
    for (int i = 0; i < index; i ++) {
        CGFloat scalingFactor = [self scalingFactorForIndex: i];
        originOffset += scalingFactor * kDefaultNavigationControllerToolbarHeight * kDefaultNavigationBarOverlap;
    }
    
    //Position should start at kDefaultVerticalOrigin and move down by size of nav toolbar for each additional nav controller
    //NSLog(@"位置:%d,%f",index,kDefaultVerticalOrigin + originOffset);
    return kDefaultVerticalOrigin + originOffset;
}

//计算卡片缩放因子
- (CGFloat) scalingFactorForIndex: (NSInteger) index {
    //Items should get progressively smaller based on their index in the navigation controller array
    //double pow(double x, double y）;计算以x为底数的y次幂
    //float powf(float x, float y); 功能与pow一致，只是输入与输出皆为浮点数
    return  powf(kDefaultMinimizedScalingFactor, (totalCards - index));
}

//重新加载卡片
- (void) reloadData {
    //Get the number of navigation  controllers to expect
    totalCards = [self numberOfControllerCardsInNoteView:self];
    
    //For each expected controller grab from the instantiating class and populate into local controller stack
    NSMutableArray* navigationControllers = [[NSMutableArray alloc] initWithCapacity: totalCards];
    for (NSInteger count = 0; count < totalCards; count++) {
        UIViewController* viewController = [self noteView:self viewControllerForRowAtIndexPath:[NSIndexPath indexPathForRow:count inSection:0]];
        
        UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        
        KLControllerCard* noteContainer = [[KLControllerCard alloc] initWithNoteViewController: self
                                                                          navigationController: navigationController
                                                                                         index:count];
        [noteContainer setDelegate: self];
        [navigationControllers addObject: noteContainer];
        
        //Add the top view controller as a child view controller
        //ios5新增API方法，将子视图控制器加入内存
        //[self addChildViewController: navigationController];
        
        
        //As child controller will call the delegate methods for UIViewController
        //[navigationController didMoveToParentViewController: self];
        
        //Add as child view controllers
    }
    
    self.controllerCards = [NSArray arrayWithArray:navigationControllers];
}

//当成为第一响应者时调用
- (void) reloadInputViews {
    
    [super reloadInputViews];
    
    //First remove all of the navigation controllers from the view to avoid redrawing over top of views
    [self removeNavigationContainersFromSuperView];
    
    //Add the navigation controllers to the view
    for (KLControllerCard* container in self.controllerCards) {
        [self.view addSubview:container];
    }
}

#pragma mark - Manage KLControllerCard helpers

-(void) removeNavigationContainersFromSuperView {
    for (KLControllerCard* navigationContainer in self.controllerCards) {
        [navigationContainer.navigationController willMoveToParentViewController:nil];  // 1
        [navigationContainer removeFromSuperview];            // 2
    }
}

//获得卡片位置
- (NSIndexPath*) indexPathForControllerCard: (KLControllerCard*) navigationContainer {
    NSInteger rowNumber = [self.controllerCards indexOfObject: navigationContainer];
    
    return [NSIndexPath indexPathForRow:rowNumber inSection:0];
}

//获得指定卡片上面的所有卡片
- (NSArray*) controllerCardAboveCard:(KLControllerCard*) card {
    NSInteger index = [self.controllerCards indexOfObject:card];
    
    return [self.controllerCards filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(KLControllerCard* controllerCard, NSDictionary *bindings) {
        NSInteger currentIndex = [self.controllerCards indexOfObject:controllerCard];
        
        //Only return cards with an index less than the one being compared to
        return index > currentIndex;
    }]];
}

//获得指定卡片下面的所有卡片
- (NSArray*) controllerCardBelowCard:(KLControllerCard*) card {
    NSInteger index = [self.controllerCards indexOfObject: card];
    
    return [self.controllerCards filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(KLControllerCard* controllerCard, NSDictionary *bindings) {
        NSInteger currentIndex = [self.controllerCards indexOfObject:controllerCard];
        
        //Only return cards with an index greater than the one being compared to
        return index < currentIndex;
    }]];
}

#pragma mark - KLNoteViewController Data Source methods

//If the controller is subclassed it will allow these values to be grabbed by the subclass. If not sublclassed it will grab from the assigned datasource.
- (NSInteger)numberOfControllerCardsInNoteView:(KLNoteViewController*) noteView{
    return  [self.dataSource numberOfControllerCardsInNoteView:self];
}

- (UIViewController *)noteView:(KLNoteViewController*)noteView viewControllerForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource noteView:noteView viewControllerForRowAtIndexPath:indexPath];
}

#pragma mark - Delegate implementation for KLControllerCard

-(void) controllerCard:(KLControllerCard*)controllerCard didChangeToDisplayState:(KLControllerCardState) toState fromDisplayState:(KLControllerCardState) fromState {
    
    if (fromState == KLControllerCardStateDefault && toState == KLControllerCardStateFullScreen) {
        
        //For all cards above the current card move them
        for (KLControllerCard* currentCard  in [self controllerCardAboveCard:controllerCard]) {
            [currentCard setState:KLControllerCardStateHiddenTop animated:YES];
        }
        for (KLControllerCard* currentCard  in [self controllerCardBelowCard:controllerCard]) {
            [currentCard setState:KLControllerCardStateHiddenBottom animated:YES];
        }
    }
    else if (fromState == KLControllerCardStateFullScreen && toState == KLControllerCardStateDefault) {
        //For all cards above the current card move them back to default state
        for (KLControllerCard* currentCard  in [self controllerCardAboveCard:controllerCard]) {
            [currentCard setState:KLControllerCardStateDefault animated:YES];
        }
        //For all cards below the current card move them back to default state
        for (KLControllerCard* currentCard  in [self controllerCardBelowCard:controllerCard]) {
            [currentCard setState:KLControllerCardStateHiddenBottom animated:NO];
            [currentCard setState:KLControllerCardStateDefault animated:YES];
        }
    }
    else if (fromState == KLControllerCardStateDefault && toState == KLControllerCardStateDefault){
        //If the current state is default and the user does not travel far enough to kick into a new state, then  return all cells back to their default state
        for (KLControllerCard* cardBelow in [self controllerCardBelowCard: controllerCard]) {
            [cardBelow setState:KLControllerCardStateDefault animated:YES];
        }
    }
    
    //Notify the delegate of the change
    if ([self.delegate respondsToSelector:@selector(controllerCard:didChangeToDisplayState:fromDisplayState:)]) {
        [self.delegate controllerCard:controllerCard
              didChangeToDisplayState:toState fromDisplayState: fromState];
    }
}

-(void) controllerCard:(KLControllerCard*)controllerCard didUpdatePanPercentage:(CGFloat) percentage {
    //NSLog(@"状态%ld",controllerCard.state);
    if (controllerCard.state == KLControllerCardStateFullScreen) {
        for (KLControllerCard* currentCard in [self controllerCardAboveCard: controllerCard]) {
            CGFloat yCoordinate = (CGFloat) currentCard.origin.y * [controllerCard percentageDistanceTravelled];
            //NSLog(@"hello");
            [currentCard setYCoordinate: yCoordinate];
        }
    }
    else if (controllerCard.state == KLControllerCardStateDefault) {  
        for (KLControllerCard* currentCard in [self controllerCardBelowCard: controllerCard]) {
            CGFloat deltaDistance = controllerCard.frame.origin.y - controllerCard.origin.y;
            CGFloat yCoordinate = currentCard.origin.y + deltaDistance;
            //NSLog(@"%f==%f",currentCard.origin.y,yCoordinate);
            [currentCard setYCoordinate: yCoordinate];
        }
    }
}

@end

@interface KLControllerCard ()
//收缩卡片，缩放
-(void) shrinkCardToScaledSize:(BOOL) animated;
//展开卡片，最大化
-(void) expandCardToFullSize:(BOOL) animated;
@end

@implementation KLControllerCard

-(id) initWithNoteViewController: (KLNoteViewController*) noteView navigationController:(UINavigationController*) navigationController index:(NSInteger) _index {
    //Set the instance variables
    index = _index;
    //获得在总视图中的默认位置
    originY = [noteView defaultVerticalOriginForIndex: index];
    self.noteViewController = noteView;
    self.navigationController = navigationController;
    
    if (self = [super initWithFrame: navigationController.view.bounds]) {
        //Initialize the view's properties
        [self setAutoresizesSubviews:YES];//子视图相对父视图自动调整
        [self setAutoresizingMask: UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];//指定只自动调整高度和宽度
        
        [self addSubview: navigationController.view];
        
        //Configure navigation controller to have rounded edges while maintaining shadow
        [self.navigationController.view.layer setCornerRadius: kDefaultCornerRadius];//设置圆角
        [self.navigationController.view setClipsToBounds:YES];
        //Add Pan Gesture 监听平移触摸事件
        UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(didPerformPanGesture:)];
        //Add touch recognizer 监听长按事件
        UILongPressGestureRecognizer* pressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                   action:@selector(didPerformLongPress:)];
        //设置长按时长
        [pressGesture setMinimumPressDuration: kDefaultMinimumPressDuration];
        
        //Add the gestures to the navigationcontrollers navigation bar
        //将事件监听器注册到导航条上
        [self.navigationController.navigationBar addGestureRecognizer: panGesture];
        [self.navigationController.navigationBar addGestureRecognizer:pressGesture];
        
        //Initialize the state to default
        //设置初始化状态
        [self setState:KLControllerCardStateDefault
              animated:NO];
    }
    return self;
}

#pragma mark - UIGestureRecognizer action handlers

-(void) didPerformLongPress:(UILongPressGestureRecognizer*) recognizer {
    NSLog(@"导航条高度：%f",self.navigationController.navigationBar.frame.size.height);
//    if (self.state == KLControllerCardStateDefault && recognizer.state == UIGestureRecognizerStateEnded) {
//        //Go to full size
//        [self setState:KLControllerCardStateFullScreen animated:YES];
//    }
}
//重画阴影
-(void) redrawShadow {
    if (kDefaultShadowEnabled) {
        UIBezierPath *path  =  [UIBezierPath bezierPathWithRoundedRect:[self bounds] cornerRadius:kDefaultCornerRadius];
        [self.layer setShadowOpacity: kDefaultShadowOpacity];
        [self.layer setShadowOffset: kDefaultShadowOffset];
        [self.layer setShadowRadius: kDefaultShadowRadius];
        [self.layer setShadowColor: [kDefaultShadowColor CGColor]];
        [self.layer setShadowPath: [path CGPath]];
    }
}
//触摸移动回调
/*
 1、拍击UITapGestureRecognizer (任意次数的拍击)
 2、向里或向外捏UIPinchGestureRecognizer (用于缩放)
 3、摇动或者拖拽UIPanGestureRecognizer (拖动)
 4、擦碰UISwipeGestureRecognizer (以任意方向)
 5、旋转UIRotationGestureRecognizer (手指朝相反方向移动)
 6、长按UILongPressGestureRecognizer (长按)
 */
-(void) didPerformPanGesture:(UIPanGestureRecognizer*) recognizer {
    CGPoint location = [recognizer locationInView: self.noteViewController.view];
    CGPoint translation = [recognizer translationInView: self];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        //Begin animation
        if (self.state == KLControllerCardStateFullScreen) {
            //Shrink to regular size
            [self shrinkCardToScaledSize:YES];
        }
        //Save the offet to add to the height
        //记录触摸响应时位置
        self.panOriginOffset = [recognizer locationInView: self].y;
        //NSLog(@"======%f===%f",self.panOriginOffset,[recognizer translationInView:self].y);
    }else if (recognizer.state == UIGestureRecognizerStateChanged) {
        //Check if panning downwards and move other cards
        //检测是否有移动量
        //NSLog(@"移动：%f",translation.y);
        if (translation.y > 0){
            //Panning downwards from Full screen state
            if (self.state == KLControllerCardStateFullScreen && self.frame.origin.y < originY) {
                //Notify delegate so it can update the coordinates of the other cards unless user has travelled past the origin y coordinate
                if ([self.delegate respondsToSelector:@selector(controllerCard:didUpdatePanPercentage:)]) {
                    [self.delegate controllerCard:self didUpdatePanPercentage: [self percentageDistanceTravelled]];
                }
            }
            //Panning downwards from default state
            else if (self.state == KLControllerCardStateDefault && self.frame.origin.y > originY) {
                //Implements behavior such that when originating at the default position and scrolling down, all other cards below the scrolling card move down at the same rate
                if ([self.delegate respondsToSelector:@selector(controllerCard:didUpdatePanPercentage:)] ) {
                    [self.delegate controllerCard:self didUpdatePanPercentage: [self percentageDistanceTravelled]];
                }
            }
        }
        
        //Track the movement of the users finger during the swipe gesture
        [self setYCoordinate: location.y - self.panOriginOffset];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        //Check if it should return to the origin location
        if ([self shouldReturnToState: self.state fromPoint: [recognizer translationInView:self]]) {
            [self setState: self.state animated:YES];
        }
        else {
            //Toggle state between full screen and default if it doesnt return to the current state
            [self setState: self.state == KLControllerCardStateFullScreen? KLControllerCardStateDefault : KLControllerCardStateFullScreen
                  animated:YES];
        }
    }
}

#pragma mark - Handle resizing of card

-(void) shrinkCardToScaledSize:(BOOL) animated {
    
    //Set the scaling factor if not already set
    if (!scalingFactor) {
        scalingFactor =  [self.noteViewController scalingFactorForIndex: index];
    }
    //If animated then animate the shrinking else no animation
    if (animated) {
        [UIView animateWithDuration:kDefaultAnimationDuration
                         animations:^{
                             //Slightly recursive to reduce duplicate code
                             [self shrinkCardToScaledSize:NO];
                         }];
    }
    else {
        //CGAffineTransformMakeTranslation(width, 0.0);是改变位置的，
        //CGAffineTransformRotate(transform, M_PI);是旋转的。
        //CGAffineTransformMakeRotation(-M_PI);也是旋转的
        //transform = CGAffineTransformScale(transform, -1.0, 1.0);是缩放的。
        
        [self setTransform: CGAffineTransformMakeScale(scalingFactor, scalingFactor)];
    }
}

-(void) expandCardToFullSize:(BOOL) animated {
    
    //Set the scaling factor if not already set
    if (!scalingFactor) {
        scalingFactor =  [self.noteViewController scalingFactorForIndex: index];
    }
    //If animated then animate the shrinking else no animation
    if (animated) {
        [UIView animateWithDuration:kDefaultAnimationDuration
                         animations:^{
                             //Slightly recursive to reduce duplicate code
                             [self expandCardToFullSize:NO];
                         }];
    }
    else {
        [self setTransform: CGAffineTransformMakeScale(kDefaultMaximizedScalingFactor, kDefaultMaximizedScalingFactor)];
    }
}

#pragma mark - Handle state changes for card
//设置状态
- (void) setState:(KLControllerCardState)state animated:(BOOL) animated{
    if (animated) {
        [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
            [self setState:state animated:NO];
        }];
        return;
    }
    if (state == KLControllerCardStateFullScreen) {
        [self expandCardToFullSize: animated];
        [self setYCoordinate: 0];
    }
    //Default State
    else if (state == KLControllerCardStateDefault) {
        [self shrinkCardToScaledSize: animated];
        [self setYCoordinate: originY];
    }
    //Hidden State - Bottom
    else if (state == KLControllerCardStateHiddenBottom) {
        //Move it off screen and far enough down that the shadow does not appear on screen
        [self setYCoordinate: self.noteViewController.view.frame.size.height + abs(kDefaultShadowOffset.height)*3];
    }
    //Hidden State - Top
    else if (state == KLControllerCardStateHiddenTop) {
        [self setYCoordinate: 0];
    }
    
    //Notify the delegate of the state change (even if state changed to self)
    KLControllerCardState lastState = self.state;
    //Update to the new state
    [self setState:state];
    //Notify the delegate
    if ([self.delegate respondsToSelector:@selector(controllerCard:didChangeToDisplayState:fromDisplayState:)]) {
        [self.delegate controllerCard:self
              didChangeToDisplayState:state fromDisplayState: lastState];
    }
    
    
}

#pragma mark - Various data helpers
//封装指定y坐标值的坐标结构
-(CGPoint) origin {
    return CGPointMake(0, originY);
}

//计算移动距离原位置的百分比
-(CGFloat) percentageDistanceTravelled {
    return self.frame.origin.y/originY;
}

//Boolean for determining if the movement was sufficient to warrent changing states
//判断手势滑动距离，如果不够则返回原来的装入，否则切换新的状态
-(BOOL) shouldReturnToState:(KLControllerCardState) state fromPoint:(CGPoint) point {
    //NSLog(@"%f",point.y);
    //NSLog(@"===%f,%f,%f",point.y,self.navigationController.navigationBar.frame.size.height,ABS(point.y) - self.navigationController.navigationBar.frame.size.height);
    if (state == KLControllerCardStateFullScreen||state == KLControllerCardStateDefault) {
        return ABS(point.y) < self.navigationController.navigationBar.frame.size.height;
    }
    //    else if (state == KLControllerCardStateDefault){
    //        return point.y > -self.navigationController.navigationBar.frame.size.height;
    //    }
    
    return NO;
}

//设置Y轴坐标
-(void) setYCoordinate:(CGFloat)yValue {
    [self setFrame:CGRectMake(self.frame.origin.x, yValue, self.frame.size.width, self.frame.size.height)];
}
//设置Frame
-(void) setFrame:(CGRect)frame {
    [super setFrame: frame];
    [self redrawShadow];
}

@end
