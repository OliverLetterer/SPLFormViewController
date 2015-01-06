//
//  SPLFormViewController.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SPLFormular.h>
#import <SPLPlainUIAdapter.h>
#import <SPLEnumUIAdapter.h>
#import <SPLFormFieldValidator.h>



/**
 @abstract  <#abstract comment#>
 */
@interface SPLFormViewController : UITableViewController

@property (nonatomic, strong) SPLFormular *formular;
@property (nonatomic, strong) id object;

@property (nonatomic, copy, readonly) void(^completionHandler)(BOOL didSaveObject);
- (void)setCompletionHandler:(void (^)(BOOL didSaveObject))completionHandler;

@property (nonatomic, strong) UIBarButtonItem *cancelBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *saveBarButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *activityIndicatorBarButtonItem;

- (BOOL)validate:(SPLField **)failingField;

- (void)saveWithCompletionHandler:(void(^)(NSError *error))completionHandler;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithStyle:(UITableViewStyle)style UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithObject:(id)object NS_DESIGNATED_INITIALIZER;

@end
