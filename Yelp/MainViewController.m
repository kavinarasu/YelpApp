//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpBusiness.h"
#import "YelpContentCell.h"
#import "FiltersViewController.h"

@interface MainViewController () <UITableViewDataSource, FiltersViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *yelpTableView;
@property (strong, nonatomic) NSArray *businesses;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.yelpTableView.dataSource = self;
    [self.yelpTableView registerNib:[UINib nibWithNibName:@"YelpContentCell" bundle:nil] forCellReuseIdentifier:@"yelpContentCell"];
    self.yelpTableView.rowHeight = UITableViewAutomaticDimension;
    self.yelpTableView.estimatedRowHeight = 120;
    self.title = @"Listing";
    UISearchBar *search = [[UISearchBar alloc] init];
    self.navigationItem.titleView = search;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterTapped)];
    [self yelpSearch:@"" withDeals:[@NO boolValue] withSortMode:YelpSortModeBestMatched withDistance:nil];
}

- (void) yelpSearch:(NSString *) categoryFilter withDeals:(BOOL) isOn withSortMode:(YelpSortMode) sortMode withDistance:(NSNumber *) distance {
    NSLog(@"%@", isOn ? @"YES": @"NO");
    [YelpBusiness searchWithTerm:@"Restaurants"
                        sortMode:sortMode
                      categories:@[categoryFilter]
                           deals:isOn
                        distance:distance
                      completion:^(NSArray *businesses, NSError *error) {
                          self.businesses = businesses;
                          [self.yelpTableView reloadData];
                      }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businesses.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YelpContentCell *cell = [self.yelpTableView dequeueReusableCellWithIdentifier:@"yelpContentCell"];
    cell.yelpBusiness = self.businesses[indexPath.row];
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) filtersViewController:(FiltersViewController *)filtersViewController didChangeFilters:(NSDictionary *)filters {
    NSLog(@"Firing a networking event %@", filters);
    NSLog(@"Firing a networking event %@", [filters objectForKey:@"deals_on"]);
    NSNumber *dealOption = [filters objectForKey:@"deals_on"];
    NSNumber *sortMode = [filters objectForKey:@"sort_mode"];
    NSNumber *distance = [filters objectForKey:@"distance"];
    NSLog(@"Firing a networking event %@", sortMode);
    YelpSortMode yelpSortMode;
    if(sortMode) {
        yelpSortMode = (YelpSortMode) [sortMode intValue];
    } else {
        yelpSortMode = YelpSortModeBestMatched;
    }
    [self yelpSearch:[filters objectForKey:@"category_filter"] withDeals:[dealOption boolValue] withSortMode:yelpSortMode withDistance:distance];
}
- (void) onFilterTapped {
    FiltersViewController *viewController = [[FiltersViewController alloc] init];
    viewController.delegate = self;
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navigation animated:YES completion:nil];
}

@end
