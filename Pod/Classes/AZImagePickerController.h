//
// Created by 钟建明 on 15/6/3.
//

#import <UIKit/UIKit.h>

@class AZImagePickerController;

@protocol AZImagePickerControllerDelegate

- (void)azImagePickerController:(AZImagePickerController *)picker
             didFinishPickImage:(UIImage *)image;

@end

@interface AZImagePickerController : UIViewController <UIScrollViewDelegate>

- (instancetype)initWithSourceImage:(UIImage *)sourceImage;

@property(nonatomic, strong) NSString *confirmButtonTitle;
@property(nonatomic, strong) NSString *cancelButtonTitle;

@property(nonatomic, weak) id <AZImagePickerControllerDelegate> delegate;


@end