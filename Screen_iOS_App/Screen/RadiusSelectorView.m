//
//  RadiusSelectorView.m
//  Screen
//
//  Created by Mason Wolters on 12/16/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "RadiusSelectorView.h"
#import "Constants.h"

@implementation RadiusSelectorView

@synthesize tableView;
@synthesize options;
@synthesize changeHandler;
@synthesize pickLocationHandler;
@synthesize locationLabel;

- (void)update {
    locationLabel.text = [NSString stringWithFormat:@"Near: %@", ([[NSUserDefaults standardUserDefaults] objectForKey:@"searchLocationName"])?[[NSUserDefaults standardUserDefaults] objectForKey:@"searchLocationName"]:@"Current Location"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (![cell viewWithTag:101]) {
        cell.tintColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        UILabel *radiusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, tableView.frame.size.width - 20, tableView.rowHeight)];
        radiusLabel.textColor = [UIColor whiteColor];
        radiusLabel.tag = 101;
        [cell.contentView addSubview:radiusLabel];
    }
    
    [(UILabel *)[cell.contentView viewWithTag:101] setText:[NSString stringWithFormat:@"%.01f miles", [options[indexPath.row] floatValue]]];
    if ([options[indexPath.row] floatValue] == [[[NSUserDefaults standardUserDefaults] objectForKey:@"theaterRadius"] floatValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[NSUserDefaults standardUserDefaults] setObject:options[indexPath.row] forKey:@"theaterRadius"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [tableView reloadData];
    if (changeHandler) {
        changeHandler();
    }
}

- (void)tapLocationPicker {
    if (pickLocationHandler) {
        pickLocationHandler();
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        options = @[@5.0f, @10.0f, @15.0f, @20.0f, @30.0f, @50.0f];
        
        UIImageView *locationImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
        locationImage.image = [UIImage imageNamed:@"location"];
        [self addSubview:locationImage];
        
        locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, self.bounds.size.width - 70, 40)];
        locationLabel.text = [NSString stringWithFormat:@"Near: %@", ([[NSUserDefaults standardUserDefaults] objectForKey:@"searchLocationName"])?[[NSUserDefaults standardUserDefaults] objectForKey:@"searchLocationName"]:@"Current Location"];
        locationLabel.textColor = [UIColor whiteColor];
        [self addSubview:locationLabel];
        
        UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 25.5, 14.5, 11, 11)];
        arrow.image = [UIImage imageNamed:@"detailDisclosure"];
        [self addSubview:arrow];
        
        UIView *tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 40)];
        tapView.backgroundColor = [UIColor clearColor];
        [self addSubview:tapView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLocationPicker)];
        [tapView addGestureRecognizer:tap];
        
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, self.bounds.size.width, self.bounds.size.height - 40)];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.rowHeight = 40.0f;
        tableView.backgroundColor = UIColorFromRGB(grayColor);
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        [self addSubview:tableView];
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
