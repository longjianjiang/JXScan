//
//  JXEditViewController.h
//  JXScanDemo
//
//  Created by zl on 2018/7/23.
//  Copyright © 2018年 longjianjiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXEditViewController : UIViewController

- (instancetype)initWithOriginalImage:(UIImage *)originalImage borderRectangle:(CIRectangleFeature *)borderRectangle;

@end

NS_ASSUME_NONNULL_END
