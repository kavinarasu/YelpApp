//
//  YelpContentCell.m
//  Yelp
//
//  Created by Kavin Arasu on 10/29/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import "YelpContentCell.h"
#import "UIImageView+AFNetworking.h"

@interface YelpContentCell() 
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *costLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewsLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *reviewsImageView;

@end

@implementation YelpContentCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setYelpBusiness:(YelpBusiness *)yelpBusiness {
    _yelpBusiness = yelpBusiness;
    [self.thumbnailImageView setImageWithURL:self.yelpBusiness.imageUrl];
    self.nameLabel.text = self.yelpBusiness.name;
    self.distanceLabel.text = self.yelpBusiness.distance;
    self.reviewsLabel.text = [NSString stringWithFormat:@"%@ Reviews", self.yelpBusiness.reviewCount];
    self.addressLabel.text = self.yelpBusiness.address;
    self.categoryLabel.text = self.yelpBusiness.categories;
    [self.reviewsImageView setImageWithURL:self.yelpBusiness.ratingImageUrl];

}

@end
