//
//  SPLFormViewController.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SPLFormular.h>
#import <SPLPlainCellConfigurator.h>



/**
 @abstract  <#abstract comment#>
 */
@interface SPLFormViewController : UITableViewController

@property (nonatomic, strong) SPLFormular *formular;
@property (nonatomic, readonly) id object;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithStyle:(UITableViewStyle)style UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithObject:(id)object NS_DESIGNATED_INITIALIZER;

@end
