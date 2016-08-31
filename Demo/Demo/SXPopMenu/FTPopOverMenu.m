//
//  FTPopOverMenu.m
//  FTPopOverMenu
//
//  Created by liufengting on 16/4/5.
//  Copyright © 2016年 liufengting ( https://github.com/liufengting ). All rights reserved.
//

#import "FTPopOverMenu.h"

#define KSCREEN_WIDTH               [[UIScreen mainScreen] bounds].size.width
#define KSCREEN_HEIGHT              [[UIScreen mainScreen] bounds].size.height
#define FTBackgroundColor           [UIColor clearColor]
#define FTDefaultTintColor          [UIColor colorWithRed:80/255.f green:80/255.f blue:80/255.f alpha:1.f]
#define FTDefaultTextColor          [UIColor whiteColor]
#define FTDefaultMenuFont           [UIFont systemFontOfSize:14]
#define FTDefaultMenuWidth          100.0
#define FTDefaultMenuIconWidth      20.0
#define FTDefaultMenuRowHeight      40.0
#define FTDefaultMenuArrowHeight    10.0
#define FTDefaultMenuArrowWidth     7.0
#define FTDefaultMenuCornerRadius   4.0
#define FTDefaultMargin             4.0
#define FTDefaultAnimationDuration  0.2

#define FTPopOverMenuTableViewCellIndentifier @"FTPopOverMenuTableViewCellIndentifier"

/**
 *  FTPopOverMenuArrowDirection
 */
typedef NS_ENUM(NSUInteger, FTPopOverMenuArrowDirection) {
    /**
     *  Up
     */
    FTPopOverMenuArrowDirectionUp,
    /**
     *  Down
     */
    FTPopOverMenuArrowDirectionDown,
    /**
     *  None
     */
    FTPopOverMenuArrowDirectionNone,
};

#pragma mark - FTPopOverMenuCell

@interface FTPopOverMenuCell ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *menuNameLabel;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation FTPopOverMenuCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier menuName:(NSString *)menuName iconImageName:(NSString *)iconImageName
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIImage *iconImage;
        if (iconImageName.length) {
            iconImage = [UIImage imageNamed:iconImageName];
        }
        CGFloat margin = (FTDefaultMenuRowHeight - FTDefaultMenuIconWidth)/2;
        CGRect iconImageRect = CGRectMake(margin, margin, FTDefaultMenuIconWidth/4*5, FTDefaultMenuIconWidth);
        CGRect menuNameRect = CGRectMake(FTDefaultMenuRowHeight, margin, FTDefaultMenuWidth - FTDefaultMenuIconWidth - margin, FTDefaultMenuIconWidth);
        if (iconImage) {
            _iconImageView = [[UIImageView alloc]initWithFrame:iconImageRect];
            _iconImageView.backgroundColor = [UIColor clearColor];
            _iconImageView.image = iconImage;
            [self addSubview:_iconImageView];
        }else{
            menuNameRect = CGRectMake(margin+10, margin, FTDefaultMenuWidth - margin*2, FTDefaultMenuIconWidth);
        }
        _menuNameLabel = [[UILabel alloc]initWithFrame:menuNameRect];
        _menuNameLabel.backgroundColor = [UIColor clearColor];
        _menuNameLabel.font = [UIFont systemFontOfSize:16];
        _menuNameLabel.textColor = FTDefaultTextColor;
        _menuNameLabel.text = menuName;
        [self addSubview:_menuNameLabel];
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, (_menuNameLabel.frame.size.height/2+_menuNameLabel.frame.origin.y)*2, self.contentView.bounds.size.width, .5)];
        _lineView.backgroundColor = [UIColor colorWithRed:232 / 255.0 green:232 / 255.0 blue:232 / 255.0 alpha:1];
        [self addSubview:_lineView];
    }
    return self;
}



@end



#pragma mark - FTPopOverMenuView

@interface FTPopOverMenuView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *menuTableView;
@property (nonatomic, strong) NSArray<NSString *> *menuStringArray;
@property (nonatomic, strong) NSArray<NSString *> *menuIconNameArray;
@property (nonatomic, assign) FTPopOverMenuArrowDirection arrowDirection;
@property (nonatomic, strong) FTPopOverMenuDoneBlock doneBlock;
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
@property (nonatomic,strong)UIColor *tintColor;

@end

@implementation FTPopOverMenuView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _menuTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _menuTableView.backgroundColor = FTBackgroundColor;
        _menuTableView.separatorColor = [UIColor grayColor];
        _menuTableView.layer.cornerRadius = FTDefaultMenuCornerRadius;
        _menuTableView.separatorInset = UIEdgeInsetsMake(0, FTDefaultMargin, 0, FTDefaultMargin);
        _menuTableView.scrollEnabled = NO;
        _menuTableView.clipsToBounds = YES;
        _menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _menuTableView.delegate = self;
        _menuTableView.dataSource = self;
        [self addSubview:_menuTableView];
        
        
    }
    return self;
}

-(void)showWithAnglePoint:(CGPoint)anglePoint
            withNameArray:(NSArray<NSString*> *)nameArray
           imageNameArray:(NSArray<NSString*> *)imageNameArray
         shouldAutoScroll:(BOOL)shouldAutoScroll
           arrowDirection:(FTPopOverMenuArrowDirection)arrowDirection
                doneBlock:(FTPopOverMenuDoneBlock)doneBlock
{
    _menuStringArray = nameArray;
    _menuIconNameArray = imageNameArray;
    _arrowDirection = arrowDirection;
    self.doneBlock = doneBlock;
    [_menuTableView reloadData];
    _menuTableView.scrollEnabled = shouldAutoScroll;
    switch (_arrowDirection) {
        case FTPopOverMenuArrowDirectionUp:
            _menuTableView.frame = CGRectMake(0, FTDefaultMenuArrowHeight, self.frame.size.width, self.frame.size.height - FTDefaultMenuArrowHeight);
            break;
            
        case FTPopOverMenuArrowDirectionDown:
            _menuTableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - FTDefaultMenuArrowHeight);
            break;
        case FTPopOverMenuArrowDirectionNone:
            _menuTableView.frame = CGRectMake(0, FTDefaultMenuArrowHeight, self.frame.size.width, self.frame.size.height - FTDefaultMenuArrowHeight);
            break;
        default:
            break;
    }
    [self drawBackgroundLayerWithAnglePoint:anglePoint];
}
-(void)drawBackgroundLayerWithAnglePoint:(CGPoint)anglePoint
{
    if (_backgroundLayer) {
        [_backgroundLayer removeFromSuperlayer];
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    switch (_arrowDirection) {
        case FTPopOverMenuArrowDirectionUp:{
            
            // [path moveToPoint:anglePoint];
            CGFloat a = FTDefaultMenuCornerRadius/2 * sqrt(3);
            [path moveToPoint:CGPointMake(anglePoint.x + a/2.0, anglePoint.y + a/2.0*(sqrt(3)))];
            [path addArcWithCenter:CGPointMake(anglePoint.x, anglePoint.y + a/sqrt(3)*2) radius:a/(sqrt(3)) startAngle:-M_PI_2/3.0 endAngle:-M_PI + M_PI_2/3.0 clockwise:NO];
            [path addLineToPoint:CGPointMake(anglePoint.x - FTDefaultMenuArrowWidth, FTDefaultMenuArrowHeight)];
            [path addLineToPoint:CGPointMake(FTDefaultMenuCornerRadius, FTDefaultMenuArrowHeight)];
            [path addArcWithCenter:CGPointMake(FTDefaultMenuCornerRadius, FTDefaultMenuArrowHeight + FTDefaultMenuCornerRadius) radius:FTDefaultMenuCornerRadius startAngle:-M_PI_2 endAngle:-M_PI clockwise:NO];
            [path addLineToPoint:CGPointMake(0, self.bounds.size.height - FTDefaultMenuCornerRadius)];
            [path addArcWithCenter:CGPointMake(FTDefaultMenuCornerRadius, self.bounds.size.height - FTDefaultMenuCornerRadius) radius:FTDefaultMenuCornerRadius startAngle:M_PI endAngle:M_PI_2 clockwise:NO];
            [path addLineToPoint:CGPointMake(self.bounds.size.width - FTDefaultMenuCornerRadius, self.bounds.size.height)];
            [path addArcWithCenter:CGPointMake(self.bounds.size.width - FTDefaultMenuCornerRadius, self.bounds.size.height - FTDefaultMenuCornerRadius) radius:FTDefaultMenuCornerRadius startAngle:M_PI_2 endAngle:0 clockwise:NO];
            [path addLineToPoint:CGPointMake(self.bounds.size.width , FTDefaultMenuCornerRadius + FTDefaultMenuArrowHeight)];
            [path addArcWithCenter:CGPointMake(self.bounds.size.width - FTDefaultMenuCornerRadius, FTDefaultMenuCornerRadius + FTDefaultMenuArrowHeight) radius:FTDefaultMenuCornerRadius startAngle:0 endAngle:-M_PI_2 clockwise:NO];
            [path addLineToPoint:CGPointMake(anglePoint.x + FTDefaultMenuArrowWidth, FTDefaultMenuArrowHeight)];
            [path closePath];
            
        }break;
        case FTPopOverMenuArrowDirectionDown:{
            
            // [path moveToPoint:anglePoint];
            CGFloat a = FTDefaultMenuCornerRadius/2 * sqrt(3);
            [path moveToPoint:CGPointMake(anglePoint.x + a/2, anglePoint.y - a/2 * sqrt(3))];
            [path addArcWithCenter:CGPointMake(anglePoint.x, anglePoint.y - a/sqrt(3)*2) radius:a/(sqrt(3)) startAngle:M_PI_2/3 endAngle:M_PI-M_PI_2/3 clockwise:YES];
            [path addLineToPoint:CGPointMake( anglePoint.x - FTDefaultMenuArrowWidth, anglePoint.y - FTDefaultMenuArrowHeight)];
            [path addLineToPoint:CGPointMake( FTDefaultMenuCornerRadius, anglePoint.y - FTDefaultMenuArrowHeight)];
            [path addArcWithCenter:CGPointMake(FTDefaultMenuCornerRadius, anglePoint.y - FTDefaultMenuArrowHeight - FTDefaultMenuCornerRadius) radius:FTDefaultMenuCornerRadius startAngle:-M_PI_2 endAngle:-M_PI clockwise:YES];
            [path addLineToPoint:CGPointMake( 0, FTDefaultMenuCornerRadius)];
            [path addArcWithCenter:CGPointMake(FTDefaultMenuCornerRadius, FTDefaultMenuCornerRadius) radius:FTDefaultMenuCornerRadius startAngle:M_PI endAngle:-M_PI_2 clockwise:YES];
            [path addLineToPoint:CGPointMake( self.bounds.size.width - FTDefaultMenuCornerRadius, 0)];
            [path addArcWithCenter:CGPointMake(self.bounds.size.width - FTDefaultMenuCornerRadius, FTDefaultMenuCornerRadius) radius:FTDefaultMenuCornerRadius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
            [path addLineToPoint:CGPointMake(self.bounds.size.width , anglePoint.y - (FTDefaultMenuCornerRadius + FTDefaultMenuArrowHeight))];
            [path addArcWithCenter:CGPointMake(self.bounds.size.width - FTDefaultMenuCornerRadius, anglePoint.y - (FTDefaultMenuCornerRadius + FTDefaultMenuArrowHeight)) radius:FTDefaultMenuCornerRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
            [path addLineToPoint:CGPointMake(anglePoint.x + FTDefaultMenuArrowWidth, anglePoint.y - FTDefaultMenuArrowHeight)];
            [path closePath];
            
        }break;
        case FTPopOverMenuArrowDirectionNone:{
            
            // [path moveToPoint:anglePoint];
            [path moveToPoint:CGPointMake(anglePoint.x - FTDefaultMenuArrowWidth, FTDefaultMenuArrowHeight)];
            [path addLineToPoint:CGPointMake(anglePoint.x - FTDefaultMenuArrowWidth, FTDefaultMenuArrowHeight)];
            [path addLineToPoint:CGPointMake(FTDefaultMenuCornerRadius, FTDefaultMenuArrowHeight)];
            [path addArcWithCenter:CGPointMake(FTDefaultMenuCornerRadius, FTDefaultMenuArrowHeight + FTDefaultMenuCornerRadius) radius:FTDefaultMenuCornerRadius startAngle:-M_PI_2 endAngle:-M_PI clockwise:NO];
            [path addLineToPoint:CGPointMake(0, self.bounds.size.height - FTDefaultMenuCornerRadius)];
            [path addArcWithCenter:CGPointMake(FTDefaultMenuCornerRadius, self.bounds.size.height - FTDefaultMenuCornerRadius) radius:FTDefaultMenuCornerRadius startAngle:M_PI endAngle:M_PI_2 clockwise:NO];
            [path addLineToPoint:CGPointMake(self.bounds.size.width - FTDefaultMenuCornerRadius, self.bounds.size.height)];
            [path addArcWithCenter:CGPointMake(self.bounds.size.width - FTDefaultMenuCornerRadius, self.bounds.size.height - FTDefaultMenuCornerRadius) radius:FTDefaultMenuCornerRadius startAngle:M_PI_2 endAngle:0 clockwise:NO];
            [path addLineToPoint:CGPointMake(self.bounds.size.width , FTDefaultMenuCornerRadius + FTDefaultMenuArrowHeight)];
            [path addArcWithCenter:CGPointMake(self.bounds.size.width - FTDefaultMenuCornerRadius, FTDefaultMenuCornerRadius + FTDefaultMenuArrowHeight) radius:FTDefaultMenuCornerRadius startAngle:0 endAngle:-M_PI_2 clockwise:NO];
            [path addLineToPoint:CGPointMake(anglePoint.x + FTDefaultMenuArrowWidth, FTDefaultMenuArrowHeight)];
            [path closePath];
            
        }break;
        default:
            break;
    }
    
    _backgroundLayer = [CAShapeLayer layer];
    _backgroundLayer.path = path.CGPath;
    _backgroundLayer.fillColor = _tintColor ? [UIColor colorWithRed:0 green:0 blue:0 alpha:.7].CGColor : FTDefaultTintColor.CGColor;
    _backgroundLayer.strokeColor = _tintColor ? _tintColor.CGColor : FTDefaultTintColor.CGColor;
    [self.layer insertSublayer:_backgroundLayer atIndex:0];
    
    
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FTDefaultMenuRowHeight;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _menuStringArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *imageName = [NSString string];
    if (_menuIconNameArray.count - 1 >= indexPath.row) {
        imageName = [NSString stringWithFormat:@"%@",_menuIconNameArray[indexPath.row]];
    }
    FTPopOverMenuCell *menuCell = [[FTPopOverMenuCell alloc]initWithStyle:UITableViewCellStyleDefault
                                                          reuseIdentifier:FTPopOverMenuTableViewCellIndentifier
                                                                 menuName:[NSString stringWithFormat:@"%@", _menuStringArray[indexPath.row]]
                                                            iconImageName:imageName];
    
    return menuCell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.doneBlock) {
        self.doneBlock(indexPath.row);
    }
}

@end


#pragma mark - FTPopOverMenu

@interface FTPopOverMenu () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView * backgroundView;
@property (nonatomic, strong) FTPopOverMenuView *popMenuView;
@property (nonatomic, strong) FTPopOverMenuDoneBlock doneBlock;
@property (nonatomic, strong) FTPopOverMenuDismissBlock dismissBlock;
@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic, strong) UIView *sender;
@property (nonatomic, assign) CGRect senderFrame;
@property (nonatomic, strong) NSArray<NSString*> *menuArray;
@property (nonatomic, strong) NSArray<NSString*> *menuImageArray;
@property (nonatomic, assign) BOOL isCurrentlyOnScreen;

@property (nonatomic, assign) BOOL noneArrow;

@end

@implementation FTPopOverMenu

+ (FTPopOverMenu *)sharedInstance
{
    static dispatch_once_t once = 0;
    static FTPopOverMenu *shared;
    dispatch_once(&once, ^{ shared = [[FTPopOverMenu alloc] init]; });
    return shared;
}

#pragma mark - Public Method

+ (void) showFromSenderFrame:(CGRect )senderFrame
                    withMenu:(NSArray<NSString*> *)menuArray
              imageNameArray:(NSArray<NSString*> *)imageNameArray
                   doneBlock:(FTPopOverMenuDoneBlock)doneBlock
                dismissBlock:(FTPopOverMenuDismissBlock)dismissBlock
{
    [[self sharedInstance] setNoneArraw:NO];
    [[self sharedInstance] showForSender:nil senderFrame:senderFrame withMenu:menuArray imageNameArray:imageNameArray doneBlock:doneBlock dismissBlock:dismissBlock];
}
+ (void)showNoneArrowFromSenderFrame:(CGRect)senderFrame
                            withMenu:(NSArray<NSString *> *)menuArray
                      imageNameArray:(NSArray<NSString *> *)imageNameArray
                           doneBlock:(FTPopOverMenuDoneBlock)doneBlock
                        dismissBlock:(FTPopOverMenuDismissBlock)dismissBlock {
    [[self sharedInstance] setNoneArraw:YES];
    [[self sharedInstance] showForSender:nil senderFrame:senderFrame withMenu:menuArray imageNameArray:imageNameArray doneBlock:doneBlock dismissBlock:dismissBlock];
}

+(void)dismiss
{
    [[self sharedInstance] dismiss];
}

+(void)setTintColor:(UIColor *)tintColor
{
    [self sharedInstance].tintColor = tintColor;
}

#pragma mark - Private Methods

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onChangeStatusBarOrientationNotification:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    return self;
}

-(void)initViews
{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc ]initWithFrame:[UIScreen mainScreen].bounds];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackgroundViewTapped:)];
        tap.delegate = self;
        [_backgroundView addGestureRecognizer:tap];
        _backgroundView.backgroundColor = FTBackgroundColor;
    }
    
    
    if (!_popMenuView) {
        _popMenuView = [[FTPopOverMenuView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [_backgroundView addSubview:_popMenuView];
        _popMenuView.alpha = 0;
    }
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:_backgroundView];
    
}

-(UIColor *)tintColor
{
    if (!_tintColor) {
        _tintColor = FTDefaultTintColor;
    }
    return _tintColor;
}

-(void)onChangeStatusBarOrientationNotification:(NSNotification *)notification
{
    if (self.isCurrentlyOnScreen) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self adjustPopOverMenu];
        });
    }
}


- (void) showForSender:(UIView *)sender
           senderFrame:(CGRect )senderFrame
              withMenu:(NSArray<NSString*> *)menuArray
        imageNameArray:(NSArray<NSString*> *)imageNameArray
             doneBlock:(FTPopOverMenuDoneBlock)doneBlock
          dismissBlock:(FTPopOverMenuDismissBlock)dismissBlock
{
    
    [self initViews];
    self.sender = sender;
    self.senderFrame = senderFrame;
    self.menuArray = menuArray;
    self.menuImageArray = imageNameArray;
    self.doneBlock = doneBlock;
    self.dismissBlock = dismissBlock;
    
//    _noneArrow = NO;
    [self adjustPopOverMenu];
}
- (void)setNoneArraw:(BOOL)isYes {
    _noneArrow = isYes;
}
-(void)adjustPopOverMenu
{
    
    [self.backgroundView setFrame:CGRectMake(0, 0, KSCREEN_WIDTH, KSCREEN_HEIGHT)];
    
    CGRect senderRect ;
    
    if (self.sender) {
        senderRect = [self.sender.superview convertRect:self.sender.frame toView:_backgroundView];
    }else{
        senderRect = self.senderFrame;
    }
    if (senderRect.origin.y > KSCREEN_HEIGHT) {
        senderRect.origin.y = KSCREEN_HEIGHT;
    }
    
    CGFloat menuHeight = FTDefaultMenuRowHeight * self.menuArray.count + FTDefaultMenuArrowHeight;
    CGPoint menuArrowPoint = CGPointMake(senderRect.origin.x + (senderRect.size.width)/2, 0);
    CGFloat menuX = 0;
    CGRect menuRect = CGRectZero;
    BOOL shouldAutoScroll = NO;
    FTPopOverMenuArrowDirection arrowDirection;
    
    if (senderRect.origin.y + senderRect.size.height/2  < KSCREEN_HEIGHT/2) {
        arrowDirection = FTPopOverMenuArrowDirectionUp;
        menuArrowPoint.y = 0;
        
    }else{
        arrowDirection = FTPopOverMenuArrowDirectionDown;
        menuArrowPoint.y = menuHeight;
        
    }
    
    if (menuArrowPoint.x + FTDefaultMenuWidth/2 + FTDefaultMargin > KSCREEN_WIDTH) {
        menuArrowPoint.x = MIN(menuArrowPoint.x - (KSCREEN_WIDTH - FTDefaultMenuWidth - FTDefaultMargin), FTDefaultMenuWidth - FTDefaultMenuArrowWidth - FTDefaultMargin);
        menuX = KSCREEN_WIDTH - FTDefaultMenuWidth - FTDefaultMargin;
    }else if ( menuArrowPoint.x - FTDefaultMenuWidth/2 - FTDefaultMargin < 0){
        menuArrowPoint.x = MAX( FTDefaultMenuCornerRadius + FTDefaultMenuArrowWidth, menuArrowPoint.x - FTDefaultMargin);
        menuX = FTDefaultMargin;
    }else{
        menuArrowPoint.x = FTDefaultMenuWidth/2;
        menuX = senderRect.origin.x + (senderRect.size.width)/2 - FTDefaultMenuWidth/2;
    }
    
    if (arrowDirection == FTPopOverMenuArrowDirectionUp) {
        menuRect = CGRectMake(menuX, (senderRect.origin.y + senderRect.size.height), FTDefaultMenuWidth, menuHeight);
        // if too long and is out of screen
        if (menuRect.origin.y + menuRect.size.height > KSCREEN_HEIGHT) {
            menuRect = CGRectMake(menuX, (senderRect.origin.y + senderRect.size.height), FTDefaultMenuWidth, KSCREEN_HEIGHT - menuRect.origin.y - FTDefaultMargin);
            shouldAutoScroll = YES;
        }
    }else{
        
        menuRect = CGRectMake(menuX, (senderRect.origin.y - menuHeight), FTDefaultMenuWidth, menuHeight);
        // if too long and is out of screen
        if (menuRect.origin.y  < 0) {
            menuRect = CGRectMake(menuX, FTDefaultMargin, FTDefaultMenuWidth, senderRect.origin.y - FTDefaultMargin);
            menuArrowPoint.y = senderRect.origin.y;
            shouldAutoScroll = YES;
        }
    }
    
    
    _popMenuView.frame = menuRect;
    _popMenuView.tintColor = self.tintColor;
    if (_noneArrow) {
        arrowDirection = FTPopOverMenuArrowDirectionNone;
    }
    
    [_popMenuView showWithAnglePoint:menuArrowPoint
                       withNameArray:self.menuArray
                      imageNameArray:self.menuImageArray
                    shouldAutoScroll:shouldAutoScroll
                      arrowDirection:arrowDirection
                           doneBlock:^(NSInteger selectedIndex) {
                               [self doneActionWithSelectedIndex:selectedIndex];
                           }];
    
    [self show];
}


#pragma mark - UIGestureRecognizerDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}

#pragma mark - onBackgroundViewTapped

-(void)onBackgroundViewTapped:(UIGestureRecognizer *)gesture
{
    [self dismiss];
}

#pragma mark - show animation

- (void)show
{
    self.isCurrentlyOnScreen = YES;
    [UIView animateWithDuration:FTDefaultAnimationDuration
                     animations:^{
                         _popMenuView.alpha = 1;
                     }];
}

#pragma mark - dismiss animation

- (void)dismiss
{
    self.isCurrentlyOnScreen = NO;
    [self doneActionWithSelectedIndex:-1];
}

#pragma mark - doneActionWithSelectedIndex

-(void)doneActionWithSelectedIndex:(NSInteger)selectedIndex
{
    [UIView animateWithDuration:FTDefaultAnimationDuration
                     animations:^{
                         _popMenuView.alpha = 0;
                     }completion:^(BOOL finished) {
                         if (finished) {
                             [_backgroundView removeFromSuperview];
                             
                             if (selectedIndex < 0) {
                                 if (self.dismissBlock) {
                                     self.dismissBlock();
                                 }
                             }else{
                                 if (self.doneBlock) {
                                     self.doneBlock(selectedIndex);
                                 }
                             }
                         }
                     }];
}
@end
