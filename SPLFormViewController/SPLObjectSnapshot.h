//
//  SPLObjectSnapshot.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <SPLFormular.h>



/**
 @abstract  <#abstract comment#>
 */
@interface SPLObjectSnapshot : NSObject

- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (BOOL)isEqual:(id)object;
- (BOOL)isEqualToSnapshot:(SPLObjectSnapshot *)snapshot;

- (void)restoreObject:(id)object;

@end



@interface SPLFormular (SPLObjectSnapshot)
- (SPLObjectSnapshot *)snapshotObject:(id)object;
@end
