//
//  ViewController.m
//  DCWebPicScrollView
//
//  Created by dengchen on 15/12/4.
//  Copyright © 2015年 name. All rights reserved.
//

#import "ViewController.h"
#import "IDBPictureScrollView.h"
#import "IDBWebImageManager.h"

@interface ViewController ()<IDBPictureScrollViewDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor whiteColor];
  
  [self demo1];
  
  [self demo2];
}

- (void)demo1 {
  
  //网络加载
  
  NSArray *UrlStringArray = @[@"http://a.hiphotos.baidu.com/image/pic/item/a08b87d6277f9e2f875fbad61a30e924b999f382.jpg",
                              @"http://img.kutoo8.com//upload/image/78018037/201305280911_960x540.jpg",
                              @"http://www.xiaoxiongbizhi.com/wallpapers/__85/2/f/2fg40v2zs.jpg",
                              @"http://pic1a.nipic.com/2008-08-11/200881116056161_2.jpg"];
  
  
  NSArray *titleArray = [@"午夜寂寞 谁来陪我,唱一首动人的情歌.你问我说 快不快乐,唱情歌越唱越寂寞.谁明白我 想要什么,一瞬间释放的洒脱.灯光闪烁 不必啰嗦,我就是传说中的那个摇摆哥.我是摇摆哥 音乐会让我快乐,我是摇摆哥 我已忘掉了寂寞.我是摇摆哥 音乐会让我洒脱,我们一起唱这摇摆的歌" componentsSeparatedByString:@"."];
  
  
  //显示顺序和数组顺序一致
  //设置图片url数组,和滚动视图位置
  
//  IDBPictureScrollView  *picView = [IDBPictureScrollView pictureScrollViewWithFrame:CGRectMake(0, 60, self.view.frame.size.width, 250) withImageUrls:UrlStringArray];
//  
//  //显示顺序和数组顺序一致
//  //设置标题显示文本数组
  
  
  IDBPictureScrollView  *picView = [[IDBPictureScrollView alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, 250)];
  picView.dataSource = self;
  
  //显示顺序和数组顺序一致
  //设置标题显示文本数组
  
  
  picView.titles = titleArray;
  
  //占位图片,你可以在下载图片失败处修改占位图片
  
  picView.placeImage = [UIImage imageNamed:@"place.png"];
  
  //图片被点击事件,当前第几张图片被点击了,和数组顺序一致
  
  [picView setImageViewDidTapAtIndex:^(NSInteger index) {
    printf("第%zd张图片\n",index);
  }];
  
  //default is 2.0f,如果小于0.5不自动播放
  picView.AutoScrollDelay = 1.0f;
  //    picView.textColor = [UIColor redColor];
  
  [self.view addSubview:picView];
  
  //下载失败重复下载次数,默认不重复,
  [[IDBWebImageManager shareManager] setDownloadImageRepeatCount:1];
  
  //图片下载失败会调用该block(如果设置了重复下载次数,则会在重复下载完后,假如还没下载成功,就会调用该block)
  //error错误信息
  //url下载失败的imageurl
  [[IDBWebImageManager shareManager] setDownLoadImageError:^(NSError *error, NSString *url) {
    NSLog(@"%@",error);
  }];
}

- (NSArray <NSString *> *)imagesOfpictureScrollView:(IDBPictureScrollView *)scrollView
{
  NSArray *UrlStringArray = @[@"http://a.hiphotos.baidu.com/image/pic/item/a08b87d6277f9e2f875fbad61a30e924b999f382.jpg",
                              @"http://img.kutoo8.com//upload/image/78018037/201305280911_960x540.jpg",
                              @"http://www.xiaoxiongbizhi.com/wallpapers/__85/2/f/2fg40v2zs.jpg",
                              @"http://pic1a.nipic.com/2008-08-11/200881116056161_2.jpg"];
  return UrlStringArray;
}


//本地加载只要放图片名数组就行了

-(void)demo2 {
  
  NSMutableArray *arr2 = [[NSMutableArray alloc] init];
  
  NSMutableArray *arr3 = [[NSMutableArray alloc] init];
  
  for (int i = 1; i < 8; i++) {
    [arr2 addObject:[NSString stringWithFormat:@"%d.jpg",i]];
    [arr3 addObject:[NSString stringWithFormat:@"我是第%d张图片啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊",i]];
  };
  
  
  IDBPictureScrollView  *picView1 = [IDBPictureScrollView pictureScrollViewWithFrame:CGRectMake(0,350,self.view.frame.size.width, 250) withImageUrls:arr2];
  
  picView1.titles = arr3;
  
  picView1.backgroundColor = [UIColor clearColor];
  [picView1 setImageViewDidTapAtIndex:^(NSInteger index) {
    printf("你点到我了😳index:%zd\n",index);
  }];
  
  picView1.AutoScrollDelay = 2.0f;
  
  [self.view addSubview:picView1];
}

@end
