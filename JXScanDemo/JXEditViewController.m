//
//  JXEditViewController.m
//  JXScanDemo
//
//  Created by zl on 2018/7/23.
//  Copyright © 2018年 longjianjiang. All rights reserved.
//

#import "JXEditViewController.h"
#import "JXScan/View/JXDocumentEditView.h"


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
    
    [self.view addSubview:self.editView];
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
