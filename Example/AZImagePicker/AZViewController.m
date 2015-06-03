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
}

- (void)takePhoto {
  UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
  pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
  pickerController.delegate = self;

  [self presentViewController:pickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo {
  __block UIImage *blockImage = image;
  [picker dismissViewControllerAnimated:YES completion:^{
      AZImagePickerController *controller = [[AZImagePickerController alloc] init];
      controller.sourceImage = blockImage;
      [self presentViewController:controller animated:YES completion:nil];
  }];
}


@end
