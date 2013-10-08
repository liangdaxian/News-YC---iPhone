//
//  CreditsCell.m
//  HackerNews
//
//  Created by Ben Gordon on 1/20/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "CreditsCell.h"
#import "ViewController.h"
#import "AppDelegate.h"

@implementation CreditsCell
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)buildUI {
    
}

- (void)setUpAddressForActiveFilter:(int)addr delegate:(id)vcDelegate {
    NSArray *buttons = @[self.addr1Button, self.addr2Button, self.addr3Button, self.addr4Button, self.addr5Button,self.addr6Button];
    if (vcDelegate) {
        delegate = (id <AddressCellDelegate>)vcDelegate;
    }
    
    for (UIButton *button in buttons) {
        [button setTitleColor:(button.tag == addr ? kOrangeColor : [UIColor colorWithWhite:0.5 alpha:1.0]) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(didClickFilterButton:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)didClickFilterButton:(UIButton *)button {
    [delegate setUpAddressWithAddrID:button.tag];
    [self setUpAddressForActiveFilter:button.tag delegate:nil];
}


@end
