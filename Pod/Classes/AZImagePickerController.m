//
// Created by 钟建明 on 15/6/3.
//

#import "AZImagePickerController.h"
#import "UIImage+CropInRect.h"

@interface AZImagePickerController ()

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) UIView *maskView;
@property(nonatomic, strong) UIButton *confirmButton;
@property(nonatomic, strong) UIButton *cancelButton;
@property(nonatomic, assign) CGFloat radius;
@property(nonatomic, strong) UIImage *sourceImage;

@end


@implementation AZImagePickerController {

}
- (instancetype)initWithSourceImage:(UIImage *)sourceImage {
  self = [super init];
  if (self) {
    _sourceImage = sourceImage;
  }
  return self;
}

- (void)loadView {
  self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
  self.view.backgroundColor = [UIColor blackColor];

  self.scrollView = [[UIScrollView alloc]
      initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds))];
  self.scrollView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
  self.scrollView.showsVerticalScrollIndicator = NO;
  self.scrollView.showsHorizontalScrollIndicator = NO;
  self.scrollView.alwaysBounceVertical = YES;
  self.scrollView.alwaysBounceHorizontal = YES;
  self.scrollView.clipsToBounds = NO;
  self.scrollView.delegate = self;
  [self.view addSubview:self.scrollView];

  self.imageView = [[UIImageView alloc] init];
  [self.scrollView addSubview:self.imageView];

  if (self.radius == 0) {
    self.radius = CGRectGetWidth(self.view.bounds) / 2;
  }
  self.maskView = [self newMaskViewWithRadius:self.radius andFrame:self.view.bounds];
  [self.view addSubview:self.maskView];

  self.confirmButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [self.confirmButton setTitle:self.confirmButtonTitle forState:UIControlStateNormal];
  self.confirmButton.titleLabel.font = [UIFont systemFontOfSize:20];
  [self.confirmButton sizeToFit];
  self.confirmButton.tintColor = [UIColor whiteColor];
  [self updateConfirmButtonPosition];
  [self.confirmButton addTarget:self action:@selector(cropImage) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.confirmButton];

  self.cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [self.cancelButton setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
  self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:20];
  [self.cancelButton sizeToFit];
  self.cancelButton.tintColor = [UIColor whiteColor];
  [self updateCancelButtonPosition];
  [self.cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.cancelButton];
}

- (void)updateCancelButtonPosition {
  self.cancelButton.center = CGPointMake(
      CGRectGetWidth(self.cancelButton.bounds) / 2 + 16,
      CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.cancelButton.bounds) / 2 - 16);
}

- (void)updateConfirmButtonPosition {
  self.confirmButton.center = CGPointMake(
      CGRectGetWidth(self.view.bounds) - CGRectGetWidth(self.confirmButton.bounds) / 2 - 16,
      CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.confirmButton.bounds) / 2 - 16);
}

- (void)cancel {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cropImage {
  [self dismissViewControllerAnimated:YES completion:^{
    CGFloat x = self.scrollView.contentOffset.x / self.scrollView.zoomScale;
    CGFloat y = self.scrollView.contentOffset.y / self.scrollView.zoomScale;
    CGFloat width = CGRectGetWidth(self.scrollView.bounds) / self.scrollView.zoomScale;
    CGFloat height = width;

    CGRect rect = CGRectMake(x, y, width, height);

    [self.delegate azImagePickerController:self didFinishPickImage:[self.sourceImage cropInRect:rect]];
  }];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setNeedsStatusBarAppearanceUpdate];

  self.imageView.image = self.sourceImage;
  [self.imageView sizeToFit];
  self.scrollView.contentSize = self.imageView.frame.size;

  CGFloat scale;
  if (CGRectGetWidth(self.imageView.bounds) > CGRectGetHeight(self.imageView.bounds)) {
    scale = self.scrollView.frame.size.height / self.imageView.frame.size.height;
  } else {
    scale = self.scrollView.frame.size.width / self.imageView.frame.size.width;
  }

  self.scrollView.minimumZoomScale = scale;
  if (scale > 1) {
    self.scrollView.maximumZoomScale = scale;
  } else {
    self.scrollView.maximumZoomScale = 1;
  }
  [self.scrollView setZoomScale:scale];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}


- (UIView *)newMaskViewWithRadius:(CGFloat)radius andFrame:(CGRect)frame {
  UIView *view = [[UIView alloc] initWithFrame:frame];
  view.userInteractionEnabled = NO;

  UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:
          CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height)
                                                  cornerRadius:0];
  CGRect circleRect =
      CGRectMake(CGRectGetMidX(frame) - radius, CGRectGetMidY(frame) - radius, radius * 2, radius * 2);
  UIBezierPath *circlePath =
      [UIBezierPath bezierPathWithRoundedRect:circleRect cornerRadius:radius];
  [path appendPath:circlePath];
  [path setUsesEvenOddFillRule:YES];

  CAShapeLayer *fillLayer = [CAShapeLayer layer];
  fillLayer.path = path.CGPath;
  fillLayer.fillRule = kCAFillRuleEvenOdd;
  fillLayer.fillColor = [UIColor blackColor].CGColor;
  fillLayer.opacity = 0.6;
  [view.layer addSublayer:fillLayer];

  CALayer *circleLayer = [CALayer layer];
  circleLayer.frame = circleRect;
  circleLayer.borderColor = [[UIColor whiteColor] CGColor];
  circleLayer.borderWidth = 2;
  circleLayer.cornerRadius = radius;
  [view.layer addSublayer:circleLayer];
  return view;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
  return self.imageView;
}

- (NSString *)confirmButtonTitle {
  if (!_confirmButtonTitle) {
    return @"确定";
  }
  return _confirmButtonTitle;
}

- (NSString *)cancelButtonTitle {
  if (!_cancelButtonTitle) {
    return @"取消";
  }
  return _cancelButtonTitle;
}


@end