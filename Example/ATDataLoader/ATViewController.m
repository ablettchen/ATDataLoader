//
//  ATViewController.m
//  ATDataLoader
//
//  Created by ablett on 2019/4/22.
//  Copyright (c) 2019 ablett. All rights reserved.
//

#import "ATViewController.h"
#import <ATDataLoader/ATDataLoader.h>
#import "ATExampleViewController.h"
#import <Masonry/Masonry.h>


@interface ATExampleListModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) ATDataLoadConf *conf;
@end
@implementation ATExampleListModel @end


@interface ATViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray <ATExampleListModel *> *datas;
@end

@implementation ATViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self _prepareView];
    [self _prepareData];
}


#pragma mark - private

- (void)_prepareView {
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.bottom.right.equalTo(self.view);
    }];
}

- (void)_prepareData {
    
    NSMutableArray <ATExampleListModel *> *datas = [NSMutableArray array];
    
    {
        ATDataLoadConf *conf = ATDataLoadConf.new;
        conf.mode = ATDataLoadModeAuto;
        conf.component = ATDataLoadComponentRefresh | ATDataLoadComponentLoadMore;
        conf.animated = ATDataLoadAnimatedRefresh;
        
        ATExampleListModel *obj = ATExampleListModel.new;
        obj.title = @"自动：下拉刷新+上拉加载更多";
        obj.conf = conf;
        [datas addObject:obj];
    }
    
    {
        ATDataLoadConf *conf = ATDataLoadConf.new;
        conf.mode = ATDataLoadModeAuto;
        conf.component = ATDataLoadComponentRefresh;
        conf.animated = ATDataLoadAnimatedRefresh;
        
        ATExampleListModel *obj = ATExampleListModel.new;
        obj.title = @"自动：下拉刷新";
        obj.conf = conf;
        [datas addObject:obj];
    }
    
    {
        ATDataLoadConf *conf = ATDataLoadConf.new;
        conf.mode = ATDataLoadModeAuto;
        conf.component = ATDataLoadComponentLoadMore;
        conf.animated = ATDataLoadAnimatedNone;
        
        ATExampleListModel *obj = ATExampleListModel.new;
        obj.title = @"自动：上拉加载更多";
        obj.conf = conf;
        [datas addObject:obj];
    }
    
    {
        ATDataLoadConf *conf = ATDataLoadConf.new;
        conf.mode = ATDataLoadModeAuto;
        conf.component = ATDataLoadComponentNone;
        conf.animated = ATDataLoadAnimatedNone;
        
        ATExampleListModel *obj = ATExampleListModel.new;
        obj.title = @"自动：无";
        obj.conf = conf;
        [datas addObject:obj];
    }
    
    {
        ATDataLoadConf *conf = ATDataLoadConf.new;
        conf.mode = ATDataLoadModeManual;
        conf.component = ATDataLoadComponentRefresh | ATDataLoadComponentLoadMore;
        conf.animated = ATDataLoadAnimatedRefresh;
        
        ATExampleListModel *obj = ATExampleListModel.new;
        obj.title = @"手动：下拉刷新+上拉加载更多";
        obj.conf = conf;
        [datas addObject:obj];
    }
    
    {
        ATDataLoadConf *conf = ATDataLoadConf.new;
        conf.mode = ATDataLoadModeManual;
        conf.component = ATDataLoadComponentRefresh;
        conf.animated = ATDataLoadAnimatedRefresh;
        
        ATExampleListModel *obj = ATExampleListModel.new;
        obj.title = @"手动：下拉刷新";
        obj.conf = conf;
        [datas addObject:obj];
    }
    
    {
        ATDataLoadConf *conf = ATDataLoadConf.new;
        conf.mode = ATDataLoadModeManual;
        conf.component = ATDataLoadComponentLoadMore;
        conf.animated = ATDataLoadAnimatedNone;
        
        ATExampleListModel *obj = ATExampleListModel.new;
        obj.title = @"手动：上拉加载更多";
        obj.conf = conf;
        [datas addObject:obj];
    }
    
    {
        ATDataLoadConf *conf = ATDataLoadConf.new;
        conf.mode = ATDataLoadModeManual;
        conf.component = ATDataLoadComponentNone;
        conf.animated = ATDataLoadAnimatedNone;
        
        ATExampleListModel *obj = ATExampleListModel.new;
        obj.title = @"手动：无";
        obj.conf = conf;
        [datas addObject:obj];
    }
    
    self.datas = datas.copy;
    [self.tableView reloadData];
}

#pragma mark - getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.rowHeight = 60;
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *idr = NSStringFromClass(UITableViewCell.class);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idr];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idr];
    }
    cell.backgroundColor = indexPath.row % 2 ? UIColor.whiteColor : [UIColor.blackColor colorWithAlphaComponent:0.1];
    cell.textLabel.text = self.datas[indexPath.row].title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ATExampleListModel *obj = self.datas[indexPath.row];
    ATExampleViewController *vc = ATExampleViewController.new;
    vc.title = obj.title;
    vc.conf = obj.conf;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
