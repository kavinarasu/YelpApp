//
//  YelpPickerCell.h
//  Yelp
//
//  Created by Kavin Arasu on 11/1/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YelpPickerCell;

@protocol YelpPickerCellDelegate <NSObject>

- (void) yelpPickerCell:(YelpPickerCell *) cell didUpdateValue:(NSInteger) option;

@end

@interface YelpPickerCell : UITableViewCell
@property (nonatomic, weak) id<YelpPickerCellDelegate> delegate;
@property (nonatomic) NSArray *options;
@property (nonatomic) NSInteger selectedIndex;

- (void) setOptions:(NSArray *)options;

- (void) setSelectedIndex:(NSInteger)selectedIndex;

@end
