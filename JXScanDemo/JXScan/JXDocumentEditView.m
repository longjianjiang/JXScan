//
//  JXDocumentEditView.m
//  JXScanDemo
//
//  Created by zl on 2018/7/23.
//  Copyright © 2018年 longjianjiang. All rights reserved.
//

#import "JXDocumentEditView.h"

@interface JXDocumentEditView ()

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) CIRectangleFeature *borderRectangle;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) CAShapeLayer *borderShapeLayer;
@end


@implementation JXDocumentEditView

#pragma mark - life cycle
- (instancetype)init {
    NSCAssert(NO, @"Use -initWithOriginalImage:borderRectangle: instead");
    return nil;
}

- (instancetype)initWithOriginalImage:(UIImage *)originalImage borderRectangle:(CIRectangleFeature *)borderRectangle {
    self = [super init];
    if (self) {
        self.borderRectangle = borderRectangle;
        self.image = originalImage;
        [self setupSubview];
        [self addSomeConstraints];
    }
    return self;
}

- (void)setupSubview {
    [self addSubview:self.imageView];
    
    self.layer.masksToBounds = YES;
    [self.layer addSublayer:self.borderShapeLayer];
    
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:self.borderRectangle.topLeft];
    [path addLineToPoint:self.borderRectangle.topRight];
    [path addLineToPoint:self.borderRectangle.bottomRight];
    [path addLineToPoint:self.borderRectangle.bottomLeft];
    [path closePath];
    
    UIBezierPath *rectPath  = [UIBezierPath bezierPathWithRect:CGRectMake(-5,
                                                                          -5,
                                                                          self.frame.size.width + 10,
                                                                          self.frame.size.height + 10)];
    [rectPath setUsesEvenOddFillRule:YES];
    [rectPath appendPath:path];
    self.borderShapeLayer.path = rectPath.CGPath;
}

- (void)addSomeConstraints {
    [[self.imageView.topAnchor constraintEqualToAnchor:self.topAnchor] setActive:YES];
    [[self.imageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
    [[self.imageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor] setActive:YES];
    [[self.imageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor] setActive:YES];
}


#pragma mark - getter and setter
- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [UIImageView new];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.image = self.image;
    }
    return _imageView;
}

- (CAShapeLayer *)borderShapeLayer {
    if (_borderShapeLayer == nil) {
        _borderShapeLayer = [CAShapeLayer layer];
        _borderShapeLayer.fillRule = kCAFillRuleEvenOdd;
        _borderShapeLayer.fillColor = [UIColor clearColor].CGColor;
        _borderShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        _borderShapeLayer.lineWidth = 2.0f;
    }
    return _borderShapeLayer;
}
@end
