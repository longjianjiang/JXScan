//
//  JXDocumentEditView.h
//  JXScanDemo
//
//  Created by zl on 2018/7/23.
//  Copyright © 2018年 longjianjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXQuadrangle.h"


@interface JXDocumentEditView : UIView

- (instancetype)initWithOriginalImage:(UIImage *)originalImage borderRectangle:(JXQuadrangleFeature)borderRectangle;

@end

