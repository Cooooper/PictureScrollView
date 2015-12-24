
//  IDBPictureScrollView.h
//  PictureScrollViewDemo
//
//  Created by Han Yahui on 15/12/23.
//  Copyright © 2015年 Han Yahui. All rights reserved.
//


#define kScreenWidth self.frame.size.width
#define kScreenHeight self.frame.size.height

#define pageSize (kScreenHeight * 0.2 > 25 ? 25 : kScreenHeight * 0.2)

#import "IDBPictureScrollView.h"
#import "IDBWebImageManager.h"

@interface IDBPictureScrollView () <UIScrollViewDelegate>

@property (nonatomic,copy) NSArray *imageDatas;

@property (nonatomic,strong) UIImageView *leftImageView, *centerImageView, *rightImageView;
@property (nonatomic,strong) UILabel *leftLabel, *centerLabel, *rightLabel;

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIPageControl *pageControl;

@property (nonatomic,strong) NSTimer *timer;

@property (nonatomic,assign) NSInteger currentIndex;
@property (nonatomic,assign) NSInteger maxImageCount;

@property (nonatomic,assign) BOOL isNetwork;
@property (nonatomic,assign) BOOL hasTitle;



@end

@implementation IDBPictureScrollView

+ (instancetype)pictureScrollViewWithFrame:(CGRect)frame withImageUrls:(NSArray<NSString *> *)imageUrls {
  return  [[self alloc] initWithFrame:frame withImageUrls:imageUrls];
}

- (instancetype)initWithFrame:(CGRect)frame withImageUrls:(NSArray<NSString *> *)imageNames {
  if (imageNames.count < 2) {
    return nil;
  }
  self = [super initWithFrame:frame];
  
  [self initScrollView];
  [self setImageDatas:imageNames];
  [self setMaxImageCount:_imageDatas.count];
  
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    
    [self initScrollView];
  }
  return self;
}

-(void)setDataSource:(id<IDBPictureScrollViewDataSource>)dataSource
{
  
  _dataSource = dataSource;
  
 self.imageDatas = [_dataSource imagesOfpictureScrollView:self];
  [self setMaxImageCount:_imageDatas.count];
}

- (void)setMaxImageCount:(NSInteger)maxImageCount {
  _maxImageCount = maxImageCount;
  
  [self prepareImageView];
  [self preparePageControl];
  
  [self setUpTimer];
  
  [self changeImageLeft:_maxImageCount-1 center:0 right:1];
}


- (void)imageViewDidTap {
  if (self.imageViewDidTapAtIndex != nil) {
    self.imageViewDidTapAtIndex(_currentIndex);
  }
}



- (void)initScrollView {
  
  UIScrollView *sc = [[UIScrollView alloc] initWithFrame:self.bounds];
  [self addSubview:sc];
  
  _scrollView = sc;
  _scrollView.backgroundColor = [UIColor clearColor];
  _scrollView.pagingEnabled = YES;
  _scrollView.showsHorizontalScrollIndicator = NO;
  _scrollView.delegate = self;
  _scrollView.contentSize = CGSizeMake(kScreenWidth * 3,0);
  
  _AutoScrollDelay = 2.0f;
  _currentIndex = 0;
}

- (void)prepareImageView {
  
  UIImageView *left = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,kScreenWidth, kScreenHeight)];
  UIImageView *center = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth, 0,kScreenWidth, kScreenHeight)];
  UIImageView *right = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth * 2, 0,kScreenWidth, kScreenHeight)];
  
  center.userInteractionEnabled = YES;
  [center addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDidTap)]];
  
  [_scrollView addSubview:left];
  [_scrollView addSubview:center];
  [_scrollView addSubview:right];

  _leftImageView   = left;
  _centerImageView = center;
  _rightImageView  = right;
  
}

- (void)preparePageControl {
  
  UIPageControl *page = [[UIPageControl alloc] initWithFrame:CGRectMake(0,kScreenHeight - pageSize,kScreenWidth, 7)];
  
  page.pageIndicatorTintColor        = [UIColor lightGrayColor];
  page.currentPageIndicatorTintColor = [UIColor whiteColor];
  page.numberOfPages                 = _maxImageCount;
  page.currentPage                   = 0;
  
  [self addSubview:page];
  
  _pageControl = page;
}

- (void)setStyle:(IDBPageControlStyle)style {
  
  if (style == IDBPageControlStyleRight) {
    CGFloat w = _maxImageCount * 17.5;
    _pageControl.frame = CGRectMake(0, 0, w, 7);
    _pageControl.center = CGPointMake(kScreenWidth-w*0.5, kScreenHeight-pageSize * 0.5);
  }
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
  _pageControl.pageIndicatorTintColor = pageIndicatorTintColor;
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
  _pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor;
}


-(void)setTitles:(NSArray<NSString *> *)titles
{
  if (titles.count < 2)  return;
  
  if (titles.count < _imageDatas.count) {
    NSMutableArray *temp = [NSMutableArray arrayWithArray:titles];
    for (int i = 0; i < _imageDatas.count - titles.count; i++) {
      [temp addObject:@""];
    }
    _titles = temp;
  }else {
    
    _titles = titles;
  }
  
  [self prepareTitleLabel];
  _hasTitle = YES;
  [self changeImageLeft:_maxImageCount-1 center:0 right:1];
}


- (void)prepareTitleLabel {
  
  [self setStyle:IDBPageControlStyleRight];
  
  UIView *left   = [self creatLabelBgView];
  UIView *center = [self creatLabelBgView];
  UIView *right  = [self creatLabelBgView];
  
  _leftLabel   = (UILabel *)left.subviews.firstObject;
  _centerLabel = (UILabel *)center.subviews.firstObject;
  _rightLabel  = (UILabel *)right.subviews.firstObject;
  
  [_leftImageView addSubview:left];
  [_centerImageView addSubview:center];
  [_rightImageView addSubview:right];
  
}


- (UIView *)creatLabelBgView {
  
  UIToolbar *v = [[UIToolbar alloc] initWithFrame:CGRectMake(0, kScreenHeight-pageSize, kScreenWidth, pageSize)];
  
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth-_pageControl.frame.size.width,pageSize)];
  label.textAlignment   = NSTextAlignmentLeft;
  label.backgroundColor = [UIColor clearColor];
  label.textColor       = [[UIColor alloc] initWithWhite:0.5 alpha:1];
  label.font            = [UIFont systemFontOfSize:pageSize*0.5];
  
  [v addSubview:label];
  
  return v;
}

- (void)setTextColor:(UIColor *)textColor {
  _leftLabel.textColor   = textColor;
  _rightLabel.textColor  = textColor;
  _centerLabel.textColor = textColor;
}

- (void)setFont:(UIFont *)font {
  _leftLabel.font   = font;
  _rightLabel.font  = font;
  _centerLabel.font = font;
}

#pragma mark scrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  [self setUpTimer];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  [self removeTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [self changeImageWithOffset:scrollView.contentOffset.x];
}


- (void)changeImageWithOffset:(CGFloat)offsetX {
  
  if (offsetX >= kScreenWidth * 2) {
    _currentIndex++;
    
    if (_currentIndex == _maxImageCount-1) {
      
      [self changeImageLeft:_currentIndex-1 center:_currentIndex right:0];
      
    }else if (_currentIndex == _maxImageCount) {
      
      _currentIndex = 0;
      [self changeImageLeft:_maxImageCount-1 center:0 right:1];
      
    }else {
      [self changeImageLeft:_currentIndex-1 center:_currentIndex right:_currentIndex+1];
    }
    _pageControl.currentPage = _currentIndex;
    
  }
  
  if (offsetX <= 0) {
    _currentIndex--;
    
    if (_currentIndex == 0) {
      
      [self changeImageLeft:_maxImageCount-1 center:0 right:1];
      
    }else if (_currentIndex == -1) {
      
      _currentIndex = _maxImageCount-1;
      [self changeImageLeft:_currentIndex-1 center:_currentIndex right:0];
      
    }else {
      [self changeImageLeft:_currentIndex-1 center:_currentIndex right:_currentIndex+1];
    }
    
    _pageControl.currentPage = _currentIndex;
  }
  
}

- (void)changeImageLeft:(NSInteger)LeftIndex center:(NSInteger)centerIndex right:(NSInteger)rightIndex {
  
  if (_isNetwork) {
    
    _leftImageView.image   = [self setImageWithIndex:LeftIndex];
    _centerImageView.image = [self setImageWithIndex:centerIndex];
    _rightImageView.image  = [self setImageWithIndex:rightIndex];
    
  }else {
    
    _leftImageView.image   = _imageDatas[LeftIndex];
    _centerImageView.image = _imageDatas[centerIndex];
    _rightImageView.image  = _imageDatas[rightIndex];
    
  }
  
  if (_hasTitle) {
    
    _leftLabel.text   = _titles[LeftIndex];
    _centerLabel.text = _titles[centerIndex];
    _rightLabel.text  = _titles[rightIndex];
    
  }
  
  [_scrollView setContentOffset:CGPointMake(kScreenWidth, 0)];
}

-(void)setPlaceImage:(UIImage *)placeImage {
  _placeImage = placeImage;
  [self changeImageLeft:_maxImageCount-1 center:0 right:1];
}

- (UIImage *)setImageWithIndex:(NSInteger)index {
  
  //从内存缓存中取,如果没有使用占位图片
  UIImage *image = [[[IDBWebImageManager shareManager] webImageCache] valueForKey:_imageDatas[index]];
  
  return image ? image : _placeImage;
}


- (void)scorll {
  [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x + kScreenWidth, 0) animated:YES];
}

- (void)setAutoScrollDelay:(NSTimeInterval)AutoScrollDelay {
  _AutoScrollDelay = AutoScrollDelay;
  [self removeTimer];
  [self setUpTimer];
}

- (void)setUpTimer {
  if (_AutoScrollDelay < 0.5) return;
  
  _timer = [NSTimer timerWithTimeInterval:_AutoScrollDelay target:self selector:@selector(scorll) userInfo:nil repeats:YES];
  [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)removeTimer {
  if (_timer == nil) return;
  [_timer invalidate];
  _timer = nil;
}

- (void)setImageDatas:(NSArray *)ImageNames {
  
  _isNetwork = [ImageNames.firstObject hasPrefix:@"http://"] || [ImageNames.firstObject hasPrefix:@"https://"];
  
  if (_isNetwork) {
    
    _imageDatas = [ImageNames copy];
    
    [self getImage];
    
  }else {
    
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:ImageNames.count];
    
    for (NSString *name in ImageNames) {
      [temp addObject:[UIImage imageNamed:name]];
    }
    
    _imageDatas = [temp copy];
  }
  
}


- (void)getImage {
  
  for (NSString *urlSting in _imageDatas) {
    [[IDBWebImageManager shareManager] downloadImageWithUrlString:urlSting];
  }
  
}

-(void)dealloc {
  [self removeTimer];
}

//
//- (void)getImage {
//
//    SDWebImageManager *manager = [SDWebImageManager sharedManager];
//
//    for (NSString *urlString in _imageData) {
//
//        [manager downloadImageWithURL:[NSURL URLWithString:urlString] options:SDWebImageHighPriority progress:NULL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//            if (error) {
//                NSLog(@"%@",error);
//            }
//        }];
//    }
//
//}
//- (UIImage *)setImageWithIndex:(NSInteger)index {
//
//  UIImage *image =
//    [[[SDWebImageManager sharedManager] imageCache] imageFromMemoryCacheForKey:_imageData[index]];
//    if (image) {
//        return image;
//    }else {
//        return _placeImage;
//    }
//
//}







@end

