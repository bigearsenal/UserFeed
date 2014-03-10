//
//  FBCell.h
//  FacebookFeed
//
//  Created by Aaron Bratcher on 3/10/14.
//  Copyright (c) 2014 Aaron L. Bratcher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPClient.h"

@interface FBCell : UITableViewCell

@property(strong) AFHTTPClient *client;
@property(strong, nonatomic) NSDictionary *wallPost;

@end
