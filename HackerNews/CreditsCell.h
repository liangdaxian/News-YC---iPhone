//
//  CreditsCell.h
//  HackerNews
//
//  Created by Ben Gordon on 1/20/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define kCellCreditsHeight 151
@class ViewController;

@protocol AddressCellDelegate <NSObject>
- (void)setUpAddressWithAddrID:(int)addr;
@end


@interface CreditsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *addr1Button;
@property (weak, nonatomic) IBOutlet UIButton *addr2Button;
@property (weak, nonatomic) IBOutlet UIButton *addr3Button;
@property (weak, nonatomic) IBOutlet UIButton *addr4Button;
@property (weak, nonatomic) IBOutlet UIButton *addr5Button;
@property (weak, nonatomic) IBOutlet UIButton *addr6Button;

@property (weak) id <AddressCellDelegate> delegate;

- (void)setUpAddressForActiveFilter:(int)addr delegate:(id)vcDelegate;

@end
