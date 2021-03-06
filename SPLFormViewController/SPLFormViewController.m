//
//  SPLFormViewController.m
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "SPLFormViewController.h"
#import "SPLObjectSnapshot.h"



@interface SPLFormViewController ()
@property (nonatomic, strong) NSArray *visibleSections;
@property (nonatomic, readonly) SPLObjectSnapshot *initialSnapshot;
@property (nonatomic, strong) SPLObjectSnapshot *currentSnapshot;
@end



@implementation SPLFormViewController

#pragma mark - setters and getters

- (SPLSection *)objectAtIndexedSubscript:(NSUInteger)index
{
    return self.visibleSections[index];
}

- (void)setCompletionHandler:(void (^)(BOOL))completionHandler
{
    _completionHandler = completionHandler;
}

- (UIBarButtonItem *)cancelBarButtonItem
{
    if (!_cancelBarButtonItem) {
        _cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(_cancelTapped:)];
    }
    return _cancelBarButtonItem;
}

- (UIBarButtonItem *)saveBarButtonItem
{
    if (!_saveBarButtonItem) {
        _saveBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(_saveTapped:)];
    }
    return _saveBarButtonItem;
}

- (UIBarButtonItem *)activityIndicatorBarButtonItem
{
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicatorView startAnimating];

    return [[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView];
}

- (void)setCurrentSnapshot:(SPLObjectSnapshot *)currentSnapshot
{
    if (currentSnapshot != _currentSnapshot) {
        _currentSnapshot = currentSnapshot;

        if (self.isViewLoaded) {
            [self _updateCancelBarButtonItem];
        }
    }
}

- (void)setObject:(id)object
{
    if (object != _object) {
        _object = object;

        [self _bootstrapObjectToFormular];

        if (self.isViewLoaded) {
            [self.tableView reloadData];
        }
    }
}

- (void)setFormular:(SPLFormular *)formular
{
    if (formular != _formular) {
        for (SPLSection *section in _formular) {
            for (SPLField *field in section) {
                [field.adapter setChangeBlock:nil];
            }
        }

        _formular = formular;
        [self _bootstrapObjectToFormular];

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
                [self _animateSectionDiffFromPreviousSections:previousSections toNewSections:_visibleSections animated:self.view.window != nil];
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem;
    self.navigationItem.rightBarButtonItem = self.saveBarButtonItem;

    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 1.0)];
    tableFooterView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = tableFooterView;

    [self _updateCancelBarButtonItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.visibleSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self[section].fields.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPLField *field = self[indexPath.section][indexPath.row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[field.adapter reuseIdentifier]];
    if (!cell) {
        cell = [[[field.adapter tableViewCellClass] alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[field.adapter reuseIdentifier]];

        if (![field.adapter respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:forField:)]) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }

    cell.textLabel.text = field.title;
    [field.adapter configureTableViewCell:cell forField:field];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPLField *field = self[indexPath.section][indexPath.row];

    if (![field.adapter respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:forField:)]) {
        return [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }

    [field.adapter tableView:tableView didSelectRowAtIndexPath:indexPath forField:field];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self[section].title;
}

#pragma mark - Instance methods

- (BOOL)validate:(SPLField **)failingField
{
    SPLField *field = nil;
    if (![self.formular validateObject:self.object failingField:&field]) {
        __block NSIndexPath *indexPath = nil;

        [self.visibleSections enumerateObjectsUsingBlock:^(SPLSection *section, NSUInteger sectionIndex, BOOL *stop) {
            [section.fields enumerateObjectsUsingBlock:^(SPLField *thisField, NSUInteger fieldIndex, BOOL *stop) {
                if (![field.property isEqualToString:thisField.property]) {
                    return;
                }

                indexPath = [NSIndexPath indexPathForRow:fieldIndex inSection:sectionIndex];
            }];
        }];

        if (indexPath) {
            void(^nowShake)(void) = ^{
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                [self _errorShakeOnView:cell withCompletionHandler:NULL];
            };

            if (![self.tableView.indexPathsForVisibleRows containsObject:indexPath]) {
                [CATransaction begin];
                [CATransaction setCompletionBlock:nowShake];

                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];

                [CATransaction commit];
            } else {
                nowShake();
            }
        }

        if (failingField) {
            *failingField = field;
        }
        return NO;
    }

    return YES;
}

- (void)saveWithCompletionHandler:(void(^)(NSError *error))completionHandler
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completionHandler(nil);
    });
}

#pragma mark - Private category implementation ()

- (void)_bootstrapObjectToFormular
{
    _initialSnapshot = [self.formular snapshotObject:self.object];
    self.currentSnapshot = self.initialSnapshot;

    for (SPLSection *section in self.formular) {
        for (SPLField *field in section) {
            __weak typeof(self) weakSelf = self;
            field.adapter.object = self.object;
            [field.adapter setChangeBlock:^{
                __strong typeof(self) strongSelf = weakSelf;
                [strongSelf setVisibleSections:[strongSelf.formular visibleSectionsWithObject:strongSelf.object] animated:YES];
                strongSelf.currentSnapshot = [strongSelf.formular snapshotObject:strongSelf.object];
            }];
        }
    }

    [self.formular enforceConsistencyWithObject:self.object];
    self.visibleSections = [self.formular visibleSectionsWithObject:self.object];
}

- (void)_animateSectionDiffFromPreviousSections:(NSArray *)previousSections toNewSections:(NSArray *)newSections animated:(BOOL)animated
{
    SPLSectionDiff *diff = [[SPLSectionDiff alloc] initWithSections:newSections previousSections:previousSections];
    UITableViewRowAnimation animation = animated ? UITableViewRowAnimationTop : UITableViewRowAnimationNone;

    [self.tableView beginUpdates];

    [self.tableView deleteSections:diff.deletedSections withRowAnimation:animation];
    [self.tableView deleteRowsAtIndexPaths:diff.deletedIndexPaths withRowAnimation:animation];

    [self.tableView insertSections:diff.insertedSections withRowAnimation:animation];
    [self.tableView insertRowsAtIndexPaths:diff.insertedIndexPaths withRowAnimation:animation];

    [self.tableView endUpdates];
}

- (void)_updateCancelBarButtonItem
{
    if (_cancelBarButtonItem) {
        BOOL snapshotIsEqual = [self.currentSnapshot isEqualToSnapshot:self.initialSnapshot];
        BOOL firstInNavigationController = self.navigationController.viewControllers.firstObject == self;
        BOOL isBeingPresented = self.isBeingPresented || self.parentViewController.isBeingPresented || self.parentViewController.parentViewController.isBeingPresented;

        if (snapshotIsEqual && !firstInNavigationController && !isBeingPresented) {
            [self.navigationItem setLeftBarButtonItem:nil animated:YES];
        } else if (self.navigationItem.leftBarButtonItem != self.cancelBarButtonItem) {
            [self.navigationItem setLeftBarButtonItem:self.cancelBarButtonItem animated:YES];
        }
    }
}

- (void)_cancelTapped:(UIBarButtonItem *)sender
{
    [self.initialSnapshot restoreObject:self.object];

    if (self.completionHandler) {
        self.completionHandler(NO);
        self.completionHandler = nil;
    }
}

- (void)_saveTapped:(UIBarButtonItem *)sender
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];

    if (![self validate:NULL]) {
        return;
    }

    UIBarButtonItem *previousBarButtonItem = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = self.activityIndicatorBarButtonItem;
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    void(^cleanupUI)(void) = ^{
        self.navigationItem.rightBarButtonItem = previousBarButtonItem;
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];

        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    };

    [self saveWithCompletionHandler:^(NSError *error) {
        cleanupUI();

        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription
                                                            message:error.localizedFailureReason
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        if (self.completionHandler) {
            self.completionHandler(YES);
            self.completionHandler = nil;
        }
    }];
}

- (UITextField *)_findTextFieldInView:(UIView *)view
{
    for (UIView *subview in view.subviews) {
        UITextField *textField = nil;
        if ([subview isKindOfClass:[UITextField class]]) {
            textField = (UITextField *)subview;
        } else {
            textField = [self _findTextFieldInView:subview];
        }

        if (textField) {
            return textField;
        }
    }

    return nil;
}

- (void)_errorShakeOnView:(UIView *)view withCompletionHandler:(dispatch_block_t)completionHandler
{
    static CGFloat intensity = 60.0;

    [UIView animateKeyframesWithDuration:0.4 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModePaced animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.2 animations:^{
            view.transform = CGAffineTransformMakeTranslation(-intensity, 0.0);
        }];

        [UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.2 animations:^{
            view.transform = CGAffineTransformMakeTranslation(intensity, 0.0);
        }];

        [UIView addKeyframeWithRelativeStartTime:0.4 relativeDuration:0.2 animations:^{
            view.transform = CGAffineTransformMakeTranslation(-intensity, 0.0);
        }];

        [UIView addKeyframeWithRelativeStartTime:0.6 relativeDuration:0.2 animations:^{
            view.transform = CGAffineTransformMakeTranslation(intensity, 0.0);
        }];

        [UIView addKeyframeWithRelativeStartTime:0.8 relativeDuration:0.2 animations:^{
            view.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
        }];
    } completion:^(BOOL finished) {
        UITextField *textField = [self _findTextFieldInView:view];

        if (textField) {
            [textField becomeFirstResponder];
        }

        if (completionHandler) {
            completionHandler();
        }
    }];
}


@end
