//
//  CollapsibleCell.h
//  Yelp
//
//  Created by Kavin Arasu on 11/2/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CollapsibleCell;

@protocol CollapsibleCellDelegate <NSObject>

- (void) collapsibleCell:(CollapsibleCell *) cell didUpdateValue:(NSInteger) option;

@end


@interface CollapsibleCell : UITableViewCell

@property (nonatomic, weak) id<CollapsibleCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *filterLabel;
@property (nonatomic, assign) BOOL hidden;


@end
