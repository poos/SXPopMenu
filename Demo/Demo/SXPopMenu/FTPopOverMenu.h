//
//  FTPopOverMenu.h
//  FTPopOverMenu
//
//  Created by liufengting on 16/4/5.
//  Copyright © 2016年 liufengting ( https://github.com/liufengting ). All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  FTPopOverMenuDoneBlock
 *
 *  @param index SlectedIndex
 */
typedef void (^FTPopOverMenuDoneBlock)(NSInteger selectedIndex);
/**
 *  FTPopOverMenuDismissBlock
 */
typedef void (^FTPopOverMenuDismissBlock)();

/**
 *  FTPopOverMenuCell
 */
@interface FTPopOverMenuCell : UITableViewCell

@end
/**
 *  FTPopOverMenuView
 */
@interface FTPopOverMenuView : UIControl

@end

/**---------------------------------------------------------------------
 *  -----------------------FTPopOverMenu-----------------------
 */
@interface FTPopOverMenu : NSObject

/**
 *  setTintColor
 *
 *  @param tintColor tintColor
 */
+(void)setTintColor:(UIColor *)tintColor;

/**
 *  setTextColor
 *
 *  @param textColor textColor
 */
//+(void)setTextColor:(UIColor *)textColor;

/**
 *  setPreferedWidth
 *
 *  @param preferedWidth preferedWidth
 */
//+(void)setPreferedWidth:(CGFloat )preferedWidth;


/**
 *  show method with SenderFrame with imageNameArray
 *
 *  @param senderFrame    senderFrame
 *  @param menuArray      menuArray
 *  @param imageNameArray imageNameArray
 *  @param doneBlock      doneBlock
 *  @param dismissBlock   dismissBlock
 
 */
+ (void) showFromSenderFrame:(CGRect )senderFrame
                    withMenu:(NSArray<NSString*> *)menuArray
              imageNameArray:(NSArray<NSString*> *)imageNameArray
                   doneBlock:(FTPopOverMenuDoneBlock)doneBlock
                dismissBlock:(FTPopOverMenuDismissBlock)dismissBlock;
/**
 *  show method with SenderFrame with imageNameArray
 *
 *  @param senderFrame    senderFrame
 *  @param menuArray      menuArray
 *  @param imageNameArray imageNameArray
 *  @param doneBlock      doneBlock
 *  @param dismissBlock   dismissBlock
 
 */
+ (void)showNoneArrowFromSenderFrame:(CGRect)senderFrame
                            withMenu:(NSArray<NSString *> *)menuArray
                      imageNameArray:(NSArray<NSString *> *)imageNameArray
                           doneBlock:(FTPopOverMenuDoneBlock)doneBlock
                        dismissBlock:(FTPopOverMenuDismissBlock)dismissBlock;
/**
 *  dismiss method
 */
+ (void) dismiss;

@end
