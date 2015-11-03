//
//  FiltersViewController.m
//  Yelp
//
//  Created by Kavin Arasu on 11/1/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "SwitchCell.h"
#import "YelpPickerCell.h"
#import "CollapsibleCell.h"

@interface FiltersViewController () <UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate, YelpPickerCellDelegate>

@property (nonatomic, readonly) NSDictionary *filters;
@property (weak, nonatomic) IBOutlet UITableView *filtersTableView;
@property (nonatomic, strong) NSMutableDictionary *categories;
@property (nonatomic, strong) NSMutableDictionary *deals;
@property (nonatomic, strong) NSMutableDictionary *sortModes;
@property (nonatomic, strong) NSMutableDictionary *sortModeOptions;
@property (nonatomic, strong) NSMutableDictionary *distanceFields;
@property (nonatomic, strong) NSMutableDictionary *distanceValues;
@property (nonatomic, strong) NSMutableSet *selectedCategories;
@property (nonatomic, strong) NSMutableArray *filterOptions;
@property (nonatomic, assign) BOOL dealsOn;
@property (nonatomic, assign) NSInteger selectedSortMode;
@property (nonatomic) NSNumber *selectedDistance;
@property (nonatomic, strong) NSMutableIndexSet *expanded;


- (void) initCategories;

@end

@implementation FiltersViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.selectedCategories = [[NSMutableSet alloc] init];
//        [self initCategories];
//        self.filters[0];
        self.filterOptions = [[NSMutableArray alloc] init];
        self.deals = [[NSMutableDictionary alloc] init];
        self.categories = [[NSMutableDictionary alloc] init];
        self.sortModes = [[NSMutableDictionary alloc] init];
        self.distanceFields = [[NSMutableDictionary alloc] init];
        self.sortModeOptions = [[NSMutableDictionary alloc] init];
        self.expanded = [[NSMutableIndexSet alloc] init];
        self.distanceValues = [[NSMutableDictionary alloc] init];
        [self initFilterOptions];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Filters";
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelTapped)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(onApplyTapped)];
    self.filtersTableView.dataSource = self;
    self.filtersTableView.delegate = self;
    [self.filtersTableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"switchCell"];
    [self.filtersTableView registerNib:[UINib nibWithNibName:@"YelpPickerCell" bundle:nil] forCellReuseIdentifier:@"pickerCell"];
    [self.filtersTableView registerNib:[UINib nibWithNibName:@"CollapsibleCell" bundle:nil] forCellReuseIdentifier:@"collapsibleCell"];

}

- (NSDictionary *) filters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    if(self.selectedCategories.count > 0) {
        NSMutableArray *names = [NSMutableArray array];
        for (NSDictionary *category in self.selectedCategories) {
            [names addObject:category[@"code"]];
        }
        NSString *categoryFilter = [names componentsJoinedByString:@","];
        [filters setObject:categoryFilter forKey:@"category_filter"];
    } else {
        [filters setObject:@"" forKey:@"category_filter"];
    }
    if([self dealsOn]) {
        [filters setObject:@YES forKey:@"deals_on"];
    } else {
        [filters setObject:@NO forKey:@"deals_on"];
    }
    if(self.selectedSortMode) {
        [filters setObject:[NSNumber numberWithInt:self.selectedSortMode] forKey:@"sort_mode"];
    }
    if(self.selectedDistance) {
        [filters setObject:self.selectedDistance forKey:@"distance"];
    }
    NSLog(@"%@", filters);
    return filters;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.filtersTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self tableView:tableView canCollapseSection:indexPath.section])
    {
            BOOL currentlyExpanded = [self.expanded containsIndex:indexPath.section];
            NSInteger rows;
            NSMutableArray *tmpArray = [NSMutableArray array];
            if (currentlyExpanded)
            {
                rows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
                [self.expanded removeIndex:indexPath.section];
                
            }
            else
            {
                [self.expanded addIndex:indexPath.section];
                rows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
            }
        
//            [tmpArray addObject:indexPath];
            for (int i=0; i<rows; i++)
            {
                if(i!=indexPath.row) {
                
                NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:i
                                                               inSection:indexPath.section];
                    [tmpArray addObject:tmpIndexPath];
                }
            }
            
            
            if (currentlyExpanded)
            {
                [tableView deleteRowsAtIndexPaths:tmpArray
                                 withRowAnimation:UITableViewRowAnimationTop];
                NSMutableArray *values = [[self.filterOptions objectAtIndex:indexPath.section][@"values"] mutableCopy];
            
                NSLog(@"%@", values);
                [values exchangeObjectAtIndex:0 withObjectAtIndex:indexPath.row];
                NSLog(@"%@", values);
                [[self.filterOptions objectAtIndex:indexPath.section] setObject:values forKey:@"values"];
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
                CollapsibleCell *cell = [tableView cellForRowAtIndexPath:newIndexPath];
                [cell setHidden:NO];
//                NSNumber *number = [self.filterOptions objectAtIndex:indexPath.section][@"values"][indexPath.row][@"code"];
                NSNumber *number = values[indexPath.row][@"code"];
                NSString *title = [self.filterOptions objectAtIndex:indexPath.section][@"title"];
                if([title isEqualToString:@"Sort Mode"]) {
                    self.selectedSortMode = [number integerValue];
                } else {
                    self.selectedDistance = number;
                }
//                NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] initWithIndex:indexPath.section];
//                [self.filtersTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
            }
            else
            {
                [tableView insertRowsAtIndexPaths:tmpArray
                                 withRowAnimation:UITableViewRowAnimationTop];
            }
    }
}

- (void) switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value {
    NSIndexPath *index = [self.filtersTableView indexPathForCell:cell];
    NSDictionary *dict = self.filterOptions[index.section];
    NSString *title = dict[@"title"];
    NSArray *values = dict[@"values"];
    if([title isEqualToString:@"Deals"]) {
        [self setDealsOn:value];
    }
    if(value && [title isEqualToString:@"Categories"]) {
//        [self.selectedCategories addObject:self.categories[index.section][index.row]];
        [self.selectedCategories addObject:values[index.row]];
    } else {
        [self.selectedCategories removeObject:values[index.row]];
//        [self.selectedCategories removeObject:self.categories[index.section][index.row]];
    }
}

- (void) yelpPickerCell:(YelpPickerCell *)cell didUpdateValue:(NSInteger)option {
    NSIndexPath *index = [self.filtersTableView indexPathForCell:cell];
    NSDictionary *dict = self.filterOptions[index.section];
    NSString *title = dict[@"title"];
    if([title isEqualToString:@"Distance"]) {
        NSArray *values = [self.distanceFields[@"values"][0] componentsSeparatedByString:@","];
        NSString *optionValue = values[option];
        NSString *distance = [[optionValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@" "][0];
        NSLog(@"%.2f", [distance doubleValue]);
        self.selectedDistance = [NSNumber numberWithDouble:[distance doubleValue]];
    } else {
        self.selectedSortMode = option;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"%ld", self.filterOptions.count);
    return self.filterOptions.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *filter = self.filterOptions[section][@"values"];
    if([self tableView:tableView canCollapseSection:section]) {
        if([self.expanded containsIndex:section]) {
            return filter.count;
        } else {
            return 1;
        }
    }
    NSLog(@"Count is %ld", filter.count);
    return filter.count;
}

- (BOOL)tableView:(UITableView *)tableView canCollapseSection:(NSInteger)section
{
    NSString *title = self.filterOptions[section][@"title"];
    NSLog(@"title is %@", title);
    if ([title isEqualToString:@"Sort Mode"] || [title isEqualToString:@"Distance Values"]) {
        NSLog(@"Collpasing because of %@", title);
        return YES;
    }
    else {
        return NO;
    }
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.filterOptions[section][@"title"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.filterOptions[indexPath.section][@"title"];
    if([self tableView:tableView canCollapseSection:indexPath.section]) {
        NSLog(@"This is a collapsible cell");
        CollapsibleCell *collapsibleCell = [tableView dequeueReusableCellWithIdentifier:@"collapsibleCell"];
        collapsibleCell.filterLabel.text = self.filterOptions[indexPath.section][@"values"][indexPath.row][@"name"];
        if(indexPath.row) {
            [collapsibleCell setHidden:YES];
        }
        return collapsibleCell;
//        if(!indexPath.row) {
//            SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"switchCell"];
//            cell.filterLabel.text = self.filterOptions[indexPath.section][@"values"][indexPath.row][@"name"];
//            cell.delegate = self;
//            return cell;
//        }
    }
    if([title isEqualToString:@"Sort By"] || [title isEqualToString:@"Distance"]) {
        YelpPickerCell *pickerCell = [tableView dequeueReusableCellWithIdentifier:@"pickerCell"];
        NSString *values = self.filterOptions[indexPath.section][@"values"][0];
        NSArray *options = [values componentsSeparatedByString:@","];
        NSLog(@"%@", options);
        [pickerCell setOptions:options];
        [pickerCell setSelectedIndex:self.selectedSortMode];
        pickerCell.delegate = self;
        return pickerCell;
    }
    SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"switchCell"];
    cell.filterLabel.text = self.filterOptions[indexPath.section][@"values"][indexPath.row][@"name"];
    cell.on = [self.selectedCategories containsObject:self.filterOptions[indexPath.section][@"values"][indexPath.row]];
    cell.delegate = self;
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) onCancelTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) onApplyTapped {
    [self.delegate filtersViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];    
}

- (void) initSortModes {
    NSArray *values = @[@"Best Matched, Distance, Highest Rated"];
    [self.sortModes setObject:@"Sort By" forKey:@"title"];
    [self.sortModes setObject:values forKey:@"values"];
}

- (void) initSortModeOptions {
    NSArray *values = @[@{@"name": @"Best Matched", @"code":@1}, @{@"name": @"Distance", @"code":@2}, @{@"name": @"Highest Rated", @"code":@3}];
    [self.sortModeOptions setObject:@"Sort Mode" forKey:@"title"];
    [self.sortModeOptions setObject:values forKey:@"values"];
}


- (void) initDistanceFields {
    NSArray *values = @[@"0.3 miles, 1 mile, 5 miles, 20 miles"];
    [self.distanceFields setObject:@"Distance" forKey:@"title"];
    [self.distanceFields setObject:values forKey:@"values"];
}

- (void) initDistanceValues {
    NSArray *values = @[@{@"name": @"0.3 miles", @"code":@0.3}, @{@"name": @"1 mile", @"code":@1}, @{@"name": @"5 miles", @"code":@5}, @{@"name": @"20 miles", @"code":@20}];
    [self.distanceValues setObject:@"Distance Values" forKey:@"title"];
    [self.distanceValues setObject:values forKey:@"values"];
}

- (void) initFilterOptions {
    [self initDealsArray];
    [self initCategories];
//    [self initSortModes];
    [self initSortModeOptions];
    [self initDistanceFields];
    [self initDistanceValues];
    [self.filterOptions addObject:self.deals];
//    [self.filterOptions addObject:self.sortModes];
    [self.filterOptions addObject:self.sortModeOptions];
    [self.filterOptions addObject:self.distanceFields];
    [self.filterOptions addObject:self.distanceValues];
    [self.filterOptions addObject:self.categories];

}

- (void) initDealsArray {
    NSArray *values = @[@{@"name": @"Offering Deals?"}];
    [self.deals setObject:@"Deals" forKey:@"title"];
    [self.deals setObject:values forKey:@"values"];
}

- (void) initCategories {
    NSArray *values = @[@{@"name": @"Afghan", @"code": @"afghani"},
                            @{@"name": @"African", @"code": @"african"},
                            @{@"name": @"American, New", @"code": @"newamerican"},
                            @{@"name": @"American, Traditional", @"code": @"tradamerican"},
                            @{@"name": @"Arabian", @"code": @"arabian"},
                            @{@"name": @"Argentine", @"code": @"argentine"},
                            @{@"name": @"Armenian", @"code": @"armenian"},
                            @{@"name": @"Asian Fusion", @"code": @"asianfusion"},
                            @{@"name": @"Asturian", @"code": @"asturian"},
                            @{@"name": @"Australian", @"code": @"australian"},
                            @{@"name": @"Austrian", @"code": @"austrian"},
                            @{@"name": @"Baguettes", @"code": @"baguettes"},
                            @{@"name": @"Bangladeshi", @"code": @"bangladeshi"},
                            @{@"name": @"Barbeque", @"code": @"bbq"},
                            @{@"name": @"Basque", @"code": @"basque"},
                            @{@"name": @"Bavarian", @"code": @"bavarian"},
                            @{@"name": @"Beer Garden", @"code": @"beergarden"},
                            @{@"name": @"Beer Hall", @"code": @"beerhall"},
                            @{@"name": @"Beisl", @"code": @"beisl"},
                            @{@"name": @"Belgian", @"code": @"belgian"},
                            @{@"name": @"Bistros", @"code": @"bistros"},
                            @{@"name": @"Black Sea", @"code": @"blacksea"},
                            @{@"name": @"Brasseries", @"code": @"brasseries"},
                            @{@"name": @"Brazilian", @"code": @"brazilian"},
                            @{@"name": @"Breakfast & Brunch", @"code": @"breakfast_brunch"},
                            @{@"name": @"British", @"code": @"british"},
                            @{@"name": @"Buffets", @"code": @"buffets"},
                            @{@"name": @"Bulgarian", @"code": @"bulgarian"},
                            @{@"name": @"Burgers", @"code": @"burgers"},
                            @{@"name": @"Burmese", @"code": @"burmese"},
                            @{@"name": @"Cafes", @"code": @"cafes"},
                            @{@"name": @"Cafeteria", @"code": @"cafeteria"},
                            @{@"name": @"Cajun/Creole", @"code": @"cajun"},
                            @{@"name": @"Cambodian", @"code": @"cambodian"},
                            @{@"name": @"Canadian", @"code": @"New)"},
                            @{@"name": @"Canteen", @"code": @"canteen"},
                            @{@"name": @"Caribbean", @"code": @"caribbean"},
                            @{@"name": @"Catalan", @"code": @"catalan"},
                            @{@"name": @"Chech", @"code": @"chech"},
                            @{@"name": @"Cheesesteaks", @"code": @"cheesesteaks"},
                            @{@"name": @"Chicken Shop", @"code": @"chickenshop"},
                            @{@"name": @"Chicken Wings", @"code": @"chicken_wings"},
                            @{@"name": @"Chilean", @"code": @"chilean"},
                            @{@"name": @"Chinese", @"code": @"chinese"},
                            @{@"name": @"Comfort Food", @"code": @"comfortfood"},
                            @{@"name": @"Corsican", @"code": @"corsican"},
                            @{@"name": @"Creperies", @"code": @"creperies"},
                            @{@"name": @"Cuban", @"code": @"cuban"},
                            @{@"name": @"Curry Sausage", @"code": @"currysausage"},
                            @{@"name": @"Cypriot", @"code": @"cypriot"},
                            @{@"name": @"Czech", @"code": @"czech"},
                            @{@"name": @"Czech/Slovakian", @"code": @"czechslovakian"},
                            @{@"name": @"Danish", @"code": @"danish"},
                            @{@"name": @"Delis", @"code": @"delis"},
                            @{@"name": @"Diners", @"code": @"diners"},
                            @{@"name": @"Dumplings", @"code": @"dumplings"},
                            @{@"name": @"Eastern European", @"code": @"eastern_european"},
                            @{@"name": @"Ethiopian", @"code": @"ethiopian"},
                            @{@"name": @"Fast Food", @"code": @"hotdogs"},
                            @{@"name": @"Filipino", @"code": @"filipino"},
                            @{@"name": @"Fish & Chips", @"code": @"fishnchips"},
                            @{@"name": @"Fondue", @"code": @"fondue"},
                            @{@"name": @"Food Court", @"code": @"food_court"},
                            @{@"name": @"Food Stands", @"code": @"foodstands"},
                            @{@"name": @"French", @"code": @"french"},
                            @{@"name": @"French Southwest", @"code": @"sud_ouest"},
                            @{@"name": @"Galician", @"code": @"galician"},
                            @{@"name": @"Gastropubs", @"code": @"gastropubs"},
                            @{@"name": @"Georgian", @"code": @"georgian"},
                            @{@"name": @"German", @"code": @"german"},
                            @{@"name": @"Giblets", @"code": @"giblets"},
                            @{@"name": @"Gluten-Free", @"code": @"gluten_free"},
                            @{@"name": @"Greek", @"code": @"greek"},
                            @{@"name": @"Halal", @"code": @"halal"},
                            @{@"name": @"Hawaiian", @"code": @"hawaiian"},
                            @{@"name": @"Heuriger", @"code": @"heuriger"},
                            @{@"name": @"Himalayan/Nepalese", @"code": @"himalayan"},
                            @{@"name": @"Hong Kong Style Cafe", @"code": @"hkcafe"},
                            @{@"name": @"Hot Dogs", @"code": @"hotdog"},
                            @{@"name": @"Hot Pot", @"code": @"hotpot"},
                            @{@"name": @"Hungarian", @"code": @"hungarian"},
                            @{@"name": @"Iberian", @"code": @"iberian"},
                            @{@"name": @"Indian", @"code": @"indpak"},
                            @{@"name": @"Indonesian", @"code": @"indonesian"},
                            @{@"name": @"International", @"code": @"international"},
                            @{@"name": @"Irish", @"code": @"irish"},
                            @{@"name": @"Island Pub", @"code": @"island_pub"},
                            @{@"name": @"Israeli", @"code": @"israeli"},
                            @{@"name": @"Italian", @"code": @"italian"},
                            @{@"name": @"Japanese", @"code": @"japanese"},
                            @{@"name": @"Jewish", @"code": @"jewish"},
                            @{@"name": @"Kebab", @"code": @"kebab"},
                            @{@"name": @"Korean", @"code": @"korean"},
                            @{@"name": @"Kosher", @"code": @"kosher"},
                            @{@"name": @"Kurdish", @"code": @"kurdish"},
                            @{@"name": @"Laos", @"code": @"laos"},
                            @{@"name": @"Laotian", @"code": @"laotian"},
                            @{@"name": @"Latin American", @"code": @"latin"},
                            @{@"name": @"Live/Raw Food", @"code": @"raw_food"},
                            @{@"name": @"Lyonnais", @"code": @"lyonnais"},
                            @{@"name": @"Malaysian", @"code": @"malaysian"},
                            @{@"name": @"Meatballs", @"code": @"meatballs"},
                            @{@"name": @"Mediterranean", @"code": @"mediterranean"},
                            @{@"name": @"Mexican", @"code": @"mexican"},
                            @{@"name": @"Middle Eastern", @"code": @"mideastern"},
                            @{@"name": @"Milk Bars", @"code": @"milkbars"},
                            @{@"name": @"Modern Australian", @"code": @"modern_australian"},
                            @{@"name": @"Modern European", @"code": @"modern_european"},
                            @{@"name": @"Mongolian", @"code": @"mongolian"},
                            @{@"name": @"Moroccan", @"code": @"moroccan"},
                            @{@"name": @"New Zealand", @"code": @"newzealand"},
                            @{@"name": @"Night Food", @"code": @"nightfood"},
                            @{@"name": @"Norcinerie", @"code": @"norcinerie"},
                            @{@"name": @"Open Sandwiches", @"code": @"opensandwiches"},
                            @{@"name": @"Oriental", @"code": @"oriental"},
                            @{@"name": @"Pakistani", @"code": @"pakistani"},
                            @{@"name": @"Parent Cafes", @"code": @"eltern_cafes"},
                            @{@"name": @"Parma", @"code": @"parma"},
                            @{@"name": @"Persian/Iranian", @"code": @"persian"},
                            @{@"name": @"Peruvian", @"code": @"peruvian"},
                            @{@"name": @"Pita", @"code": @"pita"},
                            @{@"name": @"Pizza", @"code": @"pizza"},
                            @{@"name": @"Polish", @"code": @"polish"},
                            @{@"name": @"Portuguese", @"code": @"portuguese"},
                            @{@"name": @"Potatoes", @"code": @"potatoes"},
                            @{@"name": @"Poutineries", @"code": @"poutineries"},
                            @{@"name": @"Pub Food", @"code": @"pubfood"},
                            @{@"name": @"Rice", @"code": @"riceshop"},
                            @{@"name": @"Romanian", @"code": @"romanian"},
                            @{@"name": @"Rotisserie Chicken", @"code": @"rotisserie_chicken"},
                            @{@"name": @"Rumanian", @"code": @"rumanian"},
                            @{@"name": @"Russian", @"code": @"russian"},
                            @{@"name": @"Salad", @"code": @"salad"},
                            @{@"name": @"Sandwiches", @"code": @"sandwiches"},
                            @{@"name": @"Scandinavian", @"code": @"scandinavian"},
                            @{@"name": @"Scottish", @"code": @"scottish"},
                            @{@"name": @"Seafood", @"code": @"seafood"},
                            @{@"name": @"Serbo Croatian", @"code": @"serbocroatian"},
                            @{@"name": @"Signature Cuisine", @"code": @"signature_cuisine"},
                            @{@"name": @"Singaporean", @"code": @"singaporean"},
                            @{@"name": @"Slovakian", @"code": @"slovakian"},
                            @{@"name": @"Soul Food", @"code": @"soulfood"},
                            @{@"name": @"Soup", @"code": @"soup"},
                            @{@"name": @"Southern", @"code": @"southern"},
                            @{@"name": @"Spanish", @"code": @"spanish"},
                            @{@"name": @"Steakhouses", @"code": @"steak"},
                            @{@"name": @"Sushi Bars", @"code": @"sushi"},
                            @{@"name": @"Swabian", @"code": @"swabian"},
                            @{@"name": @"Swedish", @"code": @"swedish"},
                            @{@"name": @"Swiss Food", @"code": @"swissfood"},
                            @{@"name": @"Tabernas", @"code": @"tabernas"},
                            @{@"name": @"Taiwanese", @"code": @"taiwanese"},
                            @{@"name": @"Tapas Bars", @"code": @"tapas"},
                            @{@"name": @"Tapas/Small Plates", @"code": @"tapasmallplates"},
                            @{@"name": @"Tex-Mex", @"code": @"tex-mex"},
                            @{@"name": @"Thai", @"code": @"thai"},
                            @{@"name": @"Traditional Norwegian", @"code": @"norwegian"},
                            @{@"name": @"Traditional Swedish", @"code": @"traditional_swedish"},
                            @{@"name": @"Trattorie", @"code": @"trattorie"},
                            @{@"name": @"Turkish", @"code": @"turkish"},
                            @{@"name": @"Ukrainian", @"code": @"ukrainian"},
                            @{@"name": @"Uzbek", @"code": @"uzbek"},
                            @{@"name": @"Vegan", @"code": @"vegan"},
                            @{@"name": @"Vegetarian", @"code": @"vegetarian"},
                            @{@"name": @"Venison", @"code": @"venison"},
                            @{@"name": @"Vietnamese", @"code": @"vietnamese"},
                            @{@"name": @"Wok", @"code": @"wok"},
                            @{@"name": @"Wraps", @"code": @"wraps"},
                            @{@"name": @"Yugoslav", @"code": @"yugoslav"}];
//    self.deals = @{@"title":@"Categories", @"values":values};
    [self.categories setObject:@"Categories" forKey:@"title"];
    [self.categories setObject:values forKey:@"values"];
}

@end
