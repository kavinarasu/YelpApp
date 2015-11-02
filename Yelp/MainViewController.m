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

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *yelpTableView;
@property (strong, nonatomic) NSArray *businesses;
@property (strong, nonatomic) NSMutableString *searchTerm;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchTerm = [[NSMutableString alloc] initWithString:@"Restaurants"];
    self.yelpTableView.dataSource = self;
    self.yelpTableView.delegate = self;
    [self.yelpTableView registerNib:[UINib nibWithNibName:@"YelpContentCell" bundle:nil] forCellReuseIdentifier:@"yelpContentCell"];
    self.yelpTableView.rowHeight = UITableViewAutomaticDimension;
    self.yelpTableView.estimatedRowHeight = 120;
    self.title = @"Listing";
    UISearchBar *search = [[UISearchBar alloc] init];
    search.returnKeyType = UIReturnKeySearch;
    search.delegate = self;
    self.navigationItem.titleView = search;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterTapped)];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.yelpTableView addGestureRecognizer:gestureRecognizer];
    [self yelpSearch:self.searchTerm withCategory:@"" withDeals:[@NO boolValue] withSortMode:YelpSortModeBestMatched withDistance:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.yelpTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self hideKeyboard];
    NSString *text = [searchBar text];
    [self searchWithTerm:text];
}

- (void) searchWithTerm:(NSString*) text {
    if(text && [text length] != 0) {
        NSLog(@"Search term typed %@", text);
        self.searchTerm = text;
    } else {
        self.searchTerm = @"Restaurants";
    }
    [self yelpSearch:self.searchTerm withCategory:@"" withDeals:[@NO boolValue] withSortMode:YelpSortModeBestMatched withDistance:nil];
}

- (void) hideKeyboard {
    UISearchBar *searchBar = (UISearchBar*)[self.navigationItem titleView];
    [searchBar resignFirstResponder];
    NSString *text = [searchBar text];
    if(![text isEqualToString:self.searchTerm]) {
        [self searchWithTerm:text];
    }
}

- (void) yelpSearch:(NSString *) searchTerm withCategory:(NSString *) categoryFilter withDeals:(BOOL) isOn withSortMode:(YelpSortMode) sortMode withDistance:(NSNumber *) distance {
    NSLog(@"%@", isOn ? @"YES": @"NO");
    [YelpBusiness searchWithTerm:searchTerm
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
    NSNumber *dealOption = [filters objectForKey:@"deals_on"];
    NSNumber *sortMode = [filters objectForKey:@"sort_mode"];
    NSNumber *distance = [filters objectForKey:@"distance"];
    YelpSortMode yelpSortMode;
    if(sortMode) {
        yelpSortMode = (YelpSortMode) [sortMode intValue];
    } else {
        yelpSortMode = YelpSortModeBestMatched;
    }
    [self yelpSearch:self.searchTerm withCategory:[filters objectForKey:@"category_filter"] withDeals:[dealOption boolValue] withSortMode:yelpSortMode withDistance:distance];
}
- (void) onFilterTapped {
    FiltersViewController *viewController = [[FiltersViewController alloc] init];
    viewController.delegate = self;
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navigation animated:YES completion:nil];
}

@end
