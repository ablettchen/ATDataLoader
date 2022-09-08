//
//  ATExampleViewController.m
//  ATDataLoader_Example
//
//  Created by ablett on 2019/4/22.
//  Copyright (c) 2019 ablett. All rights reserved.
//

#import "ATExampleViewController.h"
#import <Masonry/Masonry.h>

@interface ATExampleViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray <NSString *> *datas;
@end

@implementation ATExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self _prepareView];
    [self _prepareData];
}


#pragma mark - private

- (void)_prepareView {
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    if (self.conf.mode == ATDataLoadModeManual) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"load" style:UIBarButtonItemStylePlain target:self action:@selector(_naviItemAction)];
    }
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.bottom.right.equalTo(self.view);
    }];
}

- (void)_prepareData {
    
    __weak typeof(self) wSelf = self;
    
    [self.tableView atUpdateLoadConf:^(ATDataLoadConf * _Nonnull conf) {
        conf.mode = wSelf.conf.mode;
        conf.component = wSelf.conf.component;
        conf.animated = wSelf.conf.animated;
        conf.length = 7;
    }];
    
    [self.tableView atLoadData:^(ATDataLoader * _Nonnull loader) {
        
        [wSelf _requestData:loader.rangeDic
                 completion:^(NSError * _Nullable error, NSArray<NSString *> * _Nullable datas) {
           
            if (loader.state == ATDataLoadStateRefresh) { [wSelf.datas removeAllObjects]; }
            [wSelf.datas addObjectsFromArray:datas];
            [loader finished:error];
        }];
    }];
}

- (void)_naviItemAction {
    
    [self.tableView.atLoader loadNewData];
}

- (void)_requestData:(NSDictionary * _Nullable)parmas
          completion:(void(^ _Nonnull)(NSError * _Nullable error, NSArray <NSString *> * _Nullable datas))completion {
    
    NSString *countObj = [parmas objectForKey:@"count"];
    NSString *nextIdObj = [parmas objectForKey:@"nextId"];
    
    NSInteger count = self.tableView.atLoader.conf.length;
    if (countObj) { count = countObj.integerValue; }
    
    NSInteger nextId = 0;
    if (nextIdObj.length) {
        nextId = nextIdObj.integerValue;
    }
    
    NSMutableArray <NSString *> *datas = [NSMutableArray array];
    
    for (NSInteger i=1; i<=count; i++) {
        NSInteger number = nextId + i;
        [datas addObject:[NSString stringWithFormat:@"%zd", number]];
    }

    nextId = datas.lastObject.integerValue;
    self.tableView.atLoader.range.location = nextId >= count * 3 ? nil : [NSString stringWithFormat:@"%zd", nextId];
    
    completion(nil, datas);
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

- (NSMutableArray<NSString *> *)datas {
    if (!_datas) {
        _datas = [NSMutableArray array];
    }
    return _datas;
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
    cell.textLabel.text = self.datas[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
