# PopMenu
create a popMenu(气泡菜单) for you app
###!修改自https://github.com/liufengting/FTPopOverMenu 以适应工程,修改了箭头顶部的弧度

##导入方法

pod 'SXPopMenu', '~>1.1.0'

##调用
头文件#import "FTPopOverMenu.h"
###.精简了大量的方法,只留下了:
```
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
```
###.添加了不带箭头的pop方法
```
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
```

![img](https://github.com/poos/SXPopMenu/blob/master/Untitled.gif)
