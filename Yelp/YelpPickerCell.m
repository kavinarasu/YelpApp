//
//  YelpPickerCell.m
//  Yelp
//
//  Created by Kavin Arasu on 11/1/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import "YelpPickerCell.h"

@interface YelpPickerCell () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *yelpPickerView;



@end

@implementation YelpPickerCell


- (void)awakeFromNib {
    // Initialization code
//    self.options = [[NSMutableArray alloc] initWithArray:@[@""]];

    [self setOptions:@[@"Hello"]];
//    NSLog(@"This is %@", self.options);
//        NSLog(@"This is %@", self.options[0]);
    self.yelpPickerView.dataSource = self;
    self.yelpPickerView.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (void) setOptions:(NSArray *)options {
    _options = options;
    [self.yelpPickerView reloadAllComponents];
    [self setSelectedIndex:0];
}

- (void) setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    [self.yelpPickerView selectRow:selectedIndex inComponent:0 animated:YES];
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.options.count;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSLog(@"This is %ld", row);
    return self.options[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.delegate yelpPickerCell:self didUpdateValue:row];
}


@end
