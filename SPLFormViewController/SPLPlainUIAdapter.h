//
//  SPLPlainUIAdapter.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SPLFormular.h>

typedef NS_ENUM(NSInteger, SPLPropertyType) {
    SPLPropertyTypeHumanText,
    SPLPropertyTypeMachineText,
    SPLPropertyTypeEMail,
    SPLPropertyTypePassword,
    SPLPropertyTypeURL,
    SPLPropertyTypeNumber,
    SPLPropertyTypePrice,
    SPLPropertyTypeIPAddress,
    SPLPropertyTypeBoolean,
    SPLPropertyTypeDate,
    SPLPropertyTypeDateTime
};



@interface SPLField (SPLPlainUIAdapter)
- (instancetype)initWithProperty:(NSString *)property title:(NSString *)title type:(SPLPropertyType)type;
@end



/**
 @abstract  <#abstract comment#>
 */
@interface SPLPlainUIAdapter : NSObject <SPLFieldUIAdapter>

@property (nonatomic, copy) dispatch_block_t changeBlock;
@property (nonatomic, unsafe_unretained) id object;

@property (nonatomic, readonly) SPLPropertyType type;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithType:(SPLPropertyType)type NS_DESIGNATED_INITIALIZER;

@end
