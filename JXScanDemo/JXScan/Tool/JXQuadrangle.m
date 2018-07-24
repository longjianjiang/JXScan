//
//  JXQuadrangle.m
//  JXScanDemo
//
//  Created by zl on 2018/7/24.
//  Copyright © 2018年 longjianjiang. All rights reserved.
//

#import "JXQuadrangle.h"

@implementation JXQudrangle

#pragma mark - public method

+ (JXQuadrangleFeature)getQuadrangleFeatureWithPreviewRect:(CGRect)previewRect extentImageRect:(CGRect)extentImageRect reactangleFeature:(CIRectangleFeature *)rectangleFeature {
    
    JXQuadrangleFeature qf = [self getQuadrangleFeatureWithReactangleFeature:rectangleFeature];

    CGFloat deltaX = CGRectGetWidth(previewRect)/CGRectGetWidth(extentImageRect);
    CGFloat deltaY = CGRectGetHeight(previewRect)/CGRectGetHeight(extentImageRect);
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0.f, CGRectGetHeight(previewRect));
    transform = CGAffineTransformScale(transform, 1, -1); // when UIKit coordinate this line should not be executed
    
    transform = CGAffineTransformScale(transform, deltaX, deltaY);
    
    return [self getNewQuadrangleWithQuadrangle:qf transform:transform];
}


+ (JXQuadrangleFeature)getQuadrangleFeatureWithReactangleFeature:(CIRectangleFeature *)rectangleFeature {
    
    JXQuadrangleFeature qf;
    qf.topLeft = rectangleFeature.topLeft;
    qf.topRight = rectangleFeature.topRight;
    qf.bottomRight = rectangleFeature.bottomRight;
    qf.bottomLeft = rectangleFeature.bottomLeft;
   
    return qf;
}


+ (JXQuadrangleFeature)getQuadrangleFeatureWithTopLeft:(CGPoint)topLeft topRight:(CGPoint)topRight bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight {
    
    JXQuadrangleFeature qf;
    qf.topLeft = topLeft;
    qf.topRight = topRight;
    qf.bottomRight = bottomRight;
    qf.bottomLeft = bottomLeft;
    
    return qf;
}

+ (JXQuadrangleFeature)getNewQuadrangleWithQuadrangle:(JXQuadrangleFeature)quadrangleFeature transform:(CGAffineTransform)transform {
    
    JXQuadrangleFeature qf;
    qf.topLeft = CGPointApplyAffineTransform(quadrangleFeature.topLeft, transform);
    qf.topRight = CGPointApplyAffineTransform(quadrangleFeature.topRight, transform);
    qf.bottomRight = CGPointApplyAffineTransform(quadrangleFeature.bottomRight, transform);
    qf.bottomLeft = CGPointApplyAffineTransform(quadrangleFeature.bottomLeft, transform);
    
    return qf;
}

+ (UIBezierPath *)getQuadranglePathWithQuadrangle:(JXQuadrangleFeature)quadrangleFeature {
    
    UIBezierPath *path = [UIBezierPath new];
    
    [path moveToPoint:quadrangleFeature.topLeft];
    [path addLineToPoint:quadrangleFeature.topRight];
    [path addLineToPoint:quadrangleFeature.bottomRight];
    [path addLineToPoint:quadrangleFeature.bottomLeft];
    [path closePath];
    
    return path;
}


@end
