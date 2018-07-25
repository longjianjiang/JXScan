//
//  JXCGTransformHelper.h
//  DocScanDemo
//
//  Created by zl on 2018/6/26.
//  Copyright © 2018年 longjianjiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct CIFeatureRect{
    
    CGPoint topLeft;
    CGPoint topRight;
    CGPoint bottomRight;
    CGPoint bottomLeft;
    
} TransformCIFeatureRect;

@interface JXCGTransformHelper : NSObject

+ (TransformCIFeatureRect)transfromRealCIRectInPreviewRect:(CGRect)previewRect imageRect:(CGRect)imageRect topLeft:(CGPoint)topLeft topRight:(CGPoint)topRight bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight;

+ (TransformCIFeatureRect)transfromRealCGRectInPreviewRect:(CGRect)previewRect imageRect:(CGRect)imageRect topLeft:(CGPoint)topLeft topRight:(CGPoint)topRight bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight;

@end

NS_ASSUME_NONNULL_END
