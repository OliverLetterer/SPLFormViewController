//
//  SPLEnumUIAdapter.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SPLFormViewController/SPLFormular.h>



typedef void(^SPLEnumUIAdapterDownloadCompletionHandler)(NSArray *humanReadableOptions, NSArray *values, NSError *error);

/**
 @abstract  <#abstract comment#>
 */
@interface SPLEnumUIAdapter : NSObject <SPLFieldUIAdapter>

@property (nonatomic, copy) dispatch_block_t changeBlock;
@property (nonatomic, unsafe_unretained) id object;

@property (nonatomic, readonly) NSArray *values;
@property (nonatomic, readonly) NSArray *options;

@property (nonatomic, readonly) NSString *placeholder;
@property (nonatomic, copy) void(^downloadBlock)(SPLEnumUIAdapterDownloadCompletionHandler);

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithHumanReadableOptions:(NSArray *)options values:(NSArray *)values NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithKeyPath:(NSString *)keyPath fromValues:(NSArray *)values;
- (instancetype)initWithPlaceholder:(NSString *)placeholder downloadableContent:(void(^)(SPLEnumUIAdapterDownloadCompletionHandler completionHandler))downloadBlock;

@end
