//
//  JXDocumentDetectorView.h
//  DocScanDemo
//
//  Created by zl on 2018/6/26.
//  Copyright © 2018年 longjianjiang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CompletionHandler)(UIImage *originalImage, UIImage *cutImage, CIRectangleFeature *borderRectangle);

@class JXDocumentDetectorView;

@protocol JXDocumentDetectorViewDelegate <NSObject>

@optional

- (void)jxDocumentDetectorViewDidFailToSetupCamera:(JXDocumentDetectorView *)documentDetectorView;
- (void)jxDocumentDetectorView:(JXDocumentDetectorView *)documentDetectorView didCaptureOriginalImage:(UIImage *)originalImage cutImage:(UIImage *)cutImage;

@end


@interface JXDocumentDetectorView : UIView

- (void)setupCameraView;
- (void)startDetect;
- (void)stopDetect;
- (void)didCaptureImageWithCompletionHandler:(CompletionHandler)completionHandler;

@property (nonatomic, weak) id<JXDocumentDetectorViewDelegate> delegate;

@end

