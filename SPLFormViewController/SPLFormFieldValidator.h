//
//  SPLFormFieldValidator.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SPLFormular, SPLField;

@protocol SPLFormValidator <NSObject>

@required
- (BOOL)validateObject:(id)object forFormular:(SPLFormular *)formular failingField:(SPLField **)failingField;

@optional
- (void)enforceConsistencyWithObject:(id)object;

@end



/**
 @abstract  <#abstract comment#>
 */
@interface SPLFormFieldValidator : NSObject <SPLFormValidator>

+ (instancetype)validatorWithAllTextFields;
+ (instancetype)validatorWithRequiredTextFields:(NSArray *)requiredTextFields;

@end
