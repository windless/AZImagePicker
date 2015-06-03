//
// Created by 钟建明 on 15/6/3.
//

#import "AZImagePickerController.h"

@interface AZImagePickerController ()

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UIView *maskView;

@property(nonatomic, assign) CGPoint lastImageViewCenter;
@property(nonatomic, assign) CGRect lastImageViewBounds;
@property(nonatomic, assign) CGSize originImageViewSize;

@end


@implementation AZImagePickerController {

}

- (void)loadView {
  self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
  self.view.backgroundColor = [UIColor blackColor];

  self.imageView = [[UIImageView alloc] init];
  self.imageView.frame = self.view.bounds;
  self.imageView.contentMode = UIViewContentModeScaleAspectFit;
  [self.view addSubview:self.imageView];

  self.maskView = [[UIView alloc] initWithFrame:self.view.bounds];
  [self.view addSubview:self.maskView];

  self.confirmButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [self.confirmButton setTitle:@"确定" forState:UIControlStateNormal];
  self.confirmButton.titleLabel.font = [UIFont systemFontOfSize:20];
  self.confirmButton.tintColor = [UIColor whiteColor];
  [self.confirmButton sizeToFit];
  self.confirmButton.frame = CGRectMake(
      self.view.frame.size.width - self.confirmButton.frame.size.width - 16,
      self.view.frame.size.height - self.confirmButton.frame.size.height - 16,
      self.confirmButton.frame.size.width, self.confirmButton.frame.size.height);
  [self.view addSubview:self.confirmButton];

  self.cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
  self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:20];
  self.cancelButton.tintColor = [UIColor whiteColor];
  [self.cancelButton sizeToFit];
  self.cancelButton.frame = CGRectMake(
      16, self.view.frame.size.height - self.cancelButton.frame.size.height - 16,
      self.cancelButton.frame.size.width, self.cancelButton.frame.size.height);
  [self.view addSubview:self.cancelButton];
}

- (void)initRadius {
  if (self.radius == 0) {
    self.radius = self.view.bounds.size.width / 2;
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setupImageView];

  [self initRadius];
  [self addMask:self.radius];

  UIPinchGestureRecognizer *pinchGestureRecognizer =
      [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinch:)];
  [self.maskView addGestureRecognizer:pinchGestureRecognizer];

  UIPanGestureRecognizer *dragGestureRecognizer =
      [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onDrag:)];
  [self.maskView addGestureRecognizer:dragGestureRecognizer];

  [self.cancelButton addTarget:self action:@selector(cancelPicking) forControlEvents:UIControlEventTouchUpInside];
  [self.confirmButton addTarget:self action:@selector(finishPicking) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupImageView {
  self.imageView.image = self.sourceImage;
  if (self.sourceImage.size.width < self.sourceImage.size.height) {
    CGFloat scale = self.view.bounds.size.width / self.sourceImage.size.width;
    self.imageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.sourceImage.size.height * scale);
    self.imageView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
  } else {
    CGFloat scale = self.view.bounds.size.height / self.sourceImage.size.height;
    self.imageView.frame = CGRectMake(0, 0, self.view.bounds.size.width * scale, self.view.bounds.size.height);
    self.imageView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
  }

  self.originImageViewSize = self.imageView.frame.size;
}

- (void)onDrag:(UIPanGestureRecognizer *)sender {
  if (sender.state == UIGestureRecognizerStateBegan) {
    self.lastImageViewCenter = self.imageView.center;
  } else if (sender.state == UIGestureRecognizerStateChanged) {
    CGPoint location = [sender translationInView:self.maskView];
    self.imageView.center = CGPointMake(self.lastImageViewCenter.x + location.x, self.lastImageViewCenter.y + location.y);
  } else if (sender.state == UIGestureRecognizerStateEnded ||
      sender.state == UIGestureRecognizerStateCancelled) {
    [self adjustImageViewPosition];
  }
}

- (void)adjustImageViewPosition {
  CGFloat left = self.imageView.frame.origin.x;
  CGFloat top = self.imageView.frame.origin.y;
  CGFloat bottom = top + self.imageView.frame.size.height;
  CGFloat right = left + self.imageView.frame.size.width;
  CGFloat width = self.imageView.frame.size.width;
  CGFloat height = self.imageView.frame.size.height;

  NSLog(@"%@", NSStringFromCGRect(self.imageView.frame));

  CGRect cropRect = [self cropRect:self.radius];
  NSLog(@"crop rect: %@", NSStringFromCGRect(cropRect));
  BOOL isOutCropRect = NO;

  if (left > cropRect.origin.x) {
    left = cropRect.origin.x;
    isOutCropRect = YES;
  }

  if (right < cropRect.origin.x + cropRect.size.width) {
    left = cropRect.origin.x + cropRect.size.width - width;
    isOutCropRect = YES;
  }

  if (top > cropRect.origin.y) {
    top = cropRect.origin.y;
    isOutCropRect = YES;
  }

  if (bottom < cropRect.origin.y + cropRect.size.height) {
    top = cropRect.origin.y + cropRect.size.height - height;
    isOutCropRect = YES;
  }

  if (isOutCropRect) {
    [UIView animateWithDuration:0.3 animations:^{
      self.imageView.frame = CGRectMake(left, top, width, height);
    }];
  }
}

- (void)adjustImageViewSize {
  CGRect imageViewBounds = self.imageView.bounds;
  CGFloat width = imageViewBounds.size.width;
  CGFloat height = imageViewBounds.size.height;

  BOOL isOutCropRect = NO;

  if (width < self.originImageViewSize.width) {
    width = self.originImageViewSize.width;
    isOutCropRect = YES;
  }

  if (height < self.originImageViewSize.height) {
    height = self.originImageViewSize.height;
    isOutCropRect = YES;
  }

  if (isOutCropRect) {
    [UIView animateWithDuration:0.3 animations:^{
      self.imageView.frame = CGRectMake(0, 0, width, height);
      self.imageView.center = self.lastImageViewCenter;
    }];
  }
}

- (void)onPinch:(UIPinchGestureRecognizer *)sender {
  if (sender.state == UIGestureRecognizerStateBegan) {
    self.lastImageViewBounds = self.imageView.bounds;
    self.lastImageViewCenter = self.imageView.center;
  } else if (sender.state == UIGestureRecognizerStateChanged) {
    self.imageView.frame = CGRectMake(0, 0,
        self.lastImageViewBounds.size.width * sender.scale,
        self.lastImageViewBounds.size.height * sender.scale
    );
    self.imageView.center = self.lastImageViewCenter;
  } else if (sender.state == UIGestureRecognizerStateEnded ||
      sender.state == UIGestureRecognizerStateCancelled) {
    [self adjustImageViewSize];
    [self adjustImageViewPosition];
  }
}

- (void)setSourceImage:(UIImage *)sourceImage {
  _sourceImage = sourceImage;
  self.imageView.image = sourceImage;
}

- (void)addMask:(CGFloat)radius {
  UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:
          CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)
                                                  cornerRadius:0];
  UIBezierPath *circlePath =
      [UIBezierPath bezierPathWithRoundedRect:[self cropRect:radius]
                                 cornerRadius:radius];
  [path appendPath:circlePath];
  [path setUsesEvenOddFillRule:YES];

  CAShapeLayer *fillLayer = [CAShapeLayer layer];
  fillLayer.path = path.CGPath;
  fillLayer.fillRule = kCAFillRuleEvenOdd;
  fillLayer.fillColor = [UIColor blackColor].CGColor;
  fillLayer.opacity = 0.6;
  [self.maskView.layer addSublayer:fillLayer];

  CALayer *circleLayer = [CALayer layer];
  circleLayer.frame = [self cropRect:radius];
  circleLayer.borderColor = [[UIColor whiteColor] CGColor];
  circleLayer.borderWidth = 2;
  circleLayer.cornerRadius = radius;
  [self.maskView.layer addSublayer:circleLayer];
}

- (void)finishPicking {
  [self dismissViewControllerAnimated:YES completion:^{
    [self.delegate azImagePickerController:self didFinishPickImage:[self cropImage]];
  }];
}

- (void)cancelPicking {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)cropImage {
  return nil;
}

- (CGRect)cropRect:(CGFloat)radius {
  CGFloat left = self.view.bounds.size.width / 2 - radius;
  CGFloat top = self.view.bounds.size.height / 2 - radius;
  return CGRectMake(left, top, 2.0f * radius, 2.0f * radius);
}

@end