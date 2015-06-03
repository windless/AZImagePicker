//
// Created by 钟建明 on 15/6/3.
//

#import <UIKit/UIKit.h>

@class AZImagePickerController;

@protocol AZImagePickerControllerDelegate

- (void)azImagePickerController:(AZImagePickerController *)picker
             didFinishPickImage:(UIImage *)image;

@end

@interface AZImagePickerController : UIViewController

@property(nonatomic, strong) UIImage *sourceImage;
@property(nonatomic, strong) UIButton *confirmButton;
@property(nonatomic, strong) UIButton *cancelButton;
@property(nonatomic, assign) CGFloat radius;

@property(nonatomic, weak) id <AZImagePickerControllerDelegate> delegate;

@end