//
//  JXEditViewController.m
//  JXScanDemo
//
//  Created by zl on 2018/7/23.
//  Copyright © 2018年 longjianjiang. All rights reserved.
//

#import "JXEditViewController.h"
#import "JXScan/View/JXDocumentEditView.h"

#import "JXPreviewViewController.h"

@interface JXEditViewController ()

@property (nonatomic, strong) JXDocumentEditView *editView;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) JXQuadrangleFeature rectangleFeature;

@end

@implementation JXEditViewController

- (instancetype)initWithOriginalImage:(UIImage *)originalImage borderRectangle:(JXQuadrangleFeature)borderRectangle {
    self = [super init];
    if (self) {
        self.image = originalImage;
        self.rectangleFeature = borderRectangle;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"done" style:UIBarButtonItemStylePlain target:self action:@selector(goPreview)];
    
    [self.view addSubview:self.editView];
}

#pragma mark - response method
- (void)goPreview {
    UIImage *cutImage = [self.editView getCutImage];
    
    JXPreviewViewController *previewVC = [[JXPreviewViewController alloc] initWithPreviewImage:cutImage];
    
    [self.navigationController pushViewController:previewVC animated:YES];
}

#pragma mark - getter and setter
- (JXDocumentEditView *)editView {
    if (_editView == nil) {
        _editView = [[JXDocumentEditView alloc] initWithOriginalImage:self.image borderRectangle:self.rectangleFeature];
        _editView.frame = self.view.bounds;
    }
    return _editView;
}
@end
