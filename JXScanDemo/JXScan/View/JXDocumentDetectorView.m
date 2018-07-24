//
//  JXDocumentDetectorView.m
//  DocScanDemo
//
//  Created by zl on 2018/6/26.
//  Copyright © 2018年 longjianjiang. All rights reserved.
//

#import "JXDocumentDetectorView.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <GLKit/GLKit.h>

#import "JXWeakProxy.h"

static CGFloat const kDetectorDocumentTimeInterval = 0.5f;

@interface JXDocumentDetectorView ()<AVCaptureVideoDataOutputSampleBufferDelegate> {
    GLKView *_glkView;
    GLuint _renderBuffer;
    
    CIContext *_coreImageContext;
    CGRect _imageExtentRect;
    CGFloat _imageDetectionConfidence;
    NSTimer *_documentDetectorTimer;
    
    BOOL _isStopped;
    BOOL _doucumentDetectFrame;
    __block BOOL _isCapturing;
    BOOL _forceStopDetect;
    BOOL _isCaptureFirstFrame;
    
    CAShapeLayer *_rectOverlay;
    CIRectangleFeature *_documentDetectLastRectangleFeature;
}


// capture property
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, strong) EAGLContext *context;

@end


@implementation JXDocumentDetectorView

#pragma mark - public method
- (void)capture {
    if (_isCapturing) return;
    
    __weak typeof(self) weakSelf = self;
    
    _isCapturing = YES;
    _rectOverlay.path = nil;
    
    AVCaptureConnection *connection = nil;
    for (AVCaptureConnection *con in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [con inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                connection = con;
                break;
            }
        }
        if (connection) break;
    }
    
    if (!connection || !connection.enabled || !connection.active || !_isCaptureFirstFrame) {
        return;
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        
        CIImage *enhancedImage = [CIImage imageWithData:imageData];
        enhancedImage = [strongSelf filteredImageUsingContrastFilterOnImage:enhancedImage];
        
        CIRectangleFeature *documentFeature;
        if (doucmentDetectionConfidenceHighEnough(strongSelf->_imageDetectionConfidence)) {
            documentFeature = [strongSelf biggestRectangleInRectangles:[[strongSelf documentBorderDetector] featuresInImage:enhancedImage]];
            if (documentFeature) {
                enhancedImage = [strongSelf correctPerspectiveForImage:enhancedImage withFeatures:documentFeature];
            }
        }
        
        UIGraphicsBeginImageContext(CGSizeMake(enhancedImage.extent.size.height, enhancedImage.extent.size.width));
        [[UIImage imageWithCIImage:enhancedImage scale:1.0 orientation:UIImageOrientationRight] drawInRect:CGRectMake(0,0, enhancedImage.extent.size.height, enhancedImage.extent.size.width)];
        UIImage *cutImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        JXQuadrangleFeature qf = [JXQudrangle getQuadrangleFeatureWithPreviewRect:strongSelf.frame extentImageRect:strongSelf->_imageExtentRect reactangleFeature:strongSelf->_documentDetectLastRectangleFeature];
        
        if ([strongSelf.delegate respondsToSelector:@selector(jxDocumentDetectorView:didCaptureOriginalImage:cutImage:borderRectangle:)]) {
            [strongSelf.delegate jxDocumentDetectorView:strongSelf didCaptureOriginalImage:[UIImage imageWithData:imageData] cutImage:cutImage borderRectangle:qf];
        }
        
        strongSelf->_isCapturing = NO;
        
        if (strongSelf->_rectOverlay) {
            strongSelf->_rectOverlay.path = nil;
        }
        
    }];
}

- (void)setupCameraView {
    [self _createGLKView];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!device) {
        if ([self.delegate respondsToSelector:@selector(jxDocumentDetectorViewDidFailToSetupCamera:)]) {
            [self.delegate jxDocumentDetectorViewDidFailToSetupCamera:self];
            return;
        }
    }
    
    self.captureDevice = device;
    
    _imageDetectionConfidence = 0.0;
    
    AVCaptureSession *session = [AVCaptureSession new];
    session.sessionPreset = AVCaptureSessionPresetPhoto;
    self.captureSession = session;
    
[session beginConfiguration];
   
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
    [session addInput:input];
    
    AVCaptureVideoDataOutput *dataOutput = [AVCaptureVideoDataOutput new];
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [dataOutput setVideoSettings:@{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)}];
    [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    if ([session canAddOutput:dataOutput]) {
        [session addOutput:dataOutput];
    }
    
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    [session addOutput:self.stillImageOutput];
    
    AVCaptureConnection *connection = [dataOutput.connections firstObject];
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    if (device.isFlashAvailable) {
        [device lockForConfiguration:nil];
        [device setFlashMode:AVCaptureFlashModeOff];
        [device unlockForConfiguration];
    }
    
    if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        [device lockForConfiguration:nil];
        [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        [device unlockForConfiguration];
    }
    
[session commitConfiguration];
    
}

- (void)startDetect {
    _isStopped = NO;
    
    [self.captureSession startRunning];
    
    if (_documentDetectorTimer) {
        [_documentDetectorTimer invalidate];
        _documentDetectorTimer = nil;
    }
    
    _documentDetectorTimer = [NSTimer scheduledTimerWithTimeInterval:kDetectorDocumentTimeInterval
                                                              target:[JXWeakProxy proxyWithTarget:self]
                                                            selector:@selector(_enableDocumentDetect)
                                                            userInfo:nil
                                                             repeats:YES];
    [self _hideGLKView:NO completion:nil];
}

- (void)stopDetect {
    _isStopped = YES;
    
    [self.captureSession stopRunning];
    
    [_documentDetectorTimer invalidate];
    _documentDetectorTimer = nil;
    
    [self _hideGLKView:YES completion:nil];
}

#pragma mark - timer method
- (void)_enableDocumentDetect {
    _doucumentDetectFrame = YES;
}


#pragma mark - draw method
- (void)_hideGLKView:(BOOL)hidden completion:(void (^)(void))completion {
    [UIView animateWithDuration:0.1 animations:^{
        self->_glkView.alpha = hidden ? 0.0 : 1.0;
    } completion:^(BOOL finished) {
        if (!completion) return;
        completion();
    }];
}


- (void)_createGLKView {
    if (self.context) return;
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *glkView = [[GLKView alloc] initWithFrame:self.bounds context:self.context];
    glkView.contentScaleFactor = 1.0;
    glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [self insertSubview:glkView atIndex:0];
    _glkView = glkView;
    
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);

    _coreImageContext = [CIContext contextWithEAGLContext:self.context];
    [EAGLContext setCurrentContext:self.context];
}

- (void)_drawBorderDetectRectWithExtentImageRect:(CGRect)extentImageRect rectangleFeature:(CIRectangleFeature *)rectangleFeature {
    if (!_imageExtentRect.size.width) {
        _imageExtentRect = extentImageRect;
    }
    
    if (_isCapturing) {
        return;
    }
    
    if (!_rectOverlay) {
        _rectOverlay = [CAShapeLayer layer];
        _rectOverlay.fillRule = kCAFillRuleEvenOdd;
        _rectOverlay.fillColor = [UIColor clearColor].CGColor;
        _rectOverlay.strokeColor = [UIColor whiteColor].CGColor;
        _rectOverlay.lineWidth = 2.0f;
    }
    if (!_rectOverlay.superlayer) {
        self.layer.masksToBounds = YES;
        [self.layer addSublayer:_rectOverlay];
    }
    
    JXQuadrangleFeature qf = [JXQudrangle getQuadrangleFeatureWithPreviewRect:self.frame extentImageRect:extentImageRect reactangleFeature:rectangleFeature];
    
    UIBezierPath *path = [JXQudrangle getQuadranglePathWithQuadrangle:qf];
    UIBezierPath *rectPath  = [UIBezierPath bezierPathWithRect:CGRectMake(-5,
                                                                          -5,
                                                                          self.frame.size.width + 10,
                                                                          self.frame.size.height + 10)];
    [rectPath setUsesEvenOddFillRule:YES];
    [rectPath appendPath:path];
    _rectOverlay.path = rectPath.CGPath;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if (!_isCaptureFirstFrame) {
        _isCaptureFirstFrame = YES;
    }
    
    if (_forceStopDetect || _isStopped || _isCapturing || !CMSampleBufferIsValid(sampleBuffer)) return;
    
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    
    image = [self filteredImageUsingContrastFilterOnImage:image];
    
    if (_doucumentDetectFrame) {
        NSArray <CIFeature *> *features = [[self documentBorderDetector] featuresInImage:image];
        _documentDetectLastRectangleFeature = [self biggestRectangleInRectangles:features];
        _doucumentDetectFrame = NO;
    }
    
    if (_documentDetectLastRectangleFeature) {
        _imageDetectionConfidence += 0.5;
        
        if (doucmentDetectionConfidenceHighEnough(_imageDetectionConfidence)) {
            [self _drawBorderDetectRectWithExtentImageRect:image.extent rectangleFeature:_documentDetectLastRectangleFeature];
        }
        
    } else {
        
        _imageDetectionConfidence = 0.0f;
        
        if (_rectOverlay) {
            _rectOverlay.path = nil;
        }
    }
    
    if (self.context && _coreImageContext) {
        
        glClearColor(0.0f, 0.0f, 0.1f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        [_coreImageContext drawImage:image inRect:self.bounds fromRect:image.extent];
        [self.context presentRenderbuffer:GL_RENDERBUFFER];
        
        [_glkView setNeedsDisplay];
        
    }
}


#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_entereBackgroundMode) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_enterForegroundMode) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    glDeleteRenderbuffers(1, &_renderBuffer);
    _renderBuffer = 0;
    [EAGLContext setCurrentContext:nil];
}

#pragma mark - notification method
- (void)_entereBackgroundMode {
    _forceStopDetect = YES;
}

- (void)_enterForegroundMode {
    _forceStopDetect = NO;
}

#pragma mark - getter and setter
- (CIDetector *)documentBorderDetector {
    static dispatch_once_t onceToken;
    static CIDetector *detector = nil;
    dispatch_once(&onceToken, ^{
        detector = [CIDetector detectorOfType:CIDetectorTypeRectangle context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh,
                                                                                            CIDetectorAspectRatio: @(0.8)
                                                                                            }];
    });
    return detector;
}


#pragma mark - filter image method
- (CIImage *)filteredImageUsingEnhanceFilterOnImage:(CIImage *)image {
    return [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, image, @"inputBrightness", [NSNumber numberWithFloat:0.0], @"inputContrast", [NSNumber numberWithFloat:1.14], @"inputSaturation", [NSNumber numberWithFloat:0.0], nil].outputImage;
}

- (CIImage *)filteredImageUsingContrastFilterOnImage:(CIImage *)image {
    
    return [CIFilter filterWithName:@"CIColorControls" withInputParameters:@{@"inputContrast":@(1.1),kCIInputImageKey:image}].outputImage;
}

- (CIImage *)correctPerspectiveForImage:(CIImage *)image withFeatures:(CIRectangleFeature *)rectangleFeature {
    NSMutableDictionary *rectangleCoordinates = [NSMutableDictionary new];
    rectangleCoordinates[@"inputTopLeft"] = [CIVector vectorWithCGPoint:rectangleFeature.topLeft];
    rectangleCoordinates[@"inputTopRight"] = [CIVector vectorWithCGPoint:rectangleFeature.topRight];
    rectangleCoordinates[@"inputBottomLeft"] = [CIVector vectorWithCGPoint:rectangleFeature.bottomLeft];
    rectangleCoordinates[@"inputBottomRight"] = [CIVector vectorWithCGPoint:rectangleFeature.bottomRight];
    return [image imageByApplyingFilter:@"CIPerspectiveCorrection" withInputParameters:rectangleCoordinates];
}

#pragma mark - helper method
- (CIRectangleFeature *)biggestRectangleInRectangles:(NSArray *)rectangles {
    if (![rectangles count]) return nil;
    
    float halfPerimeterValue = 0;
    
    CIRectangleFeature *biggestRectangle = [rectangles firstObject];
    
    for (CIRectangleFeature *rect in rectangles) {
        CGPoint p1 = rect.topLeft;
        CGPoint p2 = rect.topRight;
        CGFloat width = hypotf(p1.x - p2.x, p1.y - p2.y);
        
        CGPoint p3 = rect.topLeft;
        CGPoint p4 = rect.bottomLeft;
        CGFloat height = hypotf(p3.x - p4.x, p3.y - p4.y);
        
        CGFloat currentHalfPerimiterValue = height + width;
        
        if (halfPerimeterValue < currentHalfPerimiterValue) {
            halfPerimeterValue = currentHalfPerimiterValue;
            biggestRectangle = rect;
        }
    }
    
    return biggestRectangle;
}

BOOL doucmentDetectionConfidenceHighEnough(float confidence) {
    return (confidence > 1.0);
}

@end
