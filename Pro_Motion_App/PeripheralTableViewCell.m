//
//  PeripheralTableViewCell.m
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 03/12/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//

#import "PeripheralTableViewCell.h"

@implementation PeripheralTableViewCell

@synthesize connect_btn, devicename_lbl, showmore_btn;

- (void)awakeFromNib
{
    // Initialization code
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self)
//    {
//        // Initialization code
//        
//        self.connect_btn.layer.borderColor = [[UIColor blackColor]CGColor];
//        self.connect_btn.layer.borderWidth = 2.0;
//        self.connect_btn.layer.cornerRadius = 5.0;
//        self.connect_btn.clipsToBounds = YES;
//
//    }
//    return self;
//}



@end
