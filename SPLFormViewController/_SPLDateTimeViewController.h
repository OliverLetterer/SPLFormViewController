//
//  _SPLDateTimeViewController.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class _SPLDateTimeViewController;



/**
 @abstract  <#abstract comment#>
 */
@protocol _SPLDateTimeViewControllerDelegate <NSObject>

- (void)dateTimeViewController:(_SPLDateTimeViewController *)viewController didSelectDate:(NSDate *)date;

@end



/**
 @abstract  <#abstract comment#>
 */
@interface _SPLDateTimeViewController : UIViewController

@property (nonatomic, weak) id<_SPLDateTimeViewControllerDelegate> delegate;
@property (nonatomic, assign) UIDatePickerMode datePickerMode;
@property (nonatomic, strong) NSDate *date;

@end
