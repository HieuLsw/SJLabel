//
//  SJLabelViewController.m
//  SJAttributesFactory
//
//  Created by BlueDancer on 2017/12/14.
//  Copyright © 2017年 畅三江. All rights reserved.
//

#import "SJLabelViewController.h"
#import "SJTableViewCell.h"
#import <Masonry.h>
#import "SJAttributesFactoryHeader.h"
#import "SJCTFrameParserConfig.h"
#import "SJCTData.h"
#import "SJCTFrameParser.h"
#import "SJLabelHelper.h"


static NSString *const __TestString =  @"👌👌👌我被班主任杨老师叫到办公室，当时上课铃刚响，杨老师过来找我，我挺奇怪的，什么事啊，可以连课都不上？当时办公室里就我们两个人。杨老师拿出手机，让我看她拍的一张照片，是我们班最近一次班级活动时照的。我们仨坐在一张椅子上，我坐在中间，皱着个眉头，😁小喵托着腮帮子，小桐则靠着椅背坐着。";

static NSString *SJTableViewCellID = @"SJTableViewCell";

@interface SJLabelViewController ()

@property (nonatomic, strong, readonly) NSArray<SJLabelHelper *> *helpers;

@end

@implementation SJLabelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:NSClassFromString(SJTableViewCellID) forCellReuseIdentifier:SJTableViewCellID];
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray<SJLabelHelper *> *helpersM = [NSMutableArray array];
        for ( int i = 0 ; i < 200 ; i ++ ) {
            
            __weak typeof(self) _self = self;

            // create helper
            SJLabelHelper *helper = [SJLabelHelper helperWithAttributedStr:[SJAttributesFactory producingWithTask:^(SJAttributeWorker * _Nonnull worker) {
                
                // insert Text String
                worker.insertText([__TestString substringToIndex:arc4random() % __TestString.length + 1], 0).font([UIFont boldSystemFontOfSize:22]).lineSpacing(8);
                
                // 匹配所有 `我们`
                worker.regexp(@"我们", ^(SJAttributeWorker * _Nonnull regexp) {
                    regexp.nextFontColor([UIColor yellowColor]);
                    regexp.nextUnderline(NSUnderlineStyleSingle, [UIColor yellowColor]);
                    
                    // add action
                    regexp.nextAction(^(NSRange range, NSAttributedString * _Nonnull matched) {
                        NSLog(@"`%@` 被点击了", matched.string);
                        __strong typeof(_self) self = _self;
                        if ( !self ) return ;
                        UIViewController *vc = [UIViewController new];
                        vc.title = matched.string;
                        vc.view.backgroundColor = [UIColor whiteColor];
                        [self.navigationController pushViewController:vc animated:YES];
                    });
                });
            }] maxWidth:[UIScreen mainScreen].bounds.size.width numberOfLines:0];
            
            // add to container
            [helpersM addObject:helper];
        }
        
        // set helpers
        _helpers = helpersM;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // update UI
            [self.tableView reloadData];
        });

    });
    
    // Do any additional setup after loading the view.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _helpers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJTableViewCell *cell = (SJTableViewCell *)[tableView dequeueReusableCellWithIdentifier:SJTableViewCellID forIndexPath:indexPath];
    cell.helper = _helpers[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SJTableViewCell heightWithContentH:_helpers[indexPath.row].drawData.height_t];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

@end
