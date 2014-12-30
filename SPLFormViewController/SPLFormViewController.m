//
//  SPLFormViewController.m
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "SPLFormViewController.h"



@interface SPLFormViewController ()
@property (nonatomic, strong) NSArray *visibleSections;
@end



@implementation SPLFormViewController

#pragma mark - setters and getters

- (void)setFormular:(SPLFormular *)formular
{
    if (formular != _formular) {
        for (SPLSection *section in _formular) {
            for (SPLField *field in section) {
                [field.configurator setChangeBlock:nil];
            }
        }

        _formular = formular;

        for (SPLSection *section in _formular) {
            for (SPLField *field in section) {
                __weak typeof(self) weakSelf = self;
                field.configurator.object = self.object;
                [field.configurator setChangeBlock:^{
                    __strong typeof(self) strongSelf = weakSelf;
                    [strongSelf setVisibleSections:[strongSelf.formular visibleSectionsWithObject:strongSelf.object] animated:YES];
                }];
            }
        }

        [_formular enforceConsistencyWithObject:self.object];
        self.visibleSections = [_formular visibleSectionsWithObject:self.object];

        if (self.isViewLoaded) {
            [self.tableView reloadData];
        }
    }
}

- (void)setVisibleSections:(NSArray *)visibleSections
{
    [self setVisibleSections:visibleSections animated:NO];
}

- (void)setVisibleSections:(NSArray *)visibleSections animated:(BOOL)animated
{
    if (visibleSections != _visibleSections && ![visibleSections isEqual:_visibleSections]) {
        NSArray *previousSections = _visibleSections;
        _visibleSections = visibleSections;

        if (self.isViewLoaded) {
            if (animated) {
                [self _animateSectionDiffFromPreviousSections:previousSections toNewSections:_visibleSections];
            } else {
                [self.tableView reloadData];
            }
        }
    }
}

#pragma mark - Initialization

- (instancetype)initWithObject:(id)object
{
    NSParameterAssert(object);

    if (self = [super init]) {
        _object = object;
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.visibleSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SPLSection *sectionObject = self.visibleSections[section];
    return sectionObject.fields.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPLField *field = self.visibleSections[indexPath.section][indexPath.row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[field.configurator reuseIdentifier]];
    if (!cell) {
        cell = [[[field.configurator tableViewCellClass] alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[field.configurator reuseIdentifier]];

        if (![field.configurator respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:forField:)]) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }

    cell.textLabel.text = field.title;
    [field.configurator configureTableViewCell:cell forField:field];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPLField *field = self.visibleSections[indexPath.section][indexPath.row];

    if (![field.configurator respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:forField:)]) {
        return [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }

    [field.configurator tableView:tableView didSelectRowAtIndexPath:indexPath forField:field];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    SPLSection *sectionObject = self.visibleSections[section];
    return sectionObject.title;
}

#pragma mark - Private category implementation ()

- (void)_animateSectionDiffFromPreviousSections:(NSArray *)previousSections toNewSections:(NSArray *)newSections
{
    SPLSectionDiff *diff = [[SPLSectionDiff alloc] initWithSections:newSections previousSections:previousSections];
    [self.tableView beginUpdates];

    [self.tableView deleteSections:diff.deletedSections withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView deleteRowsAtIndexPaths:diff.deletedIndexPaths withRowAnimation:UITableViewRowAnimationTop];

    [self.tableView insertSections:diff.insertedSections withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView insertRowsAtIndexPaths:diff.insertedIndexPaths withRowAnimation:UITableViewRowAnimationTop];

    [self.tableView endUpdates];
}

@end
