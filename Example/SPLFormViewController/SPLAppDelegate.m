//
//  SPLAppDelegate.m
//  SPLFormViewController
//
//  Created by CocoaPods on 12/30/2014.
//  Copyright (c) 2014 Oliver Letterer. All rights reserved.
//

#import "SPLAppDelegate.h"
#import <SPLFormViewController.h>

@interface TestObject : NSObject
@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSString *email;
@property (nonatomic, readonly) NSString *password;
@property (nonatomic, readonly) NSString *passwordConfirmation;

@property (nonatomic, readonly) NSNumber *hasHomepage;
@property (nonatomic, readonly) NSString *homepage;

@property (nonatomic, readonly) NSNumber *isHuman;
@property (nonatomic, readonly) NSString *firstName;
@property (nonatomic, readonly) NSString *lastName;
@property (nonatomic, readonly) NSString *street;
@property (nonatomic, readonly) NSString *zip;
@property (nonatomic, readonly) NSString *city;
@property (nonatomic, readonly) NSString *country;
@end
@implementation TestObject @end



@implementation SPLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];

    SPLFormViewController *viewController = [[SPLFormViewController alloc] initWithObject:[TestObject new]];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:viewController];

    SPLSection *section0 = [[SPLSection alloc] initWithIdentifier:@"1" title:NSLocalizedString(@"Contact", @"") fields:^NSArray *{
        return @[
                 [[SPLField alloc] initWithProperty:@"firstName" title:NSLocalizedString(@"First name", @"") type:SPLPropertyTypePlainText],
                 [[SPLField alloc] initWithProperty:@"lastName" title:NSLocalizedString(@"Last name", @"") type:SPLPropertyTypePlainText],
                 ];
    }];

    SPLSection *section1 = [[SPLSection alloc] initWithIdentifier:@"0" fields:^NSArray *{
        return @[
                 [[SPLField alloc] initWithProperty:@"username" title:NSLocalizedString(@"Username", @"") type:SPLPropertyTypePlainText],
                 [[SPLField alloc] initWithProperty:@"email" title:NSLocalizedString(@"E-Mail", @"") type:SPLPropertyTypeEMail],
                 [[SPLField alloc] initWithProperty:@"password" title:NSLocalizedString(@"Password", @"") type:SPLPropertyTypePassword],
                 [[SPLField alloc] initWithProperty:@"passwordConfirmation" title:NSLocalizedString(@"Password confirmation", @"") type:SPLPropertyTypePassword],
                 [[SPLField alloc] initWithProperty:@"isHuman" title:NSLocalizedString(@"I am a human", @"") type:SPLPropertyTypeBoolean],
                 [[SPLField alloc] initWithProperty:@"hasHomepage" title:NSLocalizedString(@"Homepage?", @"") type:SPLPropertyTypeBoolean],
                 ];
    }];

    SPLSection *section2 = [[SPLSection alloc] initWithIdentifier:@"2" title:NSLocalizedString(@"Address", @"") fields:^NSArray *{
        return @[
                 [[SPLField alloc] initWithProperty:@"street" title:NSLocalizedString(@"Street", @"") type:SPLPropertyTypePlainText],
                 [[SPLField alloc] initWithProperty:@"zip" title:NSLocalizedString(@"ZIP Code", @"") type:SPLPropertyTypeNumber],
                 [[SPLField alloc] initWithProperty:@"city" title:NSLocalizedString(@"City", @"") type:SPLPropertyTypePlainText],
                 [[SPLField alloc] initWithProperty:@"country" title:NSLocalizedString(@"Country", @"") type:SPLPropertyTypePlainText],
                 ];
    }];

    SPLSection *section3 = [[SPLSection alloc] initWithIdentifier:@"3" title:NSLocalizedString(@"Last section", @"") fields:^NSArray *{
        return @[
                 [[SPLField alloc] initWithProperty:@"homepage" title:NSLocalizedString(@"Homepage", @"") type:SPLPropertyTypeURL],
                 ];
    }];

    NSArray *sections = @[ section0, section1, section2, section3 ];
    NSDictionary *predicates = @{
                                 @"homepage": [NSPredicate predicateWithFormat:@"hasHomepage == NO OR hasHomepage == nil"],
                                 @"username": [NSPredicate predicateWithFormat:@"isHuman == YES"],
                                 @"firstName": [NSPredicate predicateWithFormat:@"isHuman == YES"],
                                 @"lastName": [NSPredicate predicateWithFormat:@"isHuman == YES"],
                                 @"street": [NSPredicate predicateWithFormat:@"isHuman == YES"],
                                 @"zip": [NSPredicate predicateWithFormat:@"isHuman == YES"],
                                 @"city": [NSPredicate predicateWithFormat:@"isHuman == YES"],
                                 @"country": [NSPredicate predicateWithFormat:@"isHuman == YES"],
                                 };
    viewController.formular = [[SPLFormular alloc] initWithSections:sections predicates:predicates];
    viewController.tableView.rowHeight = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 88.0 : 66.0;

    [self.window makeKeyAndVisible];

    return YES;
}

@end
