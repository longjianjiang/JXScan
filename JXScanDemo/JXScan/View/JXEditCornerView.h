//
//  JXEditCornerView.h
//  JXScanDemo
//
//  Created by zl on 2018/7/24.
//  Copyright © 2018年 longjianjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXQuadrangle.h"

@interface JXEditCornerView : UIView

@property (nonatomic, assign) JXCorderPosition position;

- (instancetype)initWithCorderPosition:(JXCorderPosition)position;

@end


