//
//  CollapsibleCell.m
//  Yelp
//
//  Created by Kavin Arasu on 11/2/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import "CollapsibleCell.h"

@interface CollapsibleCell ()
@property (weak, nonatomic) IBOutlet UIImageView *arrowImage;

@end

@implementation CollapsibleCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setHidden:(BOOL)hidden {
    NSLog(@"Enabling for %@", self.filterLabel.text);
    NSInteger value = hidden ? 0 : 1;
    self.arrowImage.alpha = value;
    [self reloadInputViews];
}

@end
