//
//  SPLFormular.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@class SPLField;

@protocol SPLCellConfigurator <NSObject>

@property (nonatomic, copy) dispatch_block_t changeBlock;
@property (nonatomic, unsafe_unretained) id object;
@property (nonatomic, readonly) NSString *reuseIdentifier;
@property (nonatomic, readonly) Class tableViewCellClass;

@required
- (void)configureTableViewCell:(UITableViewCell *)cell forField:(SPLField *)field;

@optional
- (void)enforceConsistencyWithObject:(id)object forField:(SPLField *)field;

@optional
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath forField:(SPLField *)field;

@end



@interface SPLField : NSObject

@property (nonatomic, readonly) NSString *property;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) id<SPLCellConfigurator> configurator;

- (BOOL)isEqualToField:(SPLField *)field;
- (Class)propertyClassWithObject:(id)object;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithProperty:(NSString *)property title:(NSString *)title configurator:(id<SPLCellConfigurator>)configurator NS_DESIGNATED_INITIALIZER;

@end



@interface SPLSection : NSObject <NSFastEnumeration>

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSArray *fields;

- (BOOL)isEqualToSection:(SPLSection *)section;
- (SPLField *)objectAtIndexedSubscript:(NSUInteger)idx;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithIdentifier:(NSString *)identifier fields:(NSArray /* SPLField */ *(^)())fields;
- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString *)title fields:(NSArray /* SPLField */ *(^)())fields NS_DESIGNATED_INITIALIZER;

@end



@interface SPLSectionDiff : NSObject

@property (nonatomic, readonly) NSArray *deletedIndexPaths;
@property (nonatomic, readonly) NSArray *insertedIndexPaths;
@property (nonatomic, readonly) NSIndexSet *deletedSections;
@property (nonatomic, readonly) NSIndexSet *insertedSections;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithSections:(NSArray *)sections previousSections:(NSArray *)previousSections NS_DESIGNATED_INITIALIZER;

@end



/**
 @abstract <#abstract comment#>
 */
@interface SPLFormular : NSObject <NSFastEnumeration>

@property (nonatomic, readonly) NSArray *sections;
@property (nonatomic, readonly) NSDictionary *predicates;

- (void)enforceConsistencyWithObject:(id)object;
- (NSArray *)visibleSectionsWithObject:(id)object;

- (SPLSection *)objectAtIndexedSubscript:(NSUInteger)idx;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithSections:(NSArray /* SPLSection */ *)sections;
- (instancetype)initWithSections:(NSArray /* SPLSection */ *)sections predicates:(NSDictionary *)predicates NS_DESIGNATED_INITIALIZER;

@end
