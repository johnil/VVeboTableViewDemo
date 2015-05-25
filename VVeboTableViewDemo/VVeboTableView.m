//
//  VVeboTableView.m
//  VVeboTableViewDemo
//
//  Created by Johnil on 15/5/25.
//  Copyright (c) 2015年 Johnil. All rights reserved.
//

#import "VVeboTableView.h"
#import "NSString+Additions.h"
#import "UIScreen+Additions.h"
#import "VVeboTableViewCell.h"
#import "UIView+Additions.h"
@interface VVeboTableView() <UITableViewDelegate, UITableViewDataSource>

@end

@implementation VVeboTableView{
    NSMutableArray *datas;
    NSMutableArray *needLoadArr;
    BOOL scrollToToping;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.dataSource = self;
        self.delegate = self;
        datas = [[NSMutableArray alloc] init];
        needLoadArr = [[NSMutableArray alloc] init];
        
        [self loadData];
        [self reloadData];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return datas.count;
}

- (NSInteger)numberOfSections{
    return 1;
}

- (void)drawCell:(VVeboTableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *data = [datas objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell clear];
    cell.data = data;
    if (needLoadArr.count>0&&[needLoadArr indexOfObject:indexPath]==NSNotFound) {
        [cell clear];
        return;
    }
    if (scrollToToping) {
        return;
    }
    [cell draw];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    VVeboTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell = [[VVeboTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:@"cell"];
    }
    [self drawCell:cell withIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict = datas[indexPath.row];
    float height = [dict[@"frame"] CGRectValue].size.height;
    return height;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [needLoadArr removeAllObjects];
}

//按需加载 - 如果目标行与当前行相差超过指定行数，只在目标滚动范围的前后指定3行加载。
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    NSIndexPath *ip = [self indexPathForRowAtPoint:CGPointMake(0, targetContentOffset->y)];
    NSIndexPath *cip = [[self indexPathsForVisibleRows] firstObject];
    NSInteger skipCount = 8;
    if (labs(cip.row-ip.row)>skipCount) {
        NSArray *temp = [self indexPathsForRowsInRect:CGRectMake(0, targetContentOffset->y, self.width, self.height)];
        NSMutableArray *arr = [NSMutableArray arrayWithArray:temp];
        if (velocity.y<0) {
            NSIndexPath *indexPath = [temp lastObject];
            if (indexPath.row+3<datas.count) {
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0]];
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row+2 inSection:0]];
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row+3 inSection:0]];
            }
        } else {
            NSIndexPath *indexPath = [temp firstObject];
            if (indexPath.row>3) {
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row-3 inSection:0]];
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row-2 inSection:0]];
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
            }
        }
        [needLoadArr addObjectsFromArray:arr];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    scrollToToping = YES;
    return YES;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    scrollToToping = NO;
    [self loadContent];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    scrollToToping = NO;
    [self loadContent];
}

//用户触摸时第一时间加载内容
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if (!scrollToToping) {
        [needLoadArr removeAllObjects];
        [self loadContent];
    }
    return [super hitTest:point withEvent:event];
}

- (void)loadContent{
    if (scrollToToping) {
        return;
    }
    if (self.indexPathsForVisibleRows.count<=0) {
        return;
    }
    if (self.visibleCells&&self.visibleCells.count>0) {
        for (id temp in [self.visibleCells copy]) {
            VVeboTableViewCell *cell = (VVeboTableViewCell *)temp;
            [cell draw];
        }
    }
}

//读取信息
- (void)loadData{
    NSArray *temp = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]];
    for (NSDictionary *dict in temp) {
        NSDictionary *user = dict[@"user"];
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        data[@"avatarUrl"] = user[@"avatar_large"];
        data[@"name"] = user[@"screen_name"];
        NSString *from = [dict valueForKey:@"source"];
        if (from.length>6) {
            NSInteger start = [from indexOf:@"\">"]+2;
            NSInteger end = [from indexOf:@"</a>"];
            from = [from substringFromIndex:start toIndex:end];
        } else {
            from = @"未知";
        }
        data[@"time"] = @"2015-05-25";
        data[@"from"] = from;
        [self setCommentsFrom:dict toData:data];
        [self setRepostsFrom:dict toData:data];
        data[@"text"] = dict[@"text"];
        
        NSDictionary *retweet = [dict valueForKey:@"retweeted_status"];
        if (retweet) {
            NSMutableDictionary *subData = [NSMutableDictionary dictionary];
            NSDictionary *user = retweet[@"user"];
            subData[@"avatarUrl"] = user[@"avatar_large"];
            subData[@"name"] = user[@"screen_name"];
            subData[@"text"] = [NSString stringWithFormat:@"@%@: %@", subData[@"name"], retweet[@"text"]];
            [self setPicUrlsFrom:retweet toData:subData];
            
            {
                float width = [UIScreen screenWidth]-SIZE_GAP_LEFT*2;
                CGSize size = [subData[@"text"] sizeWithConstrainedToWidth:width fromFont:FontWithSize(SIZE_FONT_SUBCONTENT) lineSpace:5];
                NSInteger sizeHeight = (size.height+.5);
                subData[@"textRect"] = [NSValue valueWithCGRect:CGRectMake(SIZE_GAP_LEFT, SIZE_GAP_BIG, width, sizeHeight)];
                sizeHeight += SIZE_GAP_BIG;
                if (subData[@"pic_urls"] && [subData[@"pic_urls"] count]>0) {
                    sizeHeight += (SIZE_GAP_IMG+SIZE_IMAGE+SIZE_GAP_IMG);
                }
                sizeHeight += SIZE_GAP_BIG;
                subData[@"frame"] = [NSValue valueWithCGRect:CGRectMake(0, 0, [UIScreen screenWidth], sizeHeight)];
            }
            data[@"subData"] = subData;
        } else {
            [self setPicUrlsFrom:dict toData:data];
        }
        
        {
            float width = [UIScreen screenWidth]-SIZE_GAP_LEFT*2;
            CGSize size = [data[@"text"] sizeWithConstrainedToWidth:width fromFont:FontWithSize(SIZE_FONT_CONTENT) lineSpace:5];
            NSInteger sizeHeight = (size.height+.5);
            data[@"textRect"] = [NSValue valueWithCGRect:CGRectMake(SIZE_GAP_LEFT, SIZE_GAP_TOP+SIZE_AVATAR+SIZE_GAP_BIG, width, sizeHeight)];
            sizeHeight += SIZE_GAP_TOP+SIZE_AVATAR+SIZE_GAP_BIG;
            if (data[@"pic_urls"] && [data[@"pic_urls"] count]>0) {
                sizeHeight += (SIZE_GAP_IMG+SIZE_IMAGE+SIZE_GAP_IMG);
            }
            
            NSMutableDictionary *subData = [data valueForKey:@"subData"];
            if (subData) {
                sizeHeight += SIZE_GAP_BIG;
                CGRect frame = [subData[@"frame"] CGRectValue];
                CGRect textRect = [subData[@"textRect"] CGRectValue];
                frame.origin.y = sizeHeight;
                subData[@"frame"] = [NSValue valueWithCGRect:frame];
                textRect.origin.y = frame.origin.y+SIZE_GAP_BIG;
                subData[@"textRect"] = [NSValue valueWithCGRect:textRect];
                sizeHeight += frame.size.height;
                data[@"subData"] = subData;
            }
            
            sizeHeight += 30;
            data[@"frame"] = [NSValue valueWithCGRect:CGRectMake(0, 0, [UIScreen screenWidth], sizeHeight)];
        }
        
        [datas addObject:data];
    }
}

- (void)setCommentsFrom:(NSDictionary *)dict toData:(NSMutableDictionary *)data{
    NSInteger comments = [dict[@"reposts_count"] integerValue];
    if (comments>=10000) {
        data[@"reposts"] = [NSString stringWithFormat:@"  %.1fw", comments/10000.0];
    } else {
        if (comments>0) {
            data[@"reposts"] = [NSString stringWithFormat:@"  %ld", (long)comments];
        } else {
            data[@"reposts"] = @"";
        }
    }
}

- (void)setRepostsFrom:(NSDictionary *)dict toData:(NSMutableDictionary *)data{
    NSInteger comments = [dict[@"comments_count"] integerValue];
    if (comments>=10000) {
        data[@"comments"] = [NSString stringWithFormat:@"  %.1fw", comments/10000.0];
    } else {
        if (comments>0) {
            data[@"comments"] = [NSString stringWithFormat:@"  %ld", (long)comments];
        } else {
            data[@"comments"] = @"";
        }
    }
}

- (void)setPicUrlsFrom:(NSDictionary *)dict toData:(NSMutableDictionary *)data{
    NSArray *pic_urls = [dict valueForKey:@"pic_urls"];
    NSString *url = [dict valueForKey:@"thumbnail_pic"];
    NSArray *pic_ids = [dict valueForKey:@"pic_ids"];
    if (pic_ids && pic_ids.count>1) {
        NSString *typeStr = @"jpg";
        if (pic_ids.count>0||url.length>0) {
            typeStr = [url substringFromIndex:url.length-3];
        }
        NSMutableArray *temp = [NSMutableArray array];
        for (NSString *pic_url in pic_ids) {
            [temp addObject:@{@"thumbnail_pic": [NSString stringWithFormat:@"http://ww2.sinaimg.cn/thumbnail/%@.%@", pic_url, typeStr]}];
        }
        data[@"pic_urls"] = temp;
    } else {
        data[@"pic_urls"] = pic_urls;
    }
}

- (void)removeFromSuperview{
    for (UIView *temp in self.subviews) {
        for (VVeboTableViewCell *cell in temp.subviews) {
            if ([cell isKindOfClass:[VVeboTableViewCell class]]) {
                [cell releaseMemory];
            }
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [datas removeAllObjects];
    datas = nil;
    [self reloadData];
    self.delegate = nil;
    [needLoadArr removeAllObjects];
    needLoadArr = nil;
    [super removeFromSuperview];
}

@end
