//
//  SPLFormular.m
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "SPLFormular.h"
#import <objc/runtime.h>
#import "SPLFormFieldValidator.h"

static NSDictionary *indexBy(NSArray *array, NSString *keyPath)
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (id object in array) {
        result[[object valueForKeyPath:keyPath]] = object;
    }
    return result;
}

static NSDictionary *indexedFields(NSArray *sections)
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (SPLSection *section in sections) {
        result[section.identifier] = indexBy(section.fields, @"property");
    }
    return result;
}

static Class property_getObjcClass(objc_property_t property)
{
    char *attributeType = property_copyAttributeValue(property, "T");
    if (!attributeType) {
        return Nil;
    }

    NSString *type = [[NSString alloc] initWithBytesNoCopy:attributeType length:strlen(attributeType) encoding:NSASCIIStringEncoding freeWhenDone:YES];
    if (![type hasPrefix:@"@"] || type.length < 3) {
        return Nil;
    }

    if (![type containsString:@"<"]) {
        return NSClassFromString([type substringWithRange:NSMakeRange(2, type.length - 3)]);
    }

    NSUInteger caretLocation = [type rangeOfString:@"<"].location;
    NSString *className = [type substringWithRange:NSMakeRange(2, caretLocation - 2)];
    return NSClassFromString(className);
}



@implementation SPLField

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[SPLField class]]) {
        return [self isEqualToField:object];
    }
    return [super isEqual:object];
}

- (BOOL)isEqualToField:(SPLField *)field
{
    return [self.property isEqual:field.property] && [self.title isEqual:field.title];
}

- (Class)propertyClassWithObject:(id)object
{
    objc_property_t property = class_getProperty([object class], self.property.UTF8String);
    return property_getObjcClass(property);
}

- (instancetype)initWithProperty:(NSString *)property title:(NSString *)title adapter:(id<SPLFieldUIAdapter>)adapter
{
    NSParameterAssert(property);
    NSParameterAssert(title);
    NSParameterAssert(adapter);

    if (self = [super init]) {
        _property = property.copy;
        _title = title.copy;
        _adapter = adapter;
    }
    return self;
}

@end



@implementation SPLSection

- (SPLField *)objectAtIndexedSubscript:(NSUInteger)idx
{
    return self.fields[idx];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    return [self.fields countByEnumeratingWithState:state objects:buffer count:len];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[SPLSection class]]) {
        return [self isEqualToSection:object];
    }
    return [super isEqual:object];
}

- (BOOL)isEqualToSection:(SPLSection *)section
{
    return [self.identifier isEqual:section.identifier] && [self.fields isEqual:section.fields];
}

- (instancetype)initWithIdentifier:(NSString *)identifier fields:(NSArray /* SPLField */ *(^)())fields
{
    return [self initWithIdentifier:identifier title:nil fields:fields];
}

- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString *)title fields:(NSArray /* SPLField */ *(^)())fields
{
    NSParameterAssert(identifier);
    NSParameterAssert(fields);

    if (self = [super init]) {
        _identifier = identifier.copy;
        _title = title.copy;
        _fields = fields().copy;
    }
    return self;
}

@end



@implementation SPLSectionDiff

- (instancetype)initWithSections:(NSArray *)newSections previousSections:(NSArray *)previousSections
{
    if (self = [super init]) {
        NSMutableIndexSet *deletedSections = [NSMutableIndexSet indexSet];
        NSMutableArray *deletedIndexPaths = [NSMutableArray array];
        NSMutableIndexSet *insertedSections = [NSMutableIndexSet indexSet];
        NSMutableArray *insertedIndexPaths = [NSMutableArray array];

        {
            // delete sections
            NSDictionary *sections = indexBy(newSections, @"identifier");
            NSDictionary *fields = indexedFields(newSections);

            [previousSections enumerateObjectsUsingBlock:^(SPLSection *section, NSUInteger sectionIndex, BOOL *stop) {
                if (!sections[section.identifier]) {
                    return [deletedSections addIndex:sectionIndex];
                }

                // deleted index paths
                [section.fields enumerateObjectsUsingBlock:^(SPLField *field, NSUInteger idx, BOOL *stop) {
                    if (!fields[section.identifier][field.property]) {
                        [deletedIndexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:sectionIndex]];
                    }
                }];
            }];
        }

        {
            // insert sections
            NSDictionary *sections = indexBy(previousSections, @"identifier");
            NSDictionary *fields = indexedFields(previousSections);

            [newSections enumerateObjectsUsingBlock:^(SPLSection *section, NSUInteger sectionIndex, BOOL *stop) {
                if (!sections[section.identifier]) {
                    return [insertedSections addIndex:sectionIndex];
                }

                [section.fields enumerateObjectsUsingBlock:^(SPLField *field, NSUInteger idx, BOOL *stop) {
                    if (!fields[section.identifier][field.property]) {
                        [insertedIndexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:sectionIndex]];
                    }
                }];
            }];
        }

        _deletedSections = deletedSections.copy;
        _deletedIndexPaths = deletedIndexPaths.copy;
        _insertedSections = insertedSections.copy;
        _insertedIndexPaths = insertedIndexPaths.copy;
    }
    return self;
}

@end


@implementation SPLFormular

- (void)enforceConsistencyWithObject:(id)object
{
    NSMutableSet *sectionIdentifiers = [NSMutableSet set];

    for (SPLSection *section in self) {
        if ([sectionIdentifiers containsObject:section.identifier]) {
            [NSException raise:NSInternalInconsistencyException format:@"Two sections have the save identifier %@", section.identifier];
        }

        [sectionIdentifiers addObject:section.identifier];
        for (SPLField *field in section) {
            objc_property_t property = class_getProperty([object class], field.property.UTF8String);
            if (property == NULL) {
                [NSException raise:NSInternalInconsistencyException format:@"object %@ does not contain property %@", object, field.property];
            }

            if ([field.adapter respondsToSelector:@selector(enforceConsistencyWithObject:forField:)]) {
                [field.adapter enforceConsistencyWithObject:object forField:field];
            }
        }
    }

    for (NSString *propertyName in self.predicates) {
        objc_property_t property = class_getProperty([object class], propertyName.UTF8String);
        if (property == NULL) {
            [NSException raise:NSInternalInconsistencyException format:@"object %@ does not contain property %@", object, propertyName];
        }

        if (![self.predicates[propertyName] isKindOfClass:[NSPredicate class]]) {
            [NSException raise:NSInternalInconsistencyException format:@"self.predicates[%@] %@ is no NSPredicate.", propertyName, self.predicates[propertyName]];
        }
    }

    for (id<SPLFormValidator> validator in self.validators) {
        if (![validator conformsToProtocol:@protocol(SPLFormValidator)]) {
            [NSException raise:NSInternalInconsistencyException format:@"validator %@ does not conform to SPLFormValidator protocol", validator];
        }

        if ([validator respondsToSelector:@selector(enforceConsistencyWithObject:)]) {
            [validator enforceConsistencyWithObject:object];
        }
    }
}

- (NSArray *)visibleSectionsWithObject:(id)object
{
    NSMutableArray *visibleSections = [NSMutableArray array];
    for (SPLSection *section in self) {

        NSMutableArray *visibleFields = [NSMutableArray array];
        for (SPLField *field in section) {
            if (!self.predicates[field.property]) {
                [visibleFields addObject:field];
                continue;
            }

            NSPredicate *predicate = self.predicates[field.property];
            if ([predicate evaluateWithObject:object]) {
                [visibleFields addObject:field];
            }
        }

        if (visibleFields.count > 0) {
            [visibleSections addObject:[[SPLSection alloc] initWithIdentifier:section.identifier title:section.title fields:^NSArray *{
                return visibleFields;
            }]];
        }
    }

    return visibleSections;
}

- (BOOL)validateObject:(id)object failingField:(SPLField **)failingField
{
    for (id<SPLFormValidator> validator in self.validators) {
        if (![validator validateObject:object forFormular:self failingField:failingField]) {
            return NO;
        }
    }

    return YES;
}

- (SPLSection *)objectAtIndexedSubscript:(NSUInteger)idx
{
    return self.sections[idx];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    return [self.sections countByEnumeratingWithState:state objects:buffer count:len];
}

- (instancetype)initWithSections:(NSArray *)sections
{
    return [self initWithSections:sections predicates:@{} validators:@[]];
}

- (instancetype)initWithSections:(NSArray *)sections predicates:(NSDictionary *)predicates
{
    return [self initWithSections:sections predicates:predicates validators:@[]];
}

- (instancetype)initWithSections:(NSArray *)sections validators:(NSArray *)validators
{
    return [self initWithSections:sections predicates:@{} validators:validators];
}

- (instancetype)initWithSections:(NSArray *)sections predicates:(NSDictionary *)predicates validators:(NSArray *)validators
{
    if (self = [super init]) {
        _sections = sections.copy;
        _predicates = predicates.copy;
        _validators = validators.copy;
    }
    return self;
}

@end
