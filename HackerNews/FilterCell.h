//
//  FilterCell.h
//  HackerNews
//
//  Created by Ben Gordon on 1/19/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define kFilterCellHeight 128

@class ViewController;

@protocol FilterCellDelegate <NSObject>
- (void)filterHomePageWithType:(int)type;
@end

@interface FilterCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *discussButton;
@property (weak, nonatomic) IBOutlet UIButton *newusButton;
@property (weak, nonatomic) IBOutlet UIButton *flagButton;
@property (weak, nonatomic) IBOutlet UIButton *novelButton;
@property (weak, nonatomic) IBOutlet UIButton *AsiaNoButton;
@property (weak, nonatomic) IBOutlet UIButton *AsiaYesButton;
@property (weak, nonatomic) IBOutlet UIButton *AmericaButton;
@property (weak, nonatomic) IBOutlet UIButton *ComicButton;
@property (weak, nonatomic) IBOutlet UIButton *HttpDownloadButton;

@property (weak) id <FilterCellDelegate> delegate;

- (void)setUpCellForActiveFilter:(int)filter delegate:(id)vcDelegate;

@end
