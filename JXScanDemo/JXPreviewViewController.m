//
//  JXPreviewViewController.m
//  JXScanDemo
//
//  Created by zl on 2018/7/25.
//  Copyright © 2018年 longjianjiang. All rights reserved.
//

#import "JXPreviewViewController.h"

@interface JXPreviewViewController ()

@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation JXPreviewViewController

#pragma mark - life cycle
- (instancetype)initWithPreviewImage:(UIImage *)previewImage {
    self = [super init];
    if (self) {
        self.previewImage = previewImage;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
   
     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"rotate" style:UIBarButtonItemStylePlain target:self action:@selector(rotate)];
    
    [self.view addSubview:self.imageView];
}

#pragma mark - response method
- (void)rotate {
}

#pragma mark - getter and setter
- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.image = self.previewImage;
    }
    return _imageView;
}

@end
