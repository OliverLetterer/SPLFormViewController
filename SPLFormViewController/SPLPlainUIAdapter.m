//
//  SPLPlainUIAdapter.m
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "SPLPlainUIAdapter.h"
#import "SPLFormSwitchCell.h"
#import "SPLFormTextFieldCell.h"
#import "SPLFormTableViewCell.h"
#import <objc/runtime.h>
#import "_SPLDateTimeViewController.h"

static double doubleValue(NSString *text)
{
    return [text stringByReplacingOccurrencesOfString:@"," withString:@"."].doubleValue;
}

@implementation SPLField (SPLPlainUIAdapter)

- (instancetype)initWithProperty:(NSString *)property title:(NSString *)title type:(SPLPropertyType)type
{
    return [self initWithProperty:property title:title adapter:[[SPLPlainUIAdapter alloc] initWithType:type]];
}

@end



static const void * fieldKey = &fieldKey;

@interface SPLPlainUIAdapter () <_SPLDateTimeViewControllerDelegate> @end

@implementation SPLPlainUIAdapter

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if (aSelector == @selector(tableView:didSelectRowAtIndexPath:forField:)) {
        return self.type == SPLPropertyTypeBoolean || self.type == SPLPropertyTypeDate || self.type == SPLPropertyTypeDateTime;
    }

    return [super respondsToSelector:aSelector];
}

- (NSString *)reuseIdentifier
{
    switch (self.type) {
        case SPLPropertyTypeHumanText:
        case SPLPropertyTypeMachineText:
        case SPLPropertyTypeEMail:
        case SPLPropertyTypePassword:
        case SPLPropertyTypeURL:
        case SPLPropertyTypeNumber:
        case SPLPropertyTypePrice:
        case SPLPropertyTypeIPAddress:
            return @"__InternalSPLFormTextFieldCell";
            break;
        case SPLPropertyTypeDate:
        case SPLPropertyTypeDateTime:
            return @"__InternalSPLFormTextFieldCellDateTimePicker";
            break;
        case SPLPropertyTypeBoolean:
            return @"__InternalSPLFormSwitchCell";
            break;
    }
}

- (Class)tableViewCellClass
{
    switch (self.type) {
        case SPLPropertyTypeHumanText:
        case SPLPropertyTypeMachineText:
        case SPLPropertyTypeEMail:
        case SPLPropertyTypePassword:
        case SPLPropertyTypeURL:
        case SPLPropertyTypeNumber:
        case SPLPropertyTypePrice:
        case SPLPropertyTypeIPAddress:
            return [SPLFormTextFieldCell class];
            break;
        case SPLPropertyTypeDate:
        case SPLPropertyTypeDateTime:
            return [SPLFormTableViewCell class];
            break;
        case SPLPropertyTypeBoolean:
            return [SPLFormSwitchCell class];
            break;
    }
}

- (void)enforceConsistencyWithObject:(id)object forField:(SPLField *)field
{
    switch (self.type) {
        case SPLPropertyTypeHumanText:
        case SPLPropertyTypeMachineText:
        case SPLPropertyTypeEMail:
        case SPLPropertyTypePassword:
        case SPLPropertyTypeURL:
        case SPLPropertyTypeIPAddress:
            if ([field propertyClassWithObject:object] != [NSString class]) {
                [NSException raise:NSInternalInconsistencyException format:@"%@[%@] must be NSString typed", [object class], field.property];
            }
            break;
        case SPLPropertyTypeNumber:
            if ([field propertyClassWithObject:object] != [NSNumber class] && [field propertyClassWithObject:object] != [NSString class]) {
                [NSException raise:NSInternalInconsistencyException format:@"%@[%@] must be NSNumber or NSString typed", [object class], field.property];
            }
            break;
        case SPLPropertyTypePrice:
        case SPLPropertyTypeBoolean:
            if ([field propertyClassWithObject:object] != [NSNumber class]) {
                [NSException raise:NSInternalInconsistencyException format:@"%@[%@] must be NSNumber typed", [object class], field.property];
            }
            break;
        case SPLPropertyTypeDate:
        case SPLPropertyTypeDateTime:
            if ([field propertyClassWithObject:object] != [NSDate class]) {
                [NSException raise:NSInternalInconsistencyException format:@"%@[%@] must be NSDate typed", [object class], field.property];
            }
            break;
    }
}

- (void)configureTableViewCell:(SPLFormTextFieldCell *)cell forField:(SPLField *)field
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    id value = [self.object valueForKey:field.property];

    switch (self.type) {
        case SPLPropertyTypeHumanText: {
            cell.textField.text = value;
            cell.textField.placeholder = cell.textLabel.text;
            cell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            cell.textField.autocorrectionType = UITextAutocorrectionTypeYes;
            cell.textField.accessibilityLabel = cell.textLabel.text;
            cell.textField.secureTextEntry = NO;
            cell.textField.keyboardType = UIKeyboardTypeAlphabet;
            break;
        }
        case SPLPropertyTypeMachineText: {
            cell.textField.text = value;
            cell.textField.placeholder = cell.textLabel.text;
            cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
            cell.textField.accessibilityLabel = cell.textLabel.text;
            cell.textField.secureTextEntry = NO;
            cell.textField.keyboardType = UIKeyboardTypeAlphabet;
            break;
        }
        case SPLPropertyTypeEMail: {
            cell.textField.text = value;
            cell.textField.placeholder = cell.textLabel.text;
            cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
            cell.textField.accessibilityLabel = cell.textLabel.text;
            cell.textField.secureTextEntry = NO;
            cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
            break;
        }
        case SPLPropertyTypePassword: {
            cell.textField.text = value;
            cell.textField.placeholder = cell.textLabel.text;
            cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
            cell.textField.accessibilityLabel = cell.textLabel.text;
            cell.textField.secureTextEntry = YES;
            cell.textField.keyboardType = UIKeyboardTypeAlphabet;
            break;
        }
        case SPLPropertyTypeURL: {
            cell.textField.text = value;
            cell.textField.placeholder = cell.textLabel.text;
            cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            cell.textField.autocorrectionType = UITextAutocorrectionTypeYes;
            cell.textField.accessibilityLabel = cell.textLabel.text;
            cell.textField.secureTextEntry = NO;
            cell.textField.keyboardType = UIKeyboardTypeURL;
            break;
        }
        case SPLPropertyTypeNumber: {
            if ([field propertyClassWithObject:self.object] == [NSNumber class]) {
                cell.textField.text = value ? [NSString stringWithFormat:@"%.0lf", [value doubleValue]] : nil;
            } else {
                cell.textField.text = value;
            }

            cell.textField.placeholder = cell.textLabel.text;
            cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
            cell.textField.accessibilityLabel = cell.textLabel.text;
            cell.textField.secureTextEntry = NO;
            cell.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            break;
        }
        case SPLPropertyTypePrice: {
            cell.textField.text = value ? [NSString stringWithFormat:@"%0.02lf", [value doubleValue]] : nil;
            cell.textField.placeholder = cell.textLabel.text;
            cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
            cell.textField.accessibilityLabel = cell.textLabel.text;
            cell.textField.secureTextEntry = NO;
            cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
            break;
        }
        case SPLPropertyTypeIPAddress: {
            cell.textField.text = value ? [NSString stringWithFormat:@"%@", value] : nil;
            cell.textField.placeholder = cell.textLabel.text;
            cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
            cell.textField.accessibilityLabel = cell.textLabel.text;
            cell.textField.secureTextEntry = NO;
            cell.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            break;
        }
        case SPLPropertyTypeBoolean: {
            SPLFormSwitchCell *switchCell = (SPLFormSwitchCell *)cell;
            [switchCell.switchControl setOn:[value boolValue] animated:NO];
            break;
        }
        case SPLPropertyTypeDate:
        case SPLPropertyTypeDateTime:{
            SPLFormTableViewCell *formCell = (SPLFormTableViewCell *)cell;

            if (value) {
                if (self.type == SPLPropertyTypeDate) {
                    formCell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:value dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
                } else {
                    formCell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:value dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
                }
            } else {
                formCell.detailTextLabel.text = nil;
            }
            break;
        }
    }

    if ([cell isKindOfClass:[SPLFormSwitchCell class]]) {
        SPLFormSwitchCell *switchCell = (SPLFormSwitchCell *)cell;
        for (id target in switchCell.switchControl.allTargets) {
            [switchCell.switchControl removeTarget:target action:@selector(_switchControlChanged:) forControlEvents:UIControlEventValueChanged];
        }

        [switchCell.switchControl addTarget:self action:@selector(_switchControlChanged:) forControlEvents:UIControlEventValueChanged];
        objc_setAssociatedObject(switchCell.switchControl, fieldKey, field, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else if ([cell isKindOfClass:[SPLFormTextFieldCell class]]) {
        for (id target in cell.textField.allTargets) {
            [cell.textField removeTarget:target action:@selector(_textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        }

        [cell.textField addTarget:self action:@selector(_textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        objc_setAssociatedObject(cell.textField, fieldKey, field, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath forField:(SPLField *)field
{
    switch (self.type) {
        case SPLPropertyTypeHumanText:
        case SPLPropertyTypeMachineText:
        case SPLPropertyTypeEMail:
        case SPLPropertyTypePassword:
        case SPLPropertyTypeURL:
        case SPLPropertyTypeNumber:
        case SPLPropertyTypePrice:
        case SPLPropertyTypeIPAddress: {
            SPLFormTextFieldCell *cell = (SPLFormTextFieldCell *)[tableView cellForRowAtIndexPath:indexPath];
            [cell.textField becomeFirstResponder];
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            break;
        }
        case SPLPropertyTypeBoolean: {
            SPLFormSwitchCell *cell = (SPLFormSwitchCell *)[tableView cellForRowAtIndexPath:indexPath];

            BOOL boolValue = !cell.switchControl.isOn;
            [self.object setValue:@(boolValue) forKey:field.property];
            [cell.switchControl setOn:boolValue animated:YES];
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            self.changeBlock();
            break;
        }
        case SPLPropertyTypeDate:
        case SPLPropertyTypeDateTime: {
            SPLFormTableViewCell *cell = (SPLFormTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];

            _SPLDateTimeViewController *viewController = [[_SPLDateTimeViewController alloc] init];
            viewController.date = [self.object valueForKey:field.property];
            viewController.delegate = self;

            objc_setAssociatedObject(viewController, fieldKey, field, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

            if (self.type == SPLPropertyTypeDate) {
                viewController.datePickerMode = UIDatePickerModeDate;
            } else if (self.type == SPLPropertyTypeDateTime) {
                viewController.datePickerMode = UIDatePickerModeDateAndTime;
            }

            viewController.modalPresentationStyle = UIModalPresentationPopover;
            viewController.popoverPresentationController.sourceView = cell;
            viewController.popoverPresentationController.sourceRect = cell.bounds;

            UIViewController *parentViewController = (UIViewController *)tableView.nextResponder;
            while (viewController && ![viewController isKindOfClass:[UIViewController class]]) {
                parentViewController = (UIViewController *)parentViewController.nextResponder;
            }

            [parentViewController presentViewController:viewController animated:YES completion:NULL];
            break;
        }
    }
}

- (instancetype)initWithType:(SPLPropertyType)type
{
    if (self = [super init]) {
        _type = type;
    }
    return self;
}

- (void)dateTimeViewController:(_SPLDateTimeViewController *)viewController didSelectDate:(NSDate *)date
{
    SPLField *field = objc_getAssociatedObject(viewController, fieldKey);
    NSParameterAssert(field);

    SPLFormTableViewCell *cell = (SPLFormTableViewCell *)viewController.popoverPresentationController.sourceView;

    if (self.type == SPLPropertyTypeDate) {
        cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    } else {
        cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
    }

    [self.object setValue:date forKey:field.property];
    self.changeBlock();
}

- (void)_textFieldEditingChanged:(UITextField *)textField
{
    SPLField *field = objc_getAssociatedObject(textField, fieldKey);
    NSParameterAssert(field);

    switch (self.type) {
        case SPLPropertyTypeHumanText:
        case SPLPropertyTypeMachineText:
        case SPLPropertyTypeEMail:
        case SPLPropertyTypePassword:
        case SPLPropertyTypeURL:
        case SPLPropertyTypeIPAddress:
            [self.object setValue:textField.text forKey:field.property];
            self.changeBlock();
            break;
        case SPLPropertyTypeNumber:
        case SPLPropertyTypePrice:
            if ([field propertyClassWithObject:self.object] == [NSNumber class]) {
                [self.object setValue:@(doubleValue(textField.text)) forKey:field.property];
            } else {
                [self.object setValue:textField.text forKey:field.property];
            }
            self.changeBlock();
            break;
        case SPLPropertyTypeBoolean:
            [self doesNotRecognizeSelector:_cmd];
            break;
        case SPLPropertyTypeDate:
        case SPLPropertyTypeDateTime:
            return;
            break;
    }
}

- (void)_switchControlChanged:(UISwitch *)sender
{
    SPLField *field = objc_getAssociatedObject(sender, fieldKey);
    NSParameterAssert(field);

    [self.object setValue:@(sender.isOn) forKey:field.property];
    self.changeBlock();
}

@end
