//
//  ATDataLoader.h
//  ATDataLoader
//
//  Created by ablett on 2019/4/22.
//  Copyright (c) 2019 ablett. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<ATBlank/ATBlank.h>)
#import <ATBlank/ATBlank.h>
#else
#import "ATBlank.h"
#endif

NS_ASSUME_NONNULL_BEGIN


// 数据加载模式
typedef NS_ENUM(NSUInteger, ATDataLoadMode) {
    ATDataLoadModeAuto,                           // 自动
    ATDataLoadModeManual,                         // 手动
};

// 数据加载状态
typedef NS_ENUM(NSUInteger, ATDataLoadState) {
    ATDataLoadStateIdle,                        // 空闲
    ATDataLoadStateRefresh,                     // 下拉刷新
    ATDataLoadStateLoadMore,                    // 上拉加载
};

// 数据加载组件
typedef NS_OPTIONS(NSUInteger, ATDataLoadComponent) {
    ATDataLoadComponentNone = 0,                // 无
    ATDataLoadComponentRefresh = 1 << 0,        // 下拉刷新
    ATDataLoadComponentLoadMore = 1 << 1,       // 上拉加载
};

// 数据加载动画
typedef NS_ENUM(NSUInteger, ATDataLoadAnimated) {
    ATDataLoadAnimatedNone,                     // 无动效
    ATDataLoadAnimatedRefresh,                  // 下拉动效
    ATDataLoadAnimatedHud,                      // Hud，传递给网络组件触发
};


@class ATDataLoadConf;

@interface ATDataRange : NSObject
@property (nonatomic, copy, nullable) NSString *location;
@property (nonatomic, assign) NSUInteger length;
@end

NS_INLINE ATDataRange *ATDataRangeMake(NSString * _Nullable loc, NSUInteger len) {
    ATDataRange *obj = [ATDataRange new];
    obj.location = loc;
    obj.length = len;
    return obj;
}

@interface ATDataLoader : NSObject

@property (nonatomic, strong, readonly, nullable) ATDataLoadConf *conf; // 加载配置
@property (nonatomic, assign, readonly) enum ATDataLoadState state;     // 加载状态
@property (nonatomic, strong, readonly, nonnull) ATDataRange *range;    // 数据区间
@property (nonatomic, assign, readonly) BOOL isLastPage;                // 是否最后一页

// 加载新数据
- (void)loadNewData;
- (void)loadNewData:(BOOL)animated;

// 结束加载
- (void)finished:(NSError * _Nullable)error;
- (void)finished:(NSError * _Nullable)error completion:(void(^ _Nullable)(BOOL finished))completion;

// 刷新
- (void)reloadData;

@end


@interface ATDataLoadConf : NSObject

@property (nonatomic, assign) enum ATDataLoadMode mode;                     // 刷新模式：自动、手动
@property (nonatomic, assign) ATDataLoadComponent component;                // 刷新组件：无、下拉、上拉
@property (nonatomic, assign) enum ATDataLoadAnimated animated;             // 加载动画样式：无、下拉、hud
@property (nonatomic, assign) NSUInteger length;                            // 数据加载长度

@property (nonatomic, copy, readonly, nonnull) NSMutableDictionary <NSNumber *, ATBlank *> *blankDic; // 空白页配置
@property (nonatomic, strong, nullable) UIView *customBlankView;                                      // 自定义空白视图

@end

@interface ATDataLoadDefaultConf : NSObject

@property (nonatomic, strong, readonly, nullable) ATDataLoadConf *conf; // 配置对象
+ (instancetype)shared;                                                 // 单例
- (void)setup:(void(^ _Nonnull)(ATDataLoadConf * _Nonnull conf))block;  // 设置加载配置

@end


@interface UIScrollView (ATExtention)

@property (nonatomic, strong, nonnull, readonly) ATDataLoader *atLoader;

// 更新配置
- (void)atUpdateLoadConf:(void(^ _Nonnull)(ATDataLoadConf * _Nonnull conf))block;

// 加载数据
- (void)atLoadData:(void(^ _Nonnull)(ATDataLoader * _Nonnull loader))block;

@end



@interface ATDataLoader (Business)

// 数据区间字典 @{nextId:@"", count:20}
@property (nonatomic, copy, readonly, nonnull) NSDictionary *rangeDic;

@end


NS_ASSUME_NONNULL_END
