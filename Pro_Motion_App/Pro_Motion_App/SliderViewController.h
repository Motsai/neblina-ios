//
//  SliderViewController.h
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 23/11/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SliderViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *mutable_array;
}
@property (nonatomic, retain) IBOutlet UITableView *tbl_view;
@end
