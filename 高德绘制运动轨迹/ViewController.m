//
//  ViewController.m
//  高德绘制运动轨迹
//
//  Created by zhangming on 17/9/5.
//  Copyright © 2017年 youjiesi. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>

#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface ViewController ()<MAMapViewDelegate> {
    
    CLLocationCoordinate2D * _runningCoords;
    NSUInteger _count;
    
    MAMultiPolyline * _polyline;
    
}

@property (nonatomic, strong) MAMapView *mapView;

@end

@implementation ViewController

- (MAMapView *)mapView{
    
    if (!_mapView) {
        
        _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
        
        _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _mapView.delegate = self;
        [self.view addSubview:self.mapView];
        
    }
    return _mapView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"绘制轨迹";
    
    //注册高德
    [AMapServices sharedServices].apiKey = @"dd3d5482d21dc9089ff7e303aa3022e5";
    
    //加载假数据
    [self initData];
    
    //添加轨迹
    [self.mapView addOverlay:_polyline];
    
    
    const CGFloat screenEdgeInset = 20;
    UIEdgeInsets inset = UIEdgeInsetsMake(screenEdgeInset, screenEdgeInset, screenEdgeInset, screenEdgeInset);
    [self.mapView setVisibleMapRect:_polyline.boundingMapRect edgePadding:inset animated:NO];
    
    //设置起点终点大头针
    [self setPointAnnotation];
}


- (void)initData
{
    
    NSData *jsdata = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"running_record" ofType:@"json"]];
    
    NSMutableArray * indexes = [NSMutableArray array];
    if (jsdata)
    {
        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:jsdata options:NSJSONReadingAllowFragments error:nil];
        
        _count = dataArray.count;
        _runningCoords = (CLLocationCoordinate2D *)malloc(_count * sizeof(CLLocationCoordinate2D));
        
        for (int i = 0; i < _count; i++)
        {
            @autoreleasepool
            {
                NSDictionary * data = dataArray[i];
                _runningCoords[i].latitude = [data[@"latitude"] doubleValue];
                _runningCoords[i].longitude = [data[@"longtitude"] doubleValue];
                
                [indexes addObject:@(i)];
            }
        }
    }
    
    _polyline = [MAMultiPolyline polylineWithCoordinates:_runningCoords count:_count drawStyleIndexes:indexes];
    
}



#pragma mark - mapview delegate
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if (overlay == _polyline)
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        
        polylineRenderer.lineWidth    = 8.f;
        polylineRenderer.strokeColor  = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.6];
        polylineRenderer.lineJoinType = kMALineJoinRound;
        polylineRenderer.lineCapType  = kMALineCapRound;
        [polylineRenderer setStrokeImage:[UIImage imageNamed:@"map_history"]];
        
        return polylineRenderer;
        
        
        
    }
    
    return nil;
}


#pragma mark - 设置起点终点大头针
- (void)setPointAnnotation{
    
    NSData *jsdata = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"running_record" ofType:@"json"]];
    
    //起点
    NSDictionary * startData = [NSDictionary dictionary];
    //终点
    NSDictionary * stopData = [NSDictionary dictionary];
    
    if (jsdata)
    {
        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:jsdata options:NSJSONReadingAllowFragments error:nil];
        
        startData = [dataArray firstObject];
        stopData = [dataArray lastObject];
        
        
    }
    
    MAPointAnnotation *startPointAnnotation = [[MAPointAnnotation alloc] init];
    startPointAnnotation.coordinate = CLLocationCoordinate2DMake([startData[@"latitude"] doubleValue], [startData[@"longtitude"] doubleValue]);
    startPointAnnotation.title = @"起点";
    [_mapView addAnnotation:startPointAnnotation];
    
    
    MAPointAnnotation *stopPointAnnotation = [[MAPointAnnotation alloc] init];
    stopPointAnnotation.coordinate = CLLocationCoordinate2DMake([stopData[@"latitude"] doubleValue], [stopData[@"longtitude"] doubleValue]);
    stopPointAnnotation.title = @"终点";
    [_mapView addAnnotation:stopPointAnnotation];
    
}

#pragma mark - 大头针回调
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        MAAnnotationView *annotationView = (MAAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:reuseIndetifier];
        }
        
        if ([annotation.title isEqualToString:@"起点"]) {
            
            annotationView.image = [UIImage imageNamed:@"icon_startAnima"];
        }else{
            
            annotationView.image = [UIImage imageNamed:@"icon_stopAnima"];
        }
        
        //设置中心点偏移，使得标注底部中间点成为经纬度对应点
        annotationView.centerOffset = CGPointMake(0, -18);
        return annotationView;
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
