//
//  SPLSelectEnumValuesViewController.m
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "SPLSelectEnumValuesViewController.h"
#import "SPLFormTableViewCell.h"
#import "SPLFormular.h"

typedef NS_ENUM(NSInteger, SPLSelectEnumValuesViewControllerType) {
    SPLSelectEnumValuesViewControllerTypeSingleSelection,
    SPLSelectEnumValuesViewControllerTypeArraySelection,
    SPLSelectEnumValuesViewControllerTypeSetSelection,
};



@interface SPLSelectEnumValuesViewController ()

@property (nonatomic, readonly) SPLSelectEnumValuesViewControllerType type;
@property (nonatomic, readonly) NSSet *initialSelectedObjects;
@property (nonatomic, readonly) NSMutableSet *selectedObjects;

@property (nonatomic, readonly) UIBarButtonItem *cancelBarButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *saveBarButtonItem;

@end



@implementation SPLSelectEnumValuesViewController

#pragma mark - setters and getters

- (void)setAdditionalRightBarButtonItems:(NSArray *)additionalRightBarButtonItems
{
    if (additionalRightBarButtonItems != _additionalRightBarButtonItems) {
        _additionalRightBarButtonItems = additionalRightBarButtonItems;

        [self _updateBarButtonItems];
    }
}

- (void)setHumanReadableOptions:(NSArray *)options values:(NSArray *)values
{
    NSParameterAssert(options.count == values.count);

    if (options != _options || values != _values) {
        _options = options;
        _values = values;

        if (self.isViewLoaded) {
            [self.tableView reloadData];
        }
    }
}

- (UIBarButtonItem *)cancelBarButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(_cancelTapped:)];
}

- (UIBarButtonItem *)saveBarButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(_saveTapped:)];
}

#pragma mark - Initialization

- (instancetype)initWithHumanReadableOptions:(NSArray *)options values:(NSArray *)values forField:(SPLField *)field object:(id)object
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        _options = options;
        _values = values;
        _field = field;
        _object = object;
        _selectedObjects = [NSMutableSet set];
        self.title = field.title;

        id value = [object valueForKey:field.property];
        Class propertyClass = [field propertyClassWithObject:object];
        if (propertyClass == [NSArray class]) {
            _type = SPLSelectEnumValuesViewControllerTypeArraySelection;

            if (value) {
                [_selectedObjects addObjectsFromArray:value];
            }
        } else if (propertyClass == [NSSet class]) {
            _type = SPLSelectEnumValuesViewControllerTypeSetSelection;

            if (value) {
                [_selectedObjects unionSet:value];
            }
        } else {
            _type = SPLSelectEnumValuesViewControllerTypeSingleSelection;

            if (value) {
                [_selectedObjects addObject:value];
            }
        }

        _initialSelectedObjects = _selectedObjects.copy;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self _updateBarButtonItems];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SPLFormTableViewCell";

    SPLFormTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SPLFormTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    id value = self.values[indexPath.row];
    cell.accessoryType = [self.selectedObjects containsObject:value] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.textLabel.text = self.options[indexPath.row];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id value = self.values[indexPath.row];

    switch (self.type) {
        case SPLSelectEnumValuesViewControllerTypeSingleSelection:
            return [self.delegate selectEnumValuesViewController:self didSelectValue:value];
            break;
        case SPLSelectEnumValuesViewControllerTypeArraySelection:
        case SPLSelectEnumValuesViewControllerTypeSetSelection:
            if ([self.selectedObjects containsObject:value]) {
                [self.selectedObjects removeObject:value];
            } else {
                [self.selectedObjects addObject:value];
            }

            [tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
            [self _updateBarButtonItems];
            break;
    }
}

#pragma mark - Private category implementation ()

- (void)_cancelTapped:(UIBarButtonItem *)sender
{
    [self.delegate selectEnumValuesViewControllerDidCancel:self];
}

- (void)_saveTapped:(UIBarButtonItem *)sender
{
    switch (self.type) {
        case SPLSelectEnumValuesViewControllerTypeSingleSelection:
            [NSException raise:NSInternalInconsistencyException format:@"SPLSelectEnumValuesViewControllerTypeSingleSelection not supported here"];
            break;
        case SPLSelectEnumValuesViewControllerTypeArraySelection:
            [self.delegate selectEnumValuesViewController:self didSelectValue:self.selectedObjects.allObjects];
            break;
        case SPLSelectEnumValuesViewControllerTypeSetSelection:
            [self.delegate selectEnumValuesViewController:self didSelectValue:self.selectedObjects.copy];
            break;
    }
}

- (void)_updateBarButtonItems
{
    if ([self.initialSelectedObjects isEqual:self.selectedObjects]) {
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    } else if (!self.navigationItem.leftBarButtonItem) {
        [self.navigationItem setLeftBarButtonItem:self.cancelBarButtonItem animated:YES];
    }

    NSArray *rightBarButtonItems = [self.initialSelectedObjects isEqual:self.selectedObjects] ? @[] : @[ self.saveBarButtonItem ];
    rightBarButtonItems = [rightBarButtonItems arrayByAddingObjectsFromArray:self.additionalRightBarButtonItems];

    BOOL animated = self.navigationItem.rightBarButtonItems.count != rightBarButtonItems.count;
    [self.navigationItem setRightBarButtonItems:rightBarButtonItems animated:animated];
}

@end
