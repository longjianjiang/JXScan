//
//  JXDocumentDetectorView.h
//  DocScanDemo
//
//  Created by zl on 2018/6/26.
//  Copyright © 2018年 longjianjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXQuadrangle.h"

@class JXDocumentDetectorView;

@protocol JXDocumentDetectorViewDelegate <NSObject>

@required
- (void)jxDocumentDetectorViewDidFailToSetupCamera:(JXDocumentDetectorView *)documentDetectorView;
- (void)jxDocumentDetectorView:(JXDocumentDetectorView *)documentDetectorView didCaptureOriginalImage:(UIImage *)originalImage cutImage:(UIImage *)cutImage borderRectangle:(JXQuadrangleFeature)borderRectangle;

@end


@interface JXDocumentDetectorView : UIView

- (void)setupCameraView;
- (void)startDetect;
- (void)stopDetect;
- (void)capture;

@property (nonatomic, weak) id<JXDocumentDetectorViewDelegate> delegate;
@property (nonatomic, assign) BOOL isAutoCapture;

@end

