//
//  ViewController.m
//  GaodeDemo
//
//  Created by HGDQ on 15/10/8.
//  Copyright (c) 2015年 HGDQ. All rights reserved.
//

//  key  602b32b6d05860abbf7a26593c7ca643   a12bc9db3e3f5ba30482aa704ee0fc29


#import "ViewController.h"
//地图显示需要的头文件
#import <MAMapKit/MAMapKit.h>
//poi搜素需要的头文件
#import <AMapSearchKit/AMapSearchAPI.h>
#import "DetailViewController.h"

@interface ViewController ()<MAMapViewDelegate, AMapSearchDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)MAMapView *mapView;
@property (nonatomic,strong)AMapSearchAPI *search;
@property (nonatomic,strong)MAUserLocation *location;
@property (nonatomic,strong)AMapPlaceSearchRequest *request;
@property (nonatomic,strong)UISearchBar *searchBar;
@property (nonatomic,strong)UITableView *tableView;

@property (nonatomic,strong)NSMutableArray *annotationArr;
@property (nonatomic,strong)NSMutableArray *poisArray;

@property (nonatomic,assign)NSInteger index;


@end

@implementation ViewController
#pragma mark - 页面跳转时需要使用
/* 需要页面跳转时使用
- (void)viewWillAppear:(BOOL)animated{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPoiPoint:) name:@"test" object:nil];
}
- (void)setPoiPoint:(NSNotification *)notice{
	//先移除掉上次搜索的大头针
	[self.mapView removeAnnotations:self.annotationArr];
	//清空数组
	[self.annotationArr removeAllObjects];
	NSString *index = notice.object;
	AMapPOI *poi = self.poisArray[index.integerValue];
	MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
	CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
	annotation.coordinate = coordinate;
	annotation.title = poi.name;
	annotation.subtitle = poi.address;
	[self.annotationArr addObject:annotation];
	[self.mapView addAnnotation:annotation];
}
*/

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//增加一个KVO  index
	[self addObserver:self forKeyPath:@"index" options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
	
	self.annotationArr = [[NSMutableArray alloc] init];
	
	[self configApiKey];
	[self setMySearchConterl];
	[self setMainView];
	[self setTableView];
	//获取bundleIdentifier
//	NSLog(@"bundleIdentifier = %@",[[NSBundle mainBundle] bundleIdentifier]);
	
	// Do any additional setup after loading the view, typically from a nib.
}
#pragma mark - 地图显示和搜索部分
/**
 *  配置APIKey
 */
- (void)configApiKey{
	[MAMapServices sharedServices].apiKey = @"a12bc9db3e3f5ba30482aa704ee0fc29";
}
/**
 *  设置地图显示   有这个方法就可以显示用户的位置
 */
- (void)setMainView{
	self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 200)];
	self.mapView.delegate = self;
	//设置地图语言  默认是中文
//	self.mapView.language = MAMapLanguageEn;
	//地图类型  默认是2D栅格地图
//	self.mapView.mapType = MAMapTypeSatellite;
	//关闭指南针显示
	self.mapView.showsCompass = NO;
	//关闭比例尺显示
	self.mapView.showsScale = NO;
	//显示用户位置
	self.mapView.showsUserLocation = YES;
	//设置跟踪模式
	self.mapView.userTrackingMode = MAUserTrackingModeFollow;
	[self.view addSubview:self.mapView];
}
/**
 *  设置POI搜素请求
 *
 *  @param keyword 搜索需要的关键字
 */
- (void)setPoiSearchMapWithKeyword:(NSString *)keyword{
	//初始化检索对象
	self.search = [[AMapSearchAPI alloc] initWithSearchKey:[MAMapServices sharedServices].apiKey Delegate:self];
	//构建AMapPlaceSearchRequest对象
	self.request = [[AMapPlaceSearchRequest alloc] init];
	//搜索类型  关键字搜索
	self.request.searchType = AMapSearchType_PlaceKeyword;
	//设置搜索关键字
	self.request.keywords = keyword;
	//搜索地点 广州
	self.request.city = @[@"guangzhou"];
	//开扩展
	self.request.requireExtension = YES;
	//发起POI搜索
	[self.search AMapPlaceSearch:self.request];
}
/**
 *  POI搜索请求后调用的方法
 *
 *  @param request  搜索请求
 *  @param response 请求结果
 */
- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response{
	if (response.count == 0) {
		return;
	}
/*  仅仅显示搜索结果的大头针
 	//先移除掉上次搜索的大头针  不然上一次的大头针会一直存在
	[self.mapView removeAnnotations:self.annotationArr];
 	//清空数组
	[self.annotationArr removeAllObjects];
 */
//	NSString *responseCount = [NSString stringWithFormat:@"%d",response.count];;
//	NSLog(@"responseCount = %@",responseCount);
	self.poisArray = [[NSMutableArray alloc] init];
	for (AMapPOI *poi in response.pois) {
		[self.poisArray addObject:poi];
		/* 仅仅显示搜索结果的大头针
		 MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
		 CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
		 annotation.coordinate = coordinate;
		 annotation.title = poi.name;
		 annotation.subtitle = poi.address;
		 [self.annotationArr addObject:annotation];
		 [self.mapView addAnnotation:annotation];
		 */
	}
	[self.tableView reloadData];
	/*需要页面跳转时使用
	 DetailViewController *dvc = [[DetailViewController alloc] init];
	 dvc.poisArray = self.poisArray;
	 [self presentViewController:dvc animated:YES completion:nil];
	 */
}
/**
 *  设置大头针点击后的气泡
 *
 *  @param mapView    mapView
 *  @param annotation annotation
 *
 *  @return 气泡
 */
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
	//	if ([annotation isKindOfClass:[MAAnnotationView class]]) {
	static NSString *identify = @"annotation";
	//在原有的大头针中添加自定义的修饰
	MAPinAnnotationView *pointAnnotation = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identify];
	if (pointAnnotation == nil) {
		//在原有的大头针中创建一个新的自定义的大头针
		pointAnnotation = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identify];
	}
	//设置是否能选中的标题
	pointAnnotation.canShowCallout = YES;
	//是否允许拖拽
	pointAnnotation.draggable = YES;
	//是否允许退拽动画
	pointAnnotation.animatesDrop = YES;
	return pointAnnotation;
}
/**
 *  地图定位后就会调用这个方法  酒店
 *
 *  @param mapView          当前的mapView
 *  @param userLocation     userLocation
 *  @param updatingLocation 位置更新标志
 */
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
//	NSLog(@"地图");
	if (updatingLocation) {
//		NSLog(@"latitude = %f longitude = %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
		//确定地图经纬度
		CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
		//设置的当前位置 为地图中心
		self.mapView.centerCoordinate = coordinate;
		self.location = userLocation;
	}
}
#pragma mark - searchBar部分
/**
 *  设置searchBar
 */
- (void)setMySearchConterl{
	self.searchBar = [[UISearchBar alloc] init];
	self.searchBar.frame = CGRectMake(0, 20, self.view.frame.size.width, 44);
	self.searchBar.delegate = self;
	self.searchBar.placeholder = @"请输入关键字";
	[self.view addSubview:self.searchBar];
	
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
	return YES;
}
/**
 *  设置左边的“取消”按钮
 *
 *  @param searchBar searchBar
 */
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
	self.searchBar.showsCancelButton = YES;
	for (id cc in [searchBar.subviews[0] subviews]) {
		if ([cc isKindOfClass:[UIButton class]]) {
			UIButton * cancelButton = (UIButton *)cc;
			[cancelButton setTitle:@"取消" forState:UIControlStateNormal];
		}
	}
}// called when text starts editing
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
	return YES;
}// return NO to not resign first responder

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text NS_AVAILABLE_IOS(3_0){
 return YES;
}// called before text changes
/**
 *  键盘搜索按钮按下就会调用这个方法
 *
 *  @param searchBar searchBar本身
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
//	NSLog(@"text = %@",searchBar.text);
	//发起POI搜索请求
	[self setPoiSearchMapWithKeyword:searchBar.text];
	//收起键盘
	[searchBar resignFirstResponder];
	searchBar.text = @"";
}// called when keyboard search button pressed
/**
 *  “取消”按钮按下会调用这个方法
 *  收起键盘
 *  @param searchBar searchBar本身
 */
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
	[searchBar resignFirstResponder];
	self.searchBar.showsCancelButton = NO;
}// called when cancel button pressed

#pragma mark - tableView部分
/**
 *  设置tableView
 */
- (void)setTableView{
	self.tableView = [[UITableView alloc] init];
	self.tableView.frame = CGRectMake(0, 264, self.view.frame.size.width, self.view.frame.size.height - 264);
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	[self.view addSubview:self.tableView];
}
/**
 *  设置tableView的row个数
 *
 *  @param tableView tableView本身
 *  @param section   当前的section
 *
 *  @return 当前section里面的row数
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return self.poisArray.count;
}
/**
 *  设置cell的显示
 *
 *  @param tableView tableView本身
 *  @param indexPath cell的位置
 *
 *  @return cell
 */
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
/**
 *  tableView点击时间
 *
 *  @param tableView tableView本身
 *  @param indexPath 被点击的cell的位置
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	self.index = indexPath.row;
}
/**
 *  实现KVO键值监听的方法
 *  值改变后 增加大头针
 *  @param keyPath keyPath
 *  @param object  self
 *  @param change  值字典
 *  @param context
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	//先移除掉上次搜索的大头针
	[self.mapView removeAnnotations:self.annotationArr];
	//清空数组
	[self.annotationArr removeAllObjects];
	NSString *index = change[@"new"];
	AMapPOI *poi = self.poisArray[index.integerValue];
	MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
	CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
	//地图中心点 设置为选中的点
	self.mapView.centerCoordinate = coordinate;
	annotation.coordinate = coordinate;
	//一下两句 就是气泡的显示内容
	annotation.title = poi.name;
	annotation.subtitle = poi.address;
	[self.annotationArr addObject:annotation];
	[self.mapView addAnnotation:annotation];
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end



























































































