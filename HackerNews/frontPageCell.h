//
//  frontPageCell.h
//  HackerNews
//
//  Created by Benjamin Gordon on 11/6/12.
//  Copyright (c) 2012 Benjamin Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

#define kFrontPageCellHeight 60
#define kFrontPageActionsHeight 60


@interface frontPageCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *postedTimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *scoreLabel;
@property (retain, nonatomic) IBOutlet UILabel *commentsLabel;
@property (retain, nonatomic) IBOutlet UILabel *authorLabel;
@property (retain, nonatomic) IBOutlet UIButton *commentTagButton;
@property (retain, nonatomic) IBOutlet UIButton *commentBGButton;
@property (retain, nonatomic) IBOutlet UIImageView *bottomBar;
@property (weak, nonatomic) IBOutlet UIButton *voteUpButton;
@property (weak, nonatomic) IBOutlet UIButton *voteDownButton;
@property (weak, nonatomic) IBOutlet UIView *postActionsView;
@property (retain, nonatomic) IBOutlet UILabel *descLabel;

-(frontPageCell *)setCellWithPost:(Post *)post atIndex:(NSIndexPath *)indexPath fromController:(UIViewController *)controller;

@end
