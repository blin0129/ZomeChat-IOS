//
//  ProfilePageViewController.m
//  ZomeChat
//
//  Created by Brian Lin on 1/13/14.
//  Copyright (c) 2014 Zome. All rights reserved.
//

#import "ChatImageViewController.h"
#import "UIImage+ProportionalFill.h"

@interface ChatImageViewController ()

@end

@implementation ChatImageViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background-babyblue"]]];
    UIImage *image = [self getImageFromURL:[APPDELEGATE.chatVC zoomImageURL]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:imageView];
    [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.view
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1
                                                                  constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1
                                                           constant:0]];

}

- (UIImage *) resizeImage:(UIImage *)originalImage {
    float height = originalImage.size.height;
    float width = originalImage.size.width;
    float heightScale = height/[[UIScreen mainScreen] bounds].size.height;
    float weidthScale = width/[[UIScreen mainScreen] bounds].size.width;
    float finalScale = 1;
    if(heightScale > weidthScale && heightScale > 1){
        finalScale = 1 / heightScale;
    } else if (weidthScale > heightScale && weidthScale > 1) {
        finalScale = 1 / weidthScale;
    }
    CGSize newSize = CGSizeMake(width * finalScale, height * finalScale);
    UIImage *newImage =[originalImage imageCroppedToFitSize:newSize];
    return newImage;
}

- (UIImage *) getImageFromURL: (NSString *) imageURL{
    if ([imageURL isEqualToString:@""]) {
        return nil;
    }
    UIImage *img = [APPDELEGATE.imageCache objectForKey:imageURL];
    if(!img){
        img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: imageURL]]];
        [APPDELEGATE.imageCache setObject:img forKey:imageURL];
    }
    return [self resizeImage:img];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
