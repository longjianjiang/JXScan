//
//  JXPreviewEditCornerView.m
//  JXScanDemo
//
//  Created by zl on 2018/7/24.
//  Copyright © 2018年 longjianjiang. All rights reserved.
//

#import "JXPreviewEditCornerView.h"


@interface JXPreviewEditCornerView ()

@property (nonatomic, strong) UIImageView *previewView;
@property (nonatomic, strong) UIView *pointView;

@end



@implementation JXPreviewEditCornerView

- (void)updatePreviewWithPreviewImage:(UIImage *)previewImage {
    self.previewView.image = previewImage;
    
    self.pointView.center = self.previewView.center;
}


#pragma mark - life cycle
- (void)setupSubview {
    [self addSubview:self.previewView];
    [self addSubview:self.pointView];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubview];
    }
    return self;
}


#pragma mark - getter and setter
- (UIImageView *)previewView {
    if (_previewView == nil) {
        _previewView = [[UIImageView alloc] initWithFrame:self.bounds];
        _previewView.layer.cornerRadius = 100/2.0;
        _previewView.layer.borderColor = [UIColor whiteColor].CGColor;
        _previewView.layer.borderWidth = 2.0;
        _previewView.layer.masksToBounds = YES;
    }
    return _previewView;
}

- (UIView *)pointView {
    if (_pointView == nil) {
        _pointView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _pointView.layer.cornerRadius = 10/2.0;
        _pointView.layer.borderColor = [UIColor greenColor].CGColor;
        _pointView.layer.borderWidth = 2.0;
        _pointView.layer.masksToBounds = YES;
    }
    return _pointView;
}
@end
