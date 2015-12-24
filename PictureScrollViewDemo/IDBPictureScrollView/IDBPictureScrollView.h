//
//  IDBPictureScrollView.h
//  PictureScrollViewDemo
//
//  Created by Han Yahui on 15/12/23.
//  Copyright © 2015年 Han Yahui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,IDBPageControlStyle){
  
  IDBPageControlStyleCenter,
  IDBPageControlStyleRight,
};


@class IDBPictureScrollView;

@protocol IDBPictureScrollViewDataSource <NSObject>

- (NSArray <NSString *> *)imagesOfpictureScrollView:(IDBPictureScrollView *)scrollView;


@end

@interface IDBPictureScrollView : UIView

@property (nonatomic,weak) id <IDBPictureScrollViewDataSource> dataSource;

@property (nonatomic,strong) UIImage *placeImage;//占位图片

@property (nonatomic,assign) NSTimeInterval AutoScrollDelay; //default is 2.0f,如果小于0.5不自动播放

//设置PageControl位置
@property (nonatomic,assign) IDBPageControlStyle style; //default is PageControlAtCenter

@property (nonatomic,copy) NSArray<NSString *> *titles; //设置后显示label,自动设置PageControlAtRight

//图片被点击会调用该block
@property (nonatomic,copy) void(^imageViewDidTapAtIndex)(NSInteger index); //index从0开始

 
/**
 *  imageUrlString或imageName
 *  网络加载urlsring必须为http:// https://开头,
 *  本地加载只需图片名字数组
 *  @param imageUrl imagUrl
 *
 *  @return self
 */
+ (instancetype)pictureScrollViewWithFrame:(CGRect)frame withImageUrls:(NSArray<NSString *> *)imageUrls;


@property (nonatomic,strong) UIColor *pageIndicatorTintColor;

@property (nonatomic,strong) UIColor *currentPageIndicatorTintColor;

//default is [[UIColor alloc] initWithWhite:0.5 alpha:1]
@property (nonatomic,strong) UIColor *textColor;

@property (nonatomic,strong) UIFont *font;

@end
