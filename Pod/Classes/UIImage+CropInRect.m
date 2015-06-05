//
// Created by 钟建明 on 15/6/5.
//

#import "UIImage+CropInRect.h"


@implementation UIImage (CropInRect)

- (UIImage *)cropInRect:(CGRect)rect {
  CGAffineTransform rectTransform;
  switch (self.imageOrientation) {
    case UIImageOrientationLeft:
      rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation([self rad:90]), 0, -self.size.height);
      break;
    case UIImageOrientationRight:
      rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation([self rad:-90]), -self.size.width, 0);
      break;
    case UIImageOrientationDown:
      rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation([self rad:-180]), -self.size.width, -self.size.height);
      break;
    default:
      rectTransform = CGAffineTransformIdentity;
  };
  rectTransform = CGAffineTransformScale(rectTransform, self.scale, self.scale);

  CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], CGRectApplyAffineTransform(rect, rectTransform));
  UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
  CGImageRelease(imageRef);
  return result;
}

- (CGFloat)rad:(CGFloat)deg {
  return (CGFloat) (deg / 180.0f * M_PI);
}

@end