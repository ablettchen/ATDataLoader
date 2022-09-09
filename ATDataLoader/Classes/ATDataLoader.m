//
//  ATDataLoader.m
//  ATDataLoader
//
//  Created by ablett on 2019/4/22.
//  Copyright (c) 2019 ablett. All rights reserved.
//

#import "ATDataLoader.h"


#if __has_include(<MJRefresh/MJRefresh.h>)
#import <MJRefresh/MJRefresh.h>
#else
#import "MJRefresh.h"
#endif

#if __has_include(<Reachability/Reachability.h>)
#import <Reachability/Reachability.h>
#else
#import "Reachability.h"
#endif

#define atSafePerformSelector(obj, sel, arg) ({ \
    BOOL perform = NO; \
    if (obj && sel) { \
        if ([obj respondsToSelector:sel]) { \
            [obj performSelectorOnMainThread:sel withObject:arg waitUntilDone:YES]; \
            perform = YES; \
            } \
    } \
    (perform); \
})


@implementation ATDataRange @end

@interface ATDataLoader ()
@property (nonatomic, strong) ATDataLoadConf *conf;
@property (nonatomic, assign) enum ATDataLoadState state;
@property (nonatomic, strong) ATDataRange *range;
@property (nonatomic, weak, nullable) __kindof UIScrollView *listView;
@property (nonatomic, assign, readonly) BOOL isLastPage;
@property (nonatomic, assign) enum ATBlankType blankType;
@property (nonatomic, strong) ATBlankView *blankView;
@end

@implementation ATDataLoader

- (instancetype)init {
    self = [super init];
    if (self) {
        self.state = ATDataLoadStateIdle;
        self.conf = ATDataLoadDefaultConf.shared.conf.copy;
    }
    return self;
}

#pragma mark - public

- (void)loadNewData {
    
    [self loadNewData:self.conf.animated == ATDataLoadAnimatedRefresh];
}

- (void)loadNewData:(BOOL)animated {
    
    if (animated) {
        if (self.conf.component & ATDataLoadComponentRefresh) {
            [self.listView.mj_header beginRefreshing];
            return;
        }
    }
    
    [self _pullLoadNewData];
}

- (void)loadMoreData {
    
    self.state = ATDataLoadStateLoadMore;
    self.range = ATDataRangeMake(self.range.location, self.conf.length);
    atSafePerformSelector(self.listView, NSSelectorFromString(@"_atLoadData"), nil);
}

- (void)finished:(NSError * _Nullable)error {
    
    [self finished:error completion:nil];
}

- (void)finished:(NSError * _Nullable)error completion:(void(^ _Nullable)(BOOL finished))completion {
    
    switch (self.state) {

        case ATDataLoadStateIdle:
        case ATDataLoadStateRefresh:
            
            [self.listView.mj_header endRefreshing];
            [self.listView.mj_footer resetNoMoreData];
            
            if (self.listView.atItemsCount) {
                if (self.conf.component & ATDataLoadComponentLoadMore) {
                    self.listView.mj_footer = self._loadMoreFooter;
                }else {
                    self.listView.mj_footer = nil;
                }
            }else {
                
                enum ATBlankType blankType = ATBlankTypeNoData;
                if (error) {
                    Reachability *reachable = Reachability.reachabilityForInternetConnection;
                    blankType = (reachable.currentReachabilityStatus == NotReachable) ? ATBlankTypeNoNetwork : ATBlankTypeFailure;
                }
                self.blankType = blankType;
            }
            
            break;
        case ATDataLoadStateLoadMore:
            
            if (self.isLastPage) {
                [self.listView.mj_footer endRefreshingWithNoMoreData];
            }else {
                self.listView.mj_footer = self._loadMoreFooter;
            }
            
            break;
            
        default:
            break;
    }
    
    [UIView animateWithDuration:0
                     animations:^{
        [self reloadData];
    } completion:^(BOOL finished) {
        self.state = ATDataLoadStateIdle;
        if (completion) { completion(finished); }
    }];
}

- (void)reloadData {
    
    if (atSafePerformSelector(self.listView, NSSelectorFromString(@"reloadData"), nil)) {
        [self.listView layoutIfNeeded];
    }
}

#pragma mark - private

- (MJRefreshNormalHeader *)_refreshHeader {
    
    __weak typeof(self) wSelf = self;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [wSelf _pullLoadNewData];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.textColor = self._f2Color;
    [header setTitle:@"正在刷新" forState:MJRefreshStateRefreshing];
    return header;
}

- (MJRefreshAutoNormalFooter *)_loadMoreFooter {
    
    __weak typeof(self) wSelf = self;
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [wSelf loadMoreData];
    }];
    [footer setTitle:@"加载更多……" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"点击加载更多" forState:MJRefreshStateIdle];
    footer.stateLabel.textColor = self._f2Color;
    footer.automaticallyRefresh = YES;
    return footer;
}

- (void)_pullLoadNewData {
    
    if (self.state != ATDataLoadStateIdle) { return; }
    
    self.state = ATDataLoadStateRefresh;
    self.range = ATDataRangeMake(nil, self.conf.component & ATDataLoadComponentLoadMore ? self.conf.length : 0);
    atSafePerformSelector(self.listView, NSSelectorFromString(@"_atLoadData"), nil);
}

- (UIColor *)_f2Color {
    return [UIColor.blackColor colorWithAlphaComponent:0.54];
}

#pragma mark - getter

- (BOOL)isLastPage {
    
    return (self.range.location.length > 0) == NO;
}

- (ATBlankView *)blankView {
    if (!_blankView) {
        _blankView = [ATBlankView new];
    }
    return _blankView;
}

#pragma mark - setter

- (void)setListView:(__kindof UIScrollView *)listView {
    if (_listView != listView) {
        _listView = listView;
        
        if (self.conf.component & ATDataLoadComponentRefresh) {
            self.listView.mj_header = self._refreshHeader;
        }
    }
}

- (ATDataRange *)range {
    if (!_range) {
        _range = ATDataRangeMake(nil, self.conf.length);
    }
    return _range;
}

- (void)setBlankType:(enum ATBlankType)blankType {
    _blankType = blankType;
    
    ATBlank *blank = self.conf.blankDic[@(blankType)];
    if (blank) {
        
        if (blankType != ATBlankTypeNoData) {
            __weak typeof(self) wSelf = self;
            blank.action = ^{
                [wSelf loadNewData];
            };
        }
        
        blank.customView = self.conf.customBlankView;
        self.listView.atBlank = blank;
        [self.listView atReloadBlank];
    }
}

@end



@interface ATDataLoadConf ()<NSCopying>
@property (nonatomic, copy) NSMutableDictionary <NSNumber *, ATBlank *> *blankDic;
@end
@implementation ATDataLoadConf

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mode = ATDataLoadModeAuto;
        self.component = ATDataLoadComponentRefresh;
        self.animated = ATDataLoadAnimatedRefresh;
        self.length = 20;
        self.blankDic = [@{
            @(ATBlankTypeNoNetwork): ATBlank.noNetworkBlank,
            @(ATBlankTypeFailure): ATBlank.failureBlank,
            @(ATBlankTypeNoData): ATBlank.noDataBlank
        } mutableCopy];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    
    ATDataLoadConf *obj = ATDataLoadConf.new;
    obj.mode = self.mode;
    obj.component = self.component;
    obj.animated = self.animated;
    obj.length = self.length;
    return obj;
}

@end


@interface ATDataLoadDefaultConf ()
@property (nonatomic, strong, nullable) ATDataLoadConf *conf;
@end
@implementation ATDataLoadDefaultConf

+ (instancetype)shared {
    
    static id shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

- (void)setup:(void(^ _Nonnull)(ATDataLoadConf * _Nonnull conf))block {
    
    if (!self.conf) { self.conf = ATDataLoadConf.new; }
    block(self.conf);
}

@end



@interface UIScrollView ()
@property (nonatomic, strong, nonnull) ATDataLoader *atLoader;
@property (nonatomic, copy, nonnull) void(^atConfBlock)(ATDataLoadConf * _Nonnull conf);
@property (nonatomic, copy, nonnull) void(^atLoadBlock)(ATDataLoader * _Nonnull loader);
@end

@implementation UIScrollView (ATExtention)

- (void)setAtLoader:(ATDataLoader *)atLoader {
    objc_setAssociatedObject(self, @selector(atLoader), atLoader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ATDataLoader *)atLoader {
    ATDataLoader *obj = objc_getAssociatedObject(self, _cmd);
    if (!obj) {
        obj = ATDataLoader.new;
        [self setAtLoader:obj];
    }
    return obj;
}

- (void)setAtConfBlock:(void (^)(ATDataLoadConf * _Nonnull))atConfBlock {
    objc_setAssociatedObject(self, @selector(atConfBlock), atConfBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(ATDataLoadConf * _Nonnull))atConfBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAtLoadBlock:(void (^)(ATDataLoader * _Nonnull))atLoadBlock {
    objc_setAssociatedObject(self, @selector(atLoadBlock), atLoadBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(ATDataLoader * _Nonnull))atLoadBlock {
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - public

- (void)atUpdateLoadConf:(void(^ _Nonnull)(ATDataLoadConf * _Nonnull conf))block {
    
    ATDataLoadConf *obj = self.atLoader.conf?:ATDataLoadConf.new;
    block(obj);
    self.atLoader.conf = obj;
}

- (void)atLoadData:(void(^ _Nonnull)(ATDataLoader * _Nonnull loader))block {
    
    self.atLoader.listView = self;
    self.atLoadBlock = block;
    
    if (self.atLoader.conf.mode == ATDataLoadModeManual) { return; }
    if (self.atLoader.conf.component & ATDataLoadComponentRefresh ||
        self.atLoader.conf.component & ATDataLoadComponentLoadMore) {
        
        [self.atLoader loadNewData:(self.atLoader.conf.animated == ATDataLoadAnimatedRefresh)];
        return;
    }
    
    block(self.atLoader);
}

#pragma mark - private

- (void)_atLoadData {
    
    self.atLoadBlock(self.atLoader);
}

@end


@implementation ATDataLoader (Business)

- (NSDictionary *)rangeDic {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.range.location.length > 0) { dic[@"nextId"] = self.range.location; }
    if (self.range.length > 0) { dic[@"count"] = [NSString stringWithFormat:@"%tu", self.range.length]; }
    return dic.copy;
}

@end
