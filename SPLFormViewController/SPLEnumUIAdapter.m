//
//  SPLEnumUIAdapter.m
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "SPLEnumUIAdapter.h"
#import "SPLFormTableViewCell.h"
#import "SPLSelectEnumValuesViewController.h"


@interface SPLEnumUIAdapter () <SPLSelectEnumValuesViewControllerDelegate>

@end

@implementation SPLEnumUIAdapter

- (NSString *)reuseIdentifier
{
    return @"__InternalSPLFormTableViewCellSPLEnumUIAdapter";
}

- (Class)tableViewCellClass
{
    return [SPLFormTableViewCell class];
}

- (void)enforceConsistencyWithObject:(id)object forField:(SPLField *)field
{
    Class propertyClass = [field propertyClassWithObject:object];
    if (propertyClass == [NSSet class] || propertyClass == [NSArray class]) {
        return;
    }

    for (id value in self.values) {
        if (![value isKindOfClass:propertyClass]) {
            [NSException raise:NSInternalInconsistencyException format:@"Value %@ should be of class %@", value, propertyClass];
        }
    }
}

- (void)configureTableViewCell:(SPLFormTableViewCell *)cell forField:(SPLField *)field
{
    id value = [self.object valueForKey:field.property];

    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    Class propertyClass = [field propertyClassWithObject:self.object];
    if (propertyClass == [NSSet class] || propertyClass == [NSArray class]) {
        NSArray *selectedValues = value;
        cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ selected", @""), @(selectedValues.count)];
    } else if ((self.values.count == 0 && self.downloadBlock) || (value == nil)) {
        cell.detailTextLabel.text = self.placeholder;
    } else {
        id value = [self.object valueForKey:field.property];
        NSInteger index = [self.values indexOfObject:value];

        if (index != NSNotFound) {
            cell.detailTextLabel.text = self.options[index];
        } else {
            cell.detailTextLabel.text = @"";
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath forField:(SPLField *)field
{
    if (self.values.count == 0 && self.downloadBlock) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];

        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicatorView startAnimating];
        [activityIndicatorView sizeToFit];

        SPLFormTableViewCell *cell = (SPLFormTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = activityIndicatorView;
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

        void(^restoreUI)(void) = ^(void) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        };

        void(^completionHandler)(NSArray *humanReadableOptions, NSArray *values, NSError *error) = ^(NSArray *humanReadableOptions, NSArray *values, NSError *error) {
            restoreUI();

            if (error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                                                                message:error.localizedDescription
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                      otherButtonTitles:nil];
                
                return [alert show];
            }

            _options = humanReadableOptions;
            _values = values;
            [self tableView:tableView didSelectRowAtIndexPath:indexPath forField:field];
        };

        return self.downloadBlock(completionHandler);
    } else {
        SPLSelectEnumValuesViewController *viewController = [[SPLSelectEnumValuesViewController alloc] initWithHumanReadableOptions:self.options values:self.values forField:field object:self.object];
        viewController.delegate = self;

        UIViewController *parentViewController = (UIViewController *)tableView.nextResponder;
        while (viewController && ![viewController isKindOfClass:[UIViewController class]]) {
            parentViewController = (UIViewController *)parentViewController.nextResponder;
        }

        [parentViewController.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark - SPLSelectEnumValuesViewControllerDelegate

- (void)selectEnumValuesViewControllerDidCancel:(SPLSelectEnumValuesViewController *)viewController
{
    [viewController.navigationController popViewControllerAnimated:YES];
}

- (void)selectEnumValuesViewController:(SPLSelectEnumValuesViewController *)viewController didSelectValue:(id)value
{
    [self.object setValue:value forKey:viewController.field.property];
    self.changeBlock();

    [viewController.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Initialization

- (instancetype)initWithHumanReadableOptions:(NSArray *)options values:(NSArray *)values
{
    NSParameterAssert(values.count == options.count);

    for (NSString *option in options) {
        if (![option isKindOfClass:[NSString class]]) {
            [NSException raise:NSInternalInconsistencyException format:@"Only string options are allowed"];
        }
    }

    if (self = [super init]) {
        _values = values.copy;
        _options = options.copy;
    }
    return self;
}

- (instancetype)initWithKeyPath:(NSString *)keyPath fromValues:(NSArray *)values
{
    NSArray *options = [values valueForKeyPath:keyPath];
    return [self initWithHumanReadableOptions:options values:values];
}

- (instancetype)initWithPlaceholder:(NSString *)placeholder downloadableContent:(void(^)(SPLEnumUIAdapterDownloadCompletionHandler completionHandler))downloadBlock
{
    if (self = [self initWithHumanReadableOptions:@[] values:@[]]) {
        _placeholder = placeholder;
        _downloadBlock = downloadBlock;
    }
    return self;
}

#pragma mark - Private category implementation ()

@end
