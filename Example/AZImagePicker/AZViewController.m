//
//  AZViewController.m
//  AZImagePicker
//
//  Created by Abner Zhong on 06/03/2015.
//  Copyright (c) 2014 Abner Zhong. All rights reserved.
//

#import <AZImagePicker/AZImagePickerController.h>
#import "AZViewController.h"

@interface AZViewController ()

@property(nonatomic, strong) UIImageView *imageView;

@end

@implementation AZViewController

- (void)loadView {
  self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
  self.view.backgroundColor = [UIColor whiteColor];

  UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [button setTitle:@"Take Photo" forState:UIControlStateNormal];
  [button sizeToFit];
  button.center = CGPointMake(100, 100);
  [button addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:button];

  UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [photoButton setTitle:@"Photos" forState:UIControlStateNormal];
  [photoButton sizeToFit];
  photoButton.center = CGPointMake(100, 150);
  [photoButton addTarget:self action:@selector(getPhotos) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:photoButton];

  self.imageView = [[UIImageView alloc] init];
  self.imageView.frame = CGRectMake(100, 200, 200, 200);
  self.imageView.contentMode = UIViewContentModeScaleAspectFit;
  [self.view addSubview:self.imageView];
}

- (void)getPhotos {
  UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
  pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  pickerController.delegate = self;

  [self presentViewController:pickerController animated:YES completion:nil];
}

- (void)takePhoto {
  UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
  pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
  pickerController.delegate = self;

  [self presentViewController:pickerController animated:YES completion:nil];
}

- (void)azImagePickerController:(AZImagePickerController *)picker didFinishPickImage:(UIImage *)image {
  self.imageView.image = image;
}

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo {
  [picker dismissViewControllerAnimated:YES completion:^{
    AZImagePickerController *controller = [[AZImagePickerController alloc] initWithSourceImage:image];
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
  }];
}


@end
