//
//  ViewController.m
//  ScaleRotateTextDemo
//
//  Created by 老司机 on 2017/4/14.
//  Copyright © 2017年 wangrui. All rights reserved.
//

#import "ViewController.h"

static NSString *DefaultText = @"Hello";
static CGFloat MaxFontSize = 40;
static CGFloat CornerRadius = 5;

@interface ViewController ()
{
    CGPoint dragStartCenter;
    CGPoint dragCenter;
    CGFloat dragStartLength;
    CGSize labelStartSize;
    CGFloat lastScale;
}

@property (nonatomic, assign) CGPoint centerPoint;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) CGRect wordingBounds;
@property (nonatomic, assign) CGFloat transformAngle;

@property (nonatomic, strong) UIView *bodyView;

@property (nonatomic, strong) UIView *textContainerView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) CAShapeLayer *dashLayer;
@property (nonatomic, strong) UIImageView *dragImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor colorWithRed:245.f/255.f
                                                green:245.f/255.f
                                                 blue:245.f/255.f
                                                alpha:1];
    self.screenWidth = CGRectGetWidth(self.view.frame);
    self.screenHeight = CGRectGetHeight(self.view.frame);
    self.fontSize = MaxFontSize;
    self.centerPoint = CGPointMake(self.screenWidth*.5f, self.screenWidth*.5f);
    self.transformAngle = 0;
    
    self.bodyView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.screenWidth, self.screenWidth)];
    self.bodyView.center = CGPointMake(self.screenWidth*.5f, self.screenHeight*.5f);
    self.bodyView.backgroundColor = [UIColor whiteColor];
    self.bodyView.clipsToBounds = YES;
    [self.view addSubview:self.bodyView];
    
    self.textContainerView = [[UIView alloc]init];
    self.textContainerView.center = CGPointMake(self.screenWidth*.5f, self.screenWidth*.5f);
    [self.bodyView addSubview:self.textContainerView];
    
    self.textLabel = [[UILabel alloc]init];
    self.textLabel.font = [UIFont systemFontOfSize:self.fontSize];
    self.textLabel.adjustsFontSizeToFitWidth = YES;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.numberOfLines = 0;
    self.textLabel.userInteractionEnabled = YES;
    [self.textContainerView addSubview:self.textLabel];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:DefaultText];
    [attributedString addAttribute:NSFontAttributeName
                             value:[UIFont systemFontOfSize:self.fontSize]
                             range:NSMakeRange(0, DefaultText.length)];
    CGRect bounds = [attributedString boundingRectWithSize:CGSizeMake(self.screenWidth, self.fontSize)
                                                   options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                   context:nil];
    self.wordingBounds = bounds;
    self.textLabel.text = DefaultText;
    self.textLabel.frame = bounds;
    self.textContainerView.bounds = bounds;
    
    self.dashLayer = [self dashLayerWithFrame:bounds];
    [self.textLabel.layer addSublayer:self.dashLayer];
    
    //拖动
    UIPanGestureRecognizer *labelPanGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(labelPanAction:)];
    [self.textLabel addGestureRecognizer:labelPanGesture];
    
    self.dragImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    self.dragImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.dragImageView.image = [UIImage imageNamed:@"drag"];
    self.dragImageView.userInteractionEnabled = YES;
    [self.bodyView addSubview:self.dragImageView];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dragPanAction:)];
    [self.dragImageView addGestureRecognizer:panGesture];
    
    [self setupDragViewWithCenterPoint:self.centerPoint];
}

- (CAShapeLayer *)dashLayerWithFrame:(CGRect)frame
{
    CAShapeLayer *dashLayer = [CAShapeLayer layer];
    dashLayer.frame = frame;
    dashLayer.path = [UIBezierPath bezierPathWithRoundedRect:frame
                                           byRoundingCorners:UIRectCornerAllCorners
                                                 cornerRadii:CGSizeMake(CornerRadius, CornerRadius)].CGPath;
    dashLayer.strokeColor = [UIColor redColor].CGColor;
    dashLayer.fillColor = nil;
    dashLayer.lineWidth = 1.f;
    dashLayer.lineCap = @"square";
    dashLayer.lineDashPattern = @[@4, @2];
    return dashLayer;
}

- (void)setupDragViewWithCenterPoint:(CGPoint)centerPoint
{
    CGFloat x = self.wordingBounds.size.width*.5f+centerPoint.x;
    CGFloat y = self.wordingBounds.size.height*.5f+centerPoint.y;
    
    CGFloat angle = self.transformAngle;
    CGFloat newX = (x-centerPoint.x)*cos(angle)-(y-centerPoint.y)*sin(angle)+centerPoint.x;
    CGFloat newY = (x-centerPoint.x)*sin(angle)+(y-centerPoint.y)*cos(angle)+centerPoint.y;
    
    self.dragImageView.center = CGPointMake(newX, newY);
}


- (void)labelPanAction:(UIPanGestureRecognizer *)gesture
{
    CGPoint centerPoint = CGPointMake(self.screenWidth*.5f, self.screenWidth*.5f);
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.textContainerView.bounds = CGRectMake(0, 0, self.screenWidth, self.screenWidth);
        self.textContainerView.layer.anchorPoint = CGPointMake(.5f, .5f);
        self.textContainerView.layer.position = CGPointMake(self.screenWidth*.5f, self.screenWidth*.5f);
        self.textContainerView.transform = CGAffineTransformMakeRotation(self.transformAngle);
        self.textLabel.bounds = self.wordingBounds;
        self.textLabel.center = self.centerPoint;
    }
    else if (gesture.state != UIGestureRecognizerStateBegan
             && gesture.state != UIGestureRecognizerStateEnded
             && gesture.state != UIGestureRecognizerStateFailed) {
        CGPoint location = [gesture translationInView:gesture.view];
        self.centerPoint = CGPointMake(self.centerPoint.x+location.x, self.centerPoint.y+location.y);
        gesture.view.center = CGPointMake(self.centerPoint.x+location.x, self.centerPoint.y+location.y);
        [gesture setTranslation:CGPointMake(0, 0) inView:gesture.view];
        CGPoint dragCenterPoint = [self rotatePoint:self.textLabel.center
                                        centerPoint:centerPoint
                                              angle:self.transformAngle];
        [self setupDragViewWithCenterPoint:dragCenterPoint];
    }
    else {
        CGPoint labelCenter = self.textLabel.center;
        CGFloat angle = self.transformAngle;
        self.centerPoint = [self rotatePoint:labelCenter
                                 centerPoint:centerPoint
                                       angle:angle];
        self.textContainerView.bounds = self.textLabel.bounds;
        self.textContainerView.layer.position = self.centerPoint;
        self.textLabel.frame = self.textLabel.bounds;
    }
}

- (void)dragPanAction:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        dragStartCenter = self.dragImageView.center;
        dragCenter = dragStartCenter;
        lastScale = 1;
        dragStartLength = [self lengthBetweenPoint:dragStartCenter
                                      anotherPoint:self.textContainerView.center];
        labelStartSize = self.textLabel.bounds.size;
        self.textLabel.center = CGPointMake(self.screenWidth*.5f, self.screenWidth*.5f);
        self.textContainerView.transform = CGAffineTransformMakeRotation(self.transformAngle);
        self.textContainerView.bounds = CGRectMake(0, 0, self.screenWidth, self.screenWidth);
        self.textContainerView.layer.anchorPoint = CGPointMake(.5f, .5f);
    }
    else if (gesture.state != UIGestureRecognizerStateBegan
             && gesture.state != UIGestureRecognizerStateEnded
             && gesture.state != UIGestureRecognizerStateFailed) {
        CGPoint location = [gesture translationInView:gesture.view];
        CGPoint center = gesture.view.center;
        gesture.view.center = CGPointMake(center.x+location.x, center.y+location.y);
        [gesture setTranslation:CGPointMake(0, 0) inView:gesture.view];
        CGPoint newCenter = gesture.view.center;
        //到中心点的距离
        CGFloat newLength = [self lengthBetweenPoint:newCenter
                                        anotherPoint:self.textContainerView.center];
        CGFloat ratio = newLength/dragStartLength;
        
        CGFloat angle = atan2f(newCenter.y-self.centerPoint.y, newCenter.x-self.centerPoint.x)-atan2f(dragCenter.y-self.centerPoint.y, dragCenter.x-self.centerPoint.x);
        self.transformAngle += angle;
        dragCenter = newCenter;
        if (lastScale-ratio < 0) {
            self.fontSize *= (1 - (lastScale - ratio));
        }
        self.textLabel.bounds = CGRectMake(0, 0, labelStartSize.width*ratio, labelStartSize.height*ratio);
        self.textLabel.font = [UIFont systemFontOfSize:self.fontSize];
        self.textContainerView.transform = CGAffineTransformMakeRotation(self.transformAngle);
        
        self.dashLayer.frame = self.textLabel.bounds;
        self.dashLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.textLabel.bounds
                                                    byRoundingCorners:UIRectCornerAllCorners
                                                          cornerRadii:CGSizeMake(CornerRadius, CornerRadius)].CGPath;
        
        lastScale = ratio;
    }
    else {
        lastScale = 1;
        self.wordingBounds = self.textLabel.bounds;
        self.fontSize = [self adjustedFontSizeForLabel:self.textLabel];
        
        self.textContainerView.bounds = self.textLabel.bounds;
        self.textContainerView.center = self.centerPoint;
        self.textLabel.frame = self.textLabel.bounds;
        self.textLabel.font = [UIFont systemFontOfSize:self.fontSize];
    }
}

- (CGFloat)adjustedFontSizeForLabel:(UILabel *)label
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithAttributedString:label.attributedText];
    [attrStr setAttributes:@{NSFontAttributeName:label.font} range:NSMakeRange(0, attrStr.length)];
    NSStringDrawingContext *context = [NSStringDrawingContext new];
    context.minimumScaleFactor = label.minimumScaleFactor;
    [attrStr boundingRectWithSize:label.frame.size
                          options:NSStringDrawingUsesLineFragmentOrigin
                          context:context];
    CGFloat theoreticalFontSize = label.font.pointSize * context.actualScaleFactor;
    double scaleFactor = label.frame.size.width/([attrStr size].width);
    double displayedFontSize = theoreticalFontSize*scaleFactor;
    return displayedFontSize;
}

- (CGFloat)lengthBetweenPoint:(CGPoint)point anotherPoint:(CGPoint)anotherPoint
{
    CGFloat length = sqrt(pow((point.x-anotherPoint.x), 2)+pow((point.y-anotherPoint.y), 2));
    return length;
}

- (CGPoint)rotatePoint:(CGPoint)point
           centerPoint:(CGPoint)centerPoint
                 angle:(CGFloat)angle
{
    CGFloat newX = (point.x-centerPoint.x)*cos(angle)-(point.y-centerPoint.y)*sin(angle)+centerPoint.x;
    CGFloat newY = (point.x-centerPoint.x)*sin(angle)+(point.y-centerPoint.y)*cos(angle)+centerPoint.y;
    return CGPointMake(newX, newY);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
