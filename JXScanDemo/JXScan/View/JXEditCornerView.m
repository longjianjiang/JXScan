//
//  JXEditCornerView.m
//  JXScanDemo
//
//  Created by zl on 2018/7/24.
//  Copyright © 2018年 longjianjiang. All rights reserved.
//

#import "JXEditCornerView.h"

@implementation JXEditCornerView

#pragma mark - life cycle
- (instancetype)init {
    NSCAssert(NO, @"Use -initWithCorderPosition: instead");
    return nil;
}

- (instancetype)initWithCorderPosition:(JXCorderPosition)position {
    self = [super init];
    if (self) {
        self.position = position;
    }
    return self;
}

@end
