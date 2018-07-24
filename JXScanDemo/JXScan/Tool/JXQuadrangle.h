//
//  JXQuadrangle.h
//  JXScanDemo
//
//  Created by zl on 2018/7/24.
//  Copyright © 2018年 longjianjiang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JXCorderPosition) {
    JXCorderPositionTopLeft,
    JXCorderPositionTopRight,
    JXCorderPositionBottomRight,
    JXCorderPositionBottomLeft
};

typedef struct JXQuadrangleFeature {
    
    CGPoint topLeft;
    CGPoint topRight;
    CGPoint bottomLeft;
    CGPoint bottomRight;
    
} JXQuadrangleFeature;


@interface JXQudrangle : NSObject

+ (JXQuadrangleFeature)getQuadrangleFeatureWithPreviewRect:(CGRect)previewRect extentImageRect:(CGRect)extentImageRect reactangleFeature:(CIRectangleFeature *)rectangleFeature;

+ (JXQuadrangleFeature)getQuadrangleFeatureWithReactangleFeature:(CIRectangleFeature *)rectangleFeature;

+ (JXQuadrangleFeature)getQuadrangleFeatureWithTopLeft:(CGPoint)topLeft topRight:(CGPoint)topRight bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight;

+ (JXQuadrangleFeature)getNewQuadrangleWithQuadrangle:(JXQuadrangleFeature)quadrangleFeature transform:(CGAffineTransform)transform;

+ (UIBezierPath *)getQuadranglePathWithQuadrangle:(JXQuadrangleFeature)quadrangleFeature;

@end







