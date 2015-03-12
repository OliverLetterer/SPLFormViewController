//
//  SPLAppDelegate.m
//  SPLFormViewController
//
//  Created by CocoaPods on 12/30/2014.
//  Copyright (c) 2014 Oliver Letterer. All rights reserved.
//

#import "SPLAppDelegate.h"
@import SPLFormViewController;

@interface TestObject : NSObject
@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSString *email;
@property (nonatomic, readonly) NSString *password;
@property (nonatomic, readonly) NSString *passwordConfirmation;
@property (nonatomic, readonly) NSDate *date;

@property (nonatomic, readonly) NSNumber *hasHomepage;
@property (nonatomic, readonly) NSString *homepage;

@property (nonatomic, readonly) NSString *hearedAboutUsFrom;
@property (nonatomic, readonly) NSArray *multipleSelection;

@property (nonatomic, readonly) NSNumber *isHuman;
@property (nonatomic, readonly) NSString *firstName;
@property (nonatomic, readonly) NSString *lastName;
@property (nonatomic, readonly) NSString *street;
@property (nonatomic, readonly) NSString *zip;
@property (nonatomic, readonly) NSString *city;
@property (nonatomic, readonly) NSString *country;
@end
@implementation TestObject @end



@implementation SPLAppDelegate {
    UINavigationController *_navigationController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UITableView *tableView = [UITableView appearance];
    tableView.rowHeight = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 88.0 : 66.0;
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];

    UIViewController *firstViewController = [[UIViewController alloc] init];
    firstViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit object" style:UIBarButtonItemStylePlain target:self action:@selector(_edit)];

    _navigationController = [[UINavigationController alloc] initWithRootViewController:firstViewController];
    self.window.rootViewController = _navigationController;
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)_edit
{
    SPLFormViewController *viewController = [[SPLFormViewController alloc] initWithObject:[TestObject new]];
    SPLSection *section0 = [[SPLSection alloc] initWithIdentifier:@"1" title:NSLocalizedString(@"Contact", @"") fields:^NSArray *{
        return @[
                 [[SPLField alloc] initWithProperty:@"firstName" title:NSLocalizedString(@"First name", @"") type:SPLPropertyTypeHumanText],
                 [[SPLField alloc] initWithProperty:@"lastName" title:NSLocalizedString(@"Last name", @"") type:SPLPropertyTypeHumanText],
                 [[SPLField alloc] initWithProperty:@"date" title:NSLocalizedString(@"Date", @"") type:SPLPropertyTypeDate],
                 ];
    }];

    SPLSection *section1 = [[SPLSection alloc] initWithIdentifier:@"0" fields:^NSArray *{
        return @[
                 [[SPLField alloc] initWithProperty:@"username" title:NSLocalizedString(@"Username", @"") type:SPLPropertyTypeHumanText],
                 [[SPLField alloc] initWithProperty:@"email" title:NSLocalizedString(@"E-Mail", @"") type:SPLPropertyTypeEMail],
                 [[SPLField alloc] initWithProperty:@"password" title:NSLocalizedString(@"Password", @"") type:SPLPropertyTypePassword],
                 [[SPLField alloc] initWithProperty:@"passwordConfirmation" title:NSLocalizedString(@"Password confirmation", @"") type:SPLPropertyTypePassword],
                 [[SPLField alloc] initWithProperty:@"isHuman" title:NSLocalizedString(@"I am a human", @"") type:SPLPropertyTypeBoolean],
                 [[SPLField alloc] initWithProperty:@"hasHomepage" title:NSLocalizedString(@"Homepage?", @"") type:SPLPropertyTypeBoolean],
                 ];
    }];

    SPLSection *section2 = [[SPLSection alloc] initWithIdentifier:@"2" title:NSLocalizedString(@"Address", @"") fields:^NSArray *{
        return @[
                 [[SPLField alloc] initWithProperty:@"street" title:NSLocalizedString(@"Street", @"") type:SPLPropertyTypeHumanText],
                 [[SPLField alloc] initWithProperty:@"zip" title:NSLocalizedString(@"ZIP Code", @"") type:SPLPropertyTypeNumber],
                 [[SPLField alloc] initWithProperty:@"city" title:NSLocalizedString(@"City", @"") type:SPLPropertyTypeHumanText],
                 [[SPLField alloc] initWithProperty:@"country" title:NSLocalizedString(@"Country", @"") type:SPLPropertyTypeHumanText],
                 ];
    }];

    SPLEnumUIAdapter *hearedAboutUsFromAdapter = [[SPLEnumUIAdapter alloc] initWithPlaceholder:@"Download URLs" downloadableContent:^(SPLEnumUIAdapterDownloadCompletionHandler completionHandler) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            completionHandler(@[ @"Google", @"A friend" ], @[ @"http://www.google.de", @"Cartman" ], nil);
        });
    }];
    SPLEnumUIAdapter *multiSelection = [[SPLEnumUIAdapter alloc] initWithHumanReadableOptions:@[ @"First option", @"Second option", @"Third option" ]
                                                                                       values:@[ @"First value", @"Second value", @"Third value" ]];
    SPLSection *enums = [[SPLSection alloc] initWithIdentifier:@"ENUMS" title:@"Enum values" fields:^NSArray *{
        return @[
                 [[SPLField alloc] initWithProperty:@"hearedAboutUsFrom" title:@"Von wo kommst du?" adapter:hearedAboutUsFromAdapter ],
                 [[SPLField alloc] initWithProperty:@"multipleSelection" title:@"Mehrfachauswahl" adapter:multiSelection ],
                 ];
    }];

    SPLSection *section3 = [[SPLSection alloc] initWithIdentifier:@"3" title:NSLocalizedString(@"Last section", @"") fields:^NSArray *{
        return @[
                 [[SPLField alloc] initWithProperty:@"homepage" title:NSLocalizedString(@"Homepage", @"") type:SPLPropertyTypeURL],
                 ];
    }];

    NSArray *sections = @[ section0, section1, section2, section3, enums ];
    NSDictionary *predicates = @{
                                 @"homepage": [NSPredicate predicateWithFormat:@"hasHomepage == YES"],
                                 @"username": [NSPredicate predicateWithFormat:@"isHuman == YES"],
                                 @"firstName": [NSPredicate predicateWithFormat:@"isHuman == YES"],
                                 @"lastName": [NSPredicate predicateWithFormat:@"isHuman == YES"],
                                 @"street": [NSPredicate predicateWithFormat:@"isHuman == YES"],
                                 @"zip": [NSPredicate predicateWithFormat:@"isHuman == YES"],
                                 @"city": [NSPredicate predicateWithFormat:@"isHuman == YES"],
                                 @"country": [NSPredicate predicateWithFormat:@"isHuman == YES"],
                                 };

//    SPLFormFieldValidator *validator = [SPLFormFieldValidator validatorWithAllTextFields];
    viewController.formular = [[SPLFormular alloc] initWithSections:sections predicates:predicates validators:@[ [SPLFormFieldValidator validatorWithEqualProperties:@[ @"password", @"passwordConfirmation" ]] ]];

    [viewController setCompletionHandler:^(BOOL savedObject) {
        [_navigationController popToRootViewControllerAnimated:YES];
    }];

    [_navigationController pushViewController:viewController animated:YES];
}

@end
