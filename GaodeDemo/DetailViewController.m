//
//  DetailViewController.m
//  GaodeDemo
//
//  Created by HGDQ on 15/10/8.
//  Copyright (c) 2015年 HGDQ. All rights reserved.
//

#import "DetailViewController.h"
#import <AMapSearchKit/AMapSearchAPI.h>

@interface DetailViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setMainView];
    // Do any additional setup after loading the view from its nib.
}

- (void)setMainView{
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return self.poisArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *identify = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify];
	}
	AMapPOI *poi = (AMapPOI *)self.poisArray[indexPath.row];
	cell.textLabel.text = poi.name;
	cell.detailTextLabel.text = poi.address;
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"test" object:[NSString stringWithFormat:@"%d",indexPath.row]];
	[self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
