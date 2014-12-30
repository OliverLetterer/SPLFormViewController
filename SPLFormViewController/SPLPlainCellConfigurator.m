//
//  SPLPlainCellConfigurator.m
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "SPLPlainCellConfigurator.h"
#import "SPLFormSwitchCell.h"
#import "SPLFormTextFieldCell.h"
#import "SPLFormTableViewCell.h"
#import <objc/runtime.h>

static double doubleValue(NSString *text)
{
    return [text stringByReplacingOccurrencesOfString:@"," withString:@"."].doubleValue;
}

@implementation SPLField (SPLPlainCellConfigurator)

- (instancetype)initWithProperty:(NSString *)property title:(NSString *)title type:(SPLPropertyType)type
{
    return [self initWithProperty:property title:title configurator:[[SPLPlainCellConfigurator alloc] initWithType:type]];
}

@end



static const void * fieldKey = &fieldKey;
@implementation SPLPlainCellConfigurator

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if (aSelector == @selector(tableView:didSelectRowAtIndexPath:forField:)) {
        return self.type == SPLPropertyTypeBoolean;
    }

    return [super respondsToSelector:aSelector];
}

- (NSString *)reuseIdentifier
{
    switch (self.type) {
        case SPLPropertyTypePlainText:
        case SPLPropertyTypeEMail:
        case SPLPropertyTypePassword:
        case SPLPropertyTypeURL:
        case SPLPropertyTypeNumber:
        case SPLPropertyTypePrice:
            return @"__InternalSPLFormTextFieldCell";
            break;
        case SPLPropertyTypeBoolean:
            return @"__InternalSPLFormSwitchCell";
            break;
    }
}

- (Class)tableViewCellClass
{
    switch (self.type) {
        case SPLPropertyTypePlainText:
        case SPLPropertyTypeEMail:
        case SPLPropertyTypePassword:
        case SPLPropertyTypeURL:
        case SPLPropertyTypeNumber:
        case SPLPropertyTypePrice:
            return [SPLFormTextFieldCell class];
            break;
        case SPLPropertyTypeBoolean:
            return [SPLFormSwitchCell class];
            break;
    }
}

- (void)enforceConsistencyWithObject:(id)object forField:(SPLField *)field
{
    switch (self.type) {
        case SPLPropertyTypePlainText:
        case SPLPropertyTypeEMail:
        case SPLPropertyTypePassword:
        case SPLPropertyTypeURL:
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
    }
}

- (void)configureTableViewCell:(SPLFormTextFieldCell *)cell forField:(SPLField *)field
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    id value = [self.object valueForKey:field.property];

    switch (self.type) {
        case SPLPropertyTypePlainText: {
            cell.textField.text = value;
            cell.textField.placeholder = cell.textLabel.text;
            cell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            cell.textField.autocorrectionType = UITextAutocorrectionTypeYes;
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
            cell.textField.text = value ? [NSString stringWithFormat:@"%.0lf", [value doubleValue]] : nil;
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
        case SPLPropertyTypeBoolean: {
            SPLFormSwitchCell *switchCell = (SPLFormSwitchCell *)cell;
            [switchCell.switchControl setOn:[value boolValue] animated:NO];
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
    SPLFormSwitchCell *cell = (SPLFormSwitchCell *)[tableView cellForRowAtIndexPath:indexPath];

    BOOL boolValue = !cell.switchControl.isOn;
    [self.object setValue:@(boolValue) forKey:field.property];
    [cell.switchControl setOn:boolValue animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.changeBlock();
}

- (instancetype)initWithType:(SPLPropertyType)type
{
    if (self = [super init]) {
        _type = type;
    }
    return self;
}

- (void)_textFieldEditingChanged:(UITextField *)textField
{
    SPLField *field = objc_getAssociatedObject(textField, fieldKey);
    NSParameterAssert(field);

    switch (self.type) {
        case SPLPropertyTypePlainText:
        case SPLPropertyTypeEMail:
        case SPLPropertyTypePassword:
        case SPLPropertyTypeURL:
            [self.object setValue:textField.text forKey:field.property];
            break;
        case SPLPropertyTypeNumber:
        case SPLPropertyTypePrice:
            if ([field propertyClassWithObject:self.object] == [NSNumber class]) {
                [self.object setValue:@(doubleValue(textField.text)) forKey:field.property];
            } else {
                [self.object setValue:textField.text forKey:field.property];
            }
            break;
        case SPLPropertyTypeBoolean:
            [self doesNotRecognizeSelector:_cmd];
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
