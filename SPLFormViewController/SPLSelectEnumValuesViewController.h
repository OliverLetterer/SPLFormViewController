//
//  SPLSelectEnumValuesViewController.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SPLSelectEnumValuesViewController, SPLField;



/**
 @abstract  <#abstract comment#>
 */
@protocol SPLSelectEnumValuesViewControllerDelegate <NSObject>

- (void)selectEnumValuesViewControllerDidCancel:(SPLSelectEnumValuesViewController *)viewController;
- (void)selectEnumValuesViewController:(SPLSelectEnumValuesViewController *)viewController didSelectValue:(id)value;

@end



/**
 @abstract  <#abstract comment#>
 */
@interface SPLSelectEnumValuesViewController : UITableViewController

@property (nonatomic, weak) id<SPLSelectEnumValuesViewControllerDelegate> delegate;

@property (nonatomic, readonly) NSArray *options;
@property (nonatomic, readonly) NSArray *values;
@property (nonatomic, readonly) SPLField *field;
@property (nonatomic, readonly) id object;

- (instancetype)initWithHumanReadableOptions:(NSArray *)options values:(NSArray *)values forField:(SPLField *)field object:(id)object;

@end
