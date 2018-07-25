//
//  JXDocumentEditView.m
//  JXScanDemo
//
//  Created by zl on 2018/7/23.
//  Copyright © 2018年 longjianjiang. All rights reserved.
//

#import "JXDocumentEditView.h"

#import "JXEditCornerView.h"
#import "JXPreviewEditCornerView.h"

static NSInteger const kPreviewWidth = 100;

@interface JXDocumentEditView ()

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) JXQuadrangleFeature borderRectangle;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) CAShapeLayer *borderShapeLayer;

@property (nonatomic, strong) JXEditCornerView *topLeftCornerButton;
@property (nonatomic, strong) JXEditCornerView *topRightCornerButton;
@property (nonatomic, strong) JXEditCornerView *bottomRightCornerButton;
@property (nonatomic, strong) JXEditCornerView *bottomLeftCornerButton;


@property (nonatomic, strong) JXPreviewEditCornerView *previewCornerView;

@end


@implementation JXDocumentEditView

#pragma mark - public method
- (UIImage *)getCutImage {
    
    NSData *imageData = UIImageJPEGRepresentation(self.image, 1.0);
    CIImage *enhancedImage = [CIImage imageWithData:imageData];
    enhancedImage = [self filteredImageUsingContrastFilterOnImage:enhancedImage];
    
    CGRect imageRect = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    CGRect extentRect = CGRectMake(0, 0, 750, 1000);
    
    CGFloat delta1 = CGRectGetWidth(extentRect)/CGRectGetWidth(self.bounds);
    CGFloat delta2 = CGRectGetHeight(extentRect)/CGRectGetHeight(self.bounds);
    
    CGFloat deltaX = CGRectGetWidth(enhancedImage.extent)/CGRectGetWidth(self.bounds);
    CGFloat deltaY = CGRectGetHeight(enhancedImage.extent)/CGRectGetHeight(self.bounds);
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0.f, CGRectGetHeight(enhancedImage.extent));
    transform = CGAffineTransformScale(transform, 1, -1); // when UIKit coordinate this line should not be executed
    
    transform = CGAffineTransformScale(transform, deltaX, deltaY);
   
    JXQuadrangleFeature qf = [JXQudrangle getNewQuadrangleWithQuadrangle:self.borderRectangle transform:transform];

    enhancedImage = [self correctPerspectiveForImage:enhancedImage withFeatures:qf];
    
    UIGraphicsBeginImageContext(CGSizeMake(enhancedImage.extent.size.height, enhancedImage.extent.size.width));
    [[UIImage imageWithCIImage:enhancedImage scale:1.0 orientation:UIImageOrientationRight] drawInRect:CGRectMake(0,0, enhancedImage.extent.size.height, enhancedImage.extent.size.width)];
    UIImage *cutImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return cutImage;
}

- (CIImage *)filteredImageUsingContrastFilterOnImage:(CIImage *)image {
    
    return [CIFilter filterWithName:@"CIColorControls" withInputParameters:@{@"inputContrast":@(1.1),kCIInputImageKey:image}].outputImage;
}

- (CIImage *)correctPerspectiveForImage:(CIImage *)image withFeatures:(JXQuadrangleFeature)rectangleFeature {
    NSMutableDictionary *rectangleCoordinates = [NSMutableDictionary new];
    rectangleCoordinates[@"inputTopLeft"] = [CIVector vectorWithCGPoint:rectangleFeature.topLeft];
    rectangleCoordinates[@"inputTopRight"] = [CIVector vectorWithCGPoint:rectangleFeature.topRight];
    rectangleCoordinates[@"inputBottomLeft"] = [CIVector vectorWithCGPoint:rectangleFeature.bottomLeft];
    rectangleCoordinates[@"inputBottomRight"] = [CIVector vectorWithCGPoint:rectangleFeature.bottomRight];
    return [image imageByApplyingFilter:@"CIPerspectiveCorrection" withInputParameters:rectangleCoordinates];
}
#pragma mark - life cycle
- (instancetype)init {
    NSCAssert(NO, @"Use -initWithOriginalImage:borderRectangle: instead");
    return nil;
}

- (instancetype)initWithOriginalImage:(UIImage *)originalImage borderRectangle:(JXQuadrangleFeature)borderRectangle {
    self = [super init];
    if (self) {
        self.borderRectangle = borderRectangle;
        self.image = originalImage;
        [self setupSubview];
        [self addSomeConstraints];
    }
    return self;
}

- (void)setupCornerButtons {
    [self addSubview:self.topLeftCornerButton];
    [self addSubview:self.topRightCornerButton];
    [self addSubview:self.bottomRightCornerButton];
    [self addSubview:self.bottomLeftCornerButton];
}

- (void)setupSubview {
    [self addSubview:self.imageView];
    self.layer.masksToBounds = YES;
    [self.layer addSublayer:self.borderShapeLayer];
    
    [self drawQuadrangleWithQF:self.borderRectangle];
    
    [self setupCornerButtons];
}


- (void)addSomeConstraints {
    [[self.imageView.topAnchor constraintEqualToAnchor:self.topAnchor] setActive:YES];
    [[self.imageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
    [[self.imageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor] setActive:YES];
    [[self.imageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor] setActive:YES];
    
    CGFloat buttonSize = 20;
    CGFloat cornerRadius = buttonSize / 2.0;
    
    self.topLeftCornerButton.frame = CGRectMake(self.borderRectangle.topLeft.x - buttonSize / 2.0,
                                                self.borderRectangle.topLeft.y - buttonSize / 2.0,
                                                buttonSize,
                                                buttonSize);
    self.topLeftCornerButton.layer.cornerRadius = cornerRadius;
    
    self.topRightCornerButton.frame = CGRectMake(self.borderRectangle.topRight.x - buttonSize / 2.0,
                                                self.borderRectangle.topRight.y - buttonSize / 2.0,
                                                buttonSize,
                                                buttonSize);
    self.topRightCornerButton.layer.cornerRadius = cornerRadius;
    
    self.bottomRightCornerButton.frame = CGRectMake(self.borderRectangle.bottomRight.x - buttonSize / 2.0,
                                                self.borderRectangle.bottomRight.y - buttonSize / 2.0,
                                                buttonSize,
                                                buttonSize);
    self.bottomRightCornerButton.layer.cornerRadius = cornerRadius;
    
    self.bottomLeftCornerButton.frame = CGRectMake(self.borderRectangle.bottomLeft.x - buttonSize / 2.0,
                                                self.borderRectangle.bottomLeft.y - buttonSize / 2.0,
                                                buttonSize,
                                                buttonSize);
    self.bottomLeftCornerButton.layer.cornerRadius = cornerRadius;
}

- (void)drawQuadrangleWithQF:(JXQuadrangleFeature)qf {
    UIBezierPath *path = [JXQudrangle getQuadranglePathWithQuadrangle:qf];

    UIBezierPath *rectPath  = [UIBezierPath bezierPathWithRect:CGRectMake(-5,
                                                                          -5,
                                                                          self.frame.size.width + 10,
                                                                          self.frame.size.height + 10)];
    [rectPath setUsesEvenOddFillRule:YES];
    [rectPath appendPath:path];
    self.borderShapeLayer.path = rectPath.CGPath;
}

- (void)drawPreviewCornerViewWithCenter:(CGPoint)center {
    CGRect previewRect = [self getPreviewRectWithPoint:center];
    UIImage *previewImage = [self getClipImageInView:self.imageView withFrame:previewRect];

    [self.previewCornerView updatePreviewWithPreviewImage:previewImage];
}


#pragma mark - gesture method
- (void)dragCorner:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.previewCornerView removeFromSuperview];
        self.previewCornerView = nil;
        return;
    } else {
        if (_previewCornerView == nil) {
            [self addSubview:self.previewCornerView];
        }
    }
    
    JXEditCornerView *cornerBtn = (JXEditCornerView *)gesture.view;
    
    CGPoint center = [gesture locationInView:self];
    center = [self validatePoint:center forCornerButtonSize:cornerBtn.bounds.size inView:self];
    
    gesture.view.center = center;
    JXQuadrangleFeature updatedQF = [self updateQuadrangle:self.borderRectangle updatePosition:center cornerPosition:cornerBtn.position];
    
    self.borderRectangle = updatedQF;
    
    [self drawQuadrangleWithQF:updatedQF];
    [self drawPreviewCornerViewWithCenter:center];
}


#pragma mark - helper method
- (UIImage *)getClipImageInView:(UIView *)inView withFrame:(CGRect)frame {
    UIGraphicsBeginImageContext(inView.bounds.size);
    [inView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef img = [viewImage CGImage];
    img = CGImageCreateWithImageInRect(img, frame);  // This is the specific frame size whatever you want to take scrrenshot
    viewImage = [UIImage imageWithCGImage:img];
    /*
    UIGraphicsBeginImageContext(inView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    UIRectClip(frame);
    [inView.layer renderInContext:context];
    UIImage *aImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return aImage;
     */
    
    return viewImage;
}


- (CGRect)getPreviewRectWithPoint:(CGPoint)point {
    return CGRectMake(point.x - kPreviewWidth / 2.0,
                      point.y - kPreviewWidth / 2.0,
                      kPreviewWidth,
                      kPreviewWidth);
}


- (CGPoint)validatePoint:(CGPoint)point forCornerButtonSize:(CGSize)cornerViewSize inView:(UIView *)view {
    CGPoint validPoint = point;
    
    if (point.x > view.bounds.size.width) {
        validPoint.x = view.bounds.size.width;
    } else if (point.x < 0) {
        validPoint.x = 0;
    }
    
    if (point.y > view.bounds.size.height) {
        validPoint.y = view.bounds.size.height;
    } else if (point.y < 0) {
        validPoint.y = 0;
    }
    
    return validPoint;
}

- (JXQuadrangleFeature)updateQuadrangle:(JXQuadrangleFeature)borderRectangle updatePosition:(CGPoint)position cornerPosition:(JXCorderPosition)cornerPosition {
    
    JXQuadrangleFeature qf = borderRectangle;
    
    switch (cornerPosition) {
        case JXCorderPositionTopLeft:
            qf.topLeft = position;
            break;
        case JXCorderPositionTopRight:
            qf.topRight = position;
            break;
        case JXCorderPositionBottomRight:
            qf.bottomRight = position;
            break;
        case JXCorderPositionBottomLeft:
            qf.bottomLeft = position;
            break;
    }
    
    return qf;
}



#pragma mark - getter and setter
- (JXEditCornerView *)topLeftCornerButton {
    if (_topLeftCornerButton == nil) {
        _topLeftCornerButton = [self getCornerButton:JXCorderPositionTopLeft];
    }
    return _topLeftCornerButton;
}

- (JXEditCornerView *)topRightCornerButton {
    if (_topRightCornerButton == nil) {
        _topRightCornerButton = [self getCornerButton:JXCorderPositionTopRight];
    }
    return _topRightCornerButton;
}

- (JXEditCornerView *)bottomRightCornerButton {
    if (_bottomRightCornerButton == nil) {
        _bottomRightCornerButton = [self getCornerButton:JXCorderPositionBottomRight];
    }
    return _bottomRightCornerButton;
}

- (JXEditCornerView *)bottomLeftCornerButton {
    if (_bottomLeftCornerButton == nil) {
        _bottomLeftCornerButton = [self getCornerButton:JXCorderPositionBottomLeft];
    }
    return _bottomLeftCornerButton;
}

- (JXEditCornerView *)getCornerButton:(JXCorderPosition)position {
    JXEditCornerView *button = [[JXEditCornerView alloc] initWithCorderPosition:position];
    button.backgroundColor = [UIColor whiteColor];
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOffset = CGSizeMake(0, 0);
    button.layer.shadowRadius = 3.0;
    button.layer.shadowOpacity = 0.5;
    button.layer.masksToBounds = NO;
    
    UIPanGestureRecognizer *dragCornerGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragCorner:)];
    [button addGestureRecognizer:dragCornerGesture];
    
    return button;
}

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

- (JXPreviewEditCornerView *)previewCornerView {
    if (_previewCornerView == nil) {
        _previewCornerView = [[JXPreviewEditCornerView alloc] initWithFrame:CGRectMake(0, 70, 100, 100)];
    }
    return _previewCornerView;
}
@end
