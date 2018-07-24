//
//  JXScanViewController.m
//  JXScanDemo
//
//  Created by zl on 2018/7/23.
//  Copyright © 2018年 longjianjiang. All rights reserved.
//

#import "JXScanViewController.h"
#import "JXScan/View/JXDocumentDetectorView.h"

#import "JXEditViewController.h"

@interface JXScanViewController ()<JXDocumentDetectorViewDelegate>

@property (nonatomic, strong) JXDocumentDetectorView *detectorView;
@property (weak, nonatomic) IBOutlet UIButton *captureBtn;


@property (nonatomic, strong) UIButton *cameraBtn;

@end

@implementation JXScanViewController

#pragma mark - life cycle
- (void)setupSubview {
    
    [self.view addSubview:self.detectorView];
    [self.view addSubview:self.cameraBtn];
    
    [[self.cameraBtn.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor] setActive:YES];
    [[self.cameraBtn.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-35] setActive:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubview];
    
    [self.detectorView setupCameraView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.detectorView startDetect];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.detectorView stopDetect];
}


- (void)captureBtnDidClick:(id)sender {
    NSLog(@"capture btn did click");
   
    [self.detectorView capture];
}


#pragma mark - JXDocumentDetectorViewDelegate
- (void)jxDocumentDetectorView:(JXDocumentDetectorView *)documentDetectorView didCaptureOriginalImage:(UIImage *)originalImage cutImage:(UIImage *)cutImage borderRectangle:(JXQuadrangleFeature)borderRectangle {
    
    JXEditViewController *editVC = [[JXEditViewController alloc] initWithOriginalImage:originalImage borderRectangle:borderRectangle];
    
    [self.navigationController pushViewController:editVC animated:YES];
}
#pragma mark - getter and setter
- (JXDocumentDetectorView *)detectorView {
    if (_detectorView == nil) {
        _detectorView = [[JXDocumentDetectorView alloc] initWithFrame:self.view.bounds];
        _detectorView.delegate = self;
    }
    return _detectorView;
}

- (UIButton *)cameraBtn {
    if (_cameraBtn == nil) {
        _cameraBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _cameraBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_cameraBtn setTitle:@"capture" forState:UIControlStateNormal];
        [_cameraBtn addTarget:self action:@selector(captureBtnDidClick:) forControlEvents:UIControlEventTouchDown];
    }
    return _cameraBtn;
}
@end
