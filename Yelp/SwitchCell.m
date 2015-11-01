//
//  SwitchCell.m
//  Yelp
//
//  Created by Kavin Arasu on 11/1/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import "SwitchCell.h"

@interface SwitchCell()

@property (weak, nonatomic) IBOutlet UISwitch *filterSwitch;


- (IBAction)filterSwitchChanged:(id)sender;

@end
@implementation SwitchCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setOn:(BOOL)on {
    [self setOn:on animated:NO];
}

- (void) setOn:(BOOL)on animated:(BOOL) animated {
    _on = on;
    [self.filterSwitch setOn:YES animated:animated];
}

- (IBAction)filterSwitchChanged:(id)sender {
    [self.delegate switchCell:self didUpdateValue:self.filterSwitch.on];
}
@end
