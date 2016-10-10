//
//  DJLineGraphViewController.m
//  MyLineGraph
//
//  Created by djlovettt on 16/10/8.
//  Copyright © 2016年 djlovettt. All rights reserved.
//

#import "DJLineGraphViewController.h"

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

#define pointDiameter 6 //折线转折点的直径

@interface DJLineGraphViewController ()
{
    //坐标系上的背景视图
    UIView *bgView;
    //用于 X轴方向上的滚动
    UIScrollView *djScrollView;
    
    //Y轴的高度
    CGFloat lineHeight;
    //单位数据的高度
    CGFloat perHeight;
    //记录每条折线上各点的坐标信息
    NSMutableArray *recordScorePoints;
}
@end

@implementation DJLineGraphViewController

//界面出现时，置为横屏
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
}

//界面消失时，取消横屏
- (void)viewWillDisappear:(BOOL)animated {
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"成绩分布图";
    [self initDJLineAxes];
}

//初始化折线图的坐标轴
- (void)initDJLineAxes {
    //因采用横屏，故以屏幕宽度作为高度的基准
    lineHeight = kWidth - 100 - 44;
    NSLog(@"lineHeight === %.2f",lineHeight);
    
    //绘制 Y轴
    CALayer *YLine = [CALayer new];
    YLine.frame = CGRectMake(50, 50, 2, lineHeight + 2);
    YLine.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.view.layer addSublayer:YLine];
    
    //绘制 Y轴上的单位
    UILabel *YUnit = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 48, 20)];
    YUnit.text = @"成绩/分";
    YUnit.font = [UIFont systemFontOfSize:12.f];
    YUnit.textAlignment = NSTextAlignmentCenter;
    YUnit.textColor = [UIColor lightGrayColor];
    [self.view addSubview:YUnit];
    //绘制 Y轴上的数值
    [self setYValues];
    
    //绘制 X轴
    djScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(50, 50, kHeight - 90, kWidth - 50 - 44)];
    djScrollView.bounces = NO;
    djScrollView.showsVerticalScrollIndicator   = NO;
    djScrollView.showsHorizontalScrollIndicator = NO;
    djScrollView.contentSize = CGSizeMake(25 * 24, 0);
    [self.view addSubview:djScrollView];
    
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25 * 24, kWidth - 100 - 44)];
    [djScrollView addSubview:bgView];
    
    CALayer *XLine = [CALayer new];
    XLine.frame = CGRectMake(0, kWidth - 100 - 44, 50 * 24, 2);
    XLine.backgroundColor = [UIColor lightGrayColor].CGColor;
    [djScrollView.layer addSublayer:XLine];
    
    //绘制 X轴上的单位
    UILabel *XUnit = [[UILabel alloc] initWithFrame:CGRectMake(kHeight - 50, kWidth - 44 - 30, 50, 20)];
    XUnit.text = @"编号";
    XUnit.textColor = [UIColor lightGrayColor];
    XUnit.font = [UIFont systemFontOfSize:12.f];
    XUnit.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:XUnit];
    //绘制 X轴上的数值
    [self setXValues];
    
    //开始绘制
    [self drawDJLineGraph];
}

- (void)setYValues {
    NSArray *valuesArr = @[@"100",@"90",@"80",@"70",@"60",@"50",@"40",@"30",@"20",@"10",@"0"];
    for (int i = 0; i < valuesArr.count; i++) {
        UILabel *YValue = [[UILabel alloc] initWithFrame:CGRectMake(0, lineHeight/valuesArr.count * (i + 1) + 50 - 10, 50, 20)];
        YValue.text = valuesArr[i];
        YValue.font = [UIFont systemFontOfSize:12.f];
        YValue.textAlignment = NSTextAlignmentCenter;
        YValue.textColor = [UIColor lightGrayColor];
        [self.view addSubview:YValue];
    }
}

- (void)setXValues {
    for (int i = 0; i < 24; i++) {
        NSString *values = [NSString stringWithFormat:@"%d",i + 1];
        UILabel  *XValues = [[UILabel alloc] initWithFrame:CGRectMake(25 + 25 * i, kWidth - 50 - 44 - 44, 25, 20)];
        XValues.text = values;
        XValues.textAlignment = NSTextAlignmentLeft;
        XValues.textColor = [UIColor lightGrayColor];
        XValues.font = [UIFont systemFontOfSize:12.f];
        [djScrollView addSubview:XValues];
    }
}

- (void)drawDJLineGraph {
    //设置最大成绩时的高度，作为参照基准
    CGFloat maxHeight = lineHeight * 10 / 11;
    //设置单位数值时的高度
    perHeight = maxHeight / 100;
    
    //绘制多组折线
    recordScorePoints = [NSMutableArray new];
    NSArray *firScoresArr = @[@"75",@"82",@"70",@"95",@"68",@"78",@"100",@"85" ,@"70",@"55",@"10",@"96" ,@"75",@"65",@"60",@"50"];
    NSArray *secScoresArr = @[@"60",@"92",@"30",@"87",@"86",@"95",@"85" ,@"100",@"99",@"89",@"92",@"76" ,@"81",@"86",@"92",@"94"];
    NSArray *thrScoresArr = @[@"85",@"72",@"80",@"84",@"83",@"98",@"100",@"40" ,@"79",@"85",@"85",@"100",@"74",@"68",@"99",@"85"];
    
    [self drawLineGraphWithData:firScoresArr withLineColor:[UIColor lightGrayColor]];
    [self drawLineGraphWithData:secScoresArr withLineColor:[UIColor greenColor]];
    [self drawLineGraphWithData:thrScoresArr withLineColor:[UIColor redColor]];
}

/**
 *  绘制折线图
 *
 *  @param dataArr 数据源
 *  @param djColor 折线及折线转折点的颜色
 */
- (void)drawLineGraphWithData:(NSArray *)dataSource withLineColor:(UIColor *)djColor{
    //每次执行该方法时，先清空之前保留的点的数据
    [recordScorePoints removeAllObjects];
    
    for (int i = 0; i < dataSource.count; i++) {
        CGPoint scorePoint = CGPointMake(25 + 25 * i, lineHeight - perHeight * [dataSource[i] integerValue]);
        NSLog(@"x === %f,y === %f",scorePoint.x,scorePoint.y);
        
        CALayer *djPointLayer = [CALayer new];
        //使折线转折点的中心位于折线转折处的中心位置
        NSInteger pointOffset = pointDiameter / 2;
        djPointLayer.frame = CGRectMake(scorePoint.x - pointOffset, scorePoint.y - pointOffset, pointDiameter, pointDiameter);
        djPointLayer.cornerRadius  = pointDiameter / 2.0;
        djPointLayer.masksToBounds = YES;
        djPointLayer.backgroundColor = djColor.CGColor;
        [bgView.layer addSublayer:djPointLayer];
        
        //将 CGPoint存入数组
        [recordScorePoints addObject:NSStringFromCGPoint(scorePoint)];
    }
    for (int i = 0; i < recordScorePoints.count - 1; i++) {
        //从数组中取出 CGPoint
        CGPoint firstPoint = CGPointFromString(recordScorePoints[i]);
        CGPoint nextPoint  = CGPointFromString(recordScorePoints[i + 1]);
        
        UIBezierPath *djPath = [UIBezierPath bezierPath];
        [djPath moveToPoint:firstPoint];
        [djPath addLineToPoint:nextPoint];
        
        CAShapeLayer *lineLayer = [CAShapeLayer layer];
        lineLayer.fillColor = [UIColor clearColor].CGColor;
        lineLayer.path = djPath.CGPath;
        lineLayer.strokeColor = djColor.CGColor;
        lineLayer.lineCap  = kCALineCapRound;
        lineLayer.lineJoin = kCALineJoinBevel;
        [bgView.layer addSublayer:lineLayer];
    }
}

@end
