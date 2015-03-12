//
//  SPLFormFieldValidator.m
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import "SPLFormFieldValidator.h"
#import <objc/runtime.h>
#import <SPLFormular.h>
#import <SPLPlainUIAdapter.h>
#import <SPLEnumUIAdapter.h>

typedef NS_ENUM(NSInteger, SPLFormFieldValidatorType) {
    SPLFormFieldValidatorTypeAllTextFields,
    SPLFormFieldValidatorTypeSpecificTextFields,
    SPLFormFieldValidatorTypeEqualProperties,
};



@interface SPLFormFieldValidator ()

@property (nonatomic, readonly) NSArray *requiredTextFields;
@property (nonatomic, readonly) NSArray *equalProperties;
@property (nonatomic, readonly) SPLFormFieldValidatorType type;

- (instancetype)initWithAllTextFields;
- (instancetype)initWithRequiredTextFields:(NSArray *)requiredTextFields;
- (instancetype)initWithEqualProperties:(NSArray *)equalProperties;

@end



@implementation SPLFormFieldValidator

+ (instancetype)validatorWithAllTextFields
{
    return [[self alloc] initWithAllTextFields];
}

+ (instancetype)validatorWithRequiredTextFields:(NSArray *)requiredTextFields
{
    return [[self alloc] initWithRequiredTextFields:requiredTextFields];
}

+ (instancetype)validatorWithEqualProperties:(NSArray *)equalProperties
{
    return [[self alloc] initWithEqualProperties:equalProperties];
}

- (instancetype)initWithAllTextFields
{
    if (self = [super init]) {
        _type = SPLFormFieldValidatorTypeAllTextFields;
    }
    return self;
}

- (instancetype)initWithRequiredTextFields:(NSArray *)requiredTextFields
{
    if (self = [super init]) {
        _type = SPLFormFieldValidatorTypeSpecificTextFields;
        _requiredTextFields = requiredTextFields;
    }
    return self;
}

- (instancetype)initWithEqualProperties:(NSArray *)equalProperties
{
    if (self = [super init]) {
        _type = SPLFormFieldValidatorTypeEqualProperties;
        _equalProperties = equalProperties;
    }
    return self;
}

- (BOOL)validateObject:(id)object forFormular:(SPLFormular *)formular failingField:(SPLField *__autoreleasing *)failingField
{
    NSArray *visibleSections = [formular visibleSectionsWithObject:object];

    BOOL(^failWithField)(SPLField *field) = ^BOOL(SPLField *field) {
        if (failingField) {
            *failingField = field;
        }
        return NO;
    };

    BOOL(^matches)(NSString *value, NSString *regex) = ^BOOL(NSString *value, NSString *regex) {
        if (!value || ![value isKindOfClass:[NSString class]]) {
            return NO;
        }

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        return [predicate evaluateWithObject:value];
    };

    BOOL(^validateField)(SPLField *field) = ^BOOL(SPLField *field) {
        id value = [object valueForKey:field.property];

        BOOL isValid = YES;

        if ([field.adapter isKindOfClass:[SPLPlainUIAdapter class]]) {
            SPLPlainUIAdapter *adapter = field.adapter;

            switch (adapter.type) {
                case SPLPropertyTypeHumanText:
                case SPLPropertyTypeMachineText:
                    isValid = [value length] > 0;
                    break;
                case SPLPropertyTypeEMail:
                    isValid = matches(value, @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}");
                    break;
                case SPLPropertyTypePassword:
                    isValid = [value length] > 0;
                    break;
                case SPLPropertyTypeURL:
                    isValid = value && [NSURL URLWithString:value] != nil;
                    break;
                case SPLPropertyTypeIPAddress:
                    return matches(value, @"\\d{1,3}.\\d{1,3}.\\d{1,3}.\\d{1,3}");
                    break;
                case SPLPropertyTypeNumber:
                case SPLPropertyTypePrice:
                case SPLPropertyTypeDate:
                case SPLPropertyTypeDateTime:
                    isValid = value != nil;
                    break;
                case SPLPropertyTypeBoolean:
                    isValid = YES;
                    break;
            }
        } else if ([field.adapter isKindOfClass:[SPLEnumUIAdapter class]]) {
            if ([field propertyClassWithObject:object] == [NSArray class] || [field propertyClassWithObject:object] == [NSSet class]) {
                isValid = YES;
            } else {
                isValid = value != nil;
            }
        }

        if (!isValid) {
            return failWithField(field);
        }

        return YES;
    };

    NSMutableSet *equalValues = [NSMutableSet set];
    for (SPLSection *section in visibleSections) {
        for (SPLField *field in section) {
            switch (self.type) {
                case SPLFormFieldValidatorTypeAllTextFields: {
                    if (!validateField(field)) {
                        return NO;
                    }
                    break;
                }
                case SPLFormFieldValidatorTypeSpecificTextFields: {
                    if (![self.requiredTextFields containsObject:field.property]) {
                        continue;
                    }

                    if (!validateField(field)) {
                        return NO;
                    }
                    break;
                }
                case SPLFormFieldValidatorTypeEqualProperties: {
                    if (![self.equalProperties containsObject:field.property]) {
                        continue;
                    }

                    id value = [object valueForKey:field.property];
                    if (equalValues.count > 0) {
                        if (value && ![equalValues containsObject:value]) {
                            return failWithField(field);
                        } else if (!value) {
                            return failWithField(field);;
                        }
                    } else {
                        if (value) {
                            [equalValues addObject:value];
                        }
                    }
                    break;
                }
            }
        }
    }

    return YES;
}

- (void)enforceConsistencyWithObject:(id)object
{
    NSString *fieldType = Nil;
    switch (self.type) {
        case SPLFormFieldValidatorTypeAllTextFields:
            return;
            break;
        case SPLFormFieldValidatorTypeSpecificTextFields: {
            for (NSString *propertyName in self.requiredTextFields) {
                objc_property_t property = class_getProperty([object class], propertyName.UTF8String);
                if (property == NULL) {
                    [NSException raise:NSInternalInconsistencyException format:@"object %@ does not contain property %@", object, propertyName];
                }
            }
            break;
        }
        case SPLFormFieldValidatorTypeEqualProperties: {
            for (NSString *propertyName in self.equalProperties) {
                objc_property_t property = class_getProperty([object class], propertyName.UTF8String);
                if (property == NULL) {
                    [NSException raise:NSInternalInconsistencyException format:@"object %@ does not contain property %@", object, propertyName];
                }

                char *type = property_copyAttributeValue(property, "T");
                if (!type) {
                    [NSException raise:NSInternalInconsistencyException format:@"object %@[%@] property does not have a type", object, propertyName];
                }

                NSString *thisType = [[NSString alloc] initWithCString:type encoding:NSASCIIStringEncoding];
                free(type);

                if (!fieldType) {
                    fieldType = thisType;
                }

                if (![fieldType isEqualToString:thisType]) {
                    [NSException raise:NSInternalInconsistencyException format:@"object %@ properties %@ dont have the same type", object, self.equalProperties];
                }
            }
            break;
        }
    }
}

@end
