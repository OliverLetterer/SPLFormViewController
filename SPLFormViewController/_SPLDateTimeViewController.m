//
//  _SPLDateTimeViewController.m
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import "_SPLDateTimeViewController.h"



@interface _SPLDateTimeViewController ()

@property (nonatomic, strong) UIDatePicker *datePicker;

@end



@implementation _SPLDateTimeViewController

#pragma mark - setters and getters

- (void)setDate:(NSDate *)date
{
    if (date != _date) {
        _date = date;

        if (self.isViewLoaded && _date) {
            [self.datePicker setDate:_date animated:NO];
        }
    }
}

- (void)setDatePickerMode:(UIDatePickerMode)datePickerMode
{
    if (datePickerMode != _datePickerMode) {
        _datePickerMode = datePickerMode;

        if (self.isViewLoaded) {
            [self.datePicker setDatePickerMode:datePickerMode];
        }
    }
}

#pragma mark - Initialization

- (instancetype)init
{
    if (self = [super init]) {
        _date = [NSDate date];
        _datePickerMode = UIDatePickerModeDateAndTime;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];

    self.datePicker = [[UIDatePicker alloc] initWithFrame:self.view.bounds];
    if (self.date) {
        self.datePicker.date = self.date;
    }
    self.datePicker.datePickerMode = self.datePickerMode;
    self.datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.datePicker];
}

#pragma mark - Private category implementation ()

- (void)_valueChanged:(UIDatePicker *)sender
{
    _date = sender.date;
    [self.delegate dateTimeViewController:self didSelectDate:self.date];
}

@end
