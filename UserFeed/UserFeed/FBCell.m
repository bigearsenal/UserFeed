//
//  FBCell.m
//  FacebookFeed
//
//  Created by Aaron Bratcher on 3/10/14.
//  Copyright (c) 2014 Aaron L. Bratcher. All rights reserved.
//

#import "FBCell.h"
#import "NSString+Additions.h"
#import "NSDate+Additions.h"
#import <FacebookSDK/FacebookSDK.h>
#import "DBFBProfilePictureView.h"

@interface FBCell ()

@property (weak, nonatomic) IBOutlet UILabel *source;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UITextView *body;
@property (weak, nonatomic) IBOutlet UIImageView *image;

@property (copy) NSString *from_id;

@end

@implementation FBCell

- (void)setWallPost:(NSDictionary *)wallPost {
	static NSDateFormatter *dateFormatter;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
	});
	
	_wallPost = wallPost;
	
	NSDictionary *from = wallPost[@"from"];
	NSString *from_id = from[@"id"];
	self.from_id = from_id;
	self.source.text = from[@"name"];
	
	NSDate *date = [dateFormatter dateFromString:wallPost[@"updated_time"]];
	self.time.text = [NSString stringWithFormat:@"%@ %@", [date longRelativeDateString], [date timeString]];
	self.body.text = wallPost[@"message"];
	self.image.image = [UIImage imageNamed:@"photoIcon"]; // generic profile image
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	parameters[@"access_token"] = FBSession.activeSession.accessTokenData;
	parameters[@"width"] = @"64";
	parameters[@"height"] = @"64";
	NSString *path = [NSString stringWithFormat:@"%@/picture", from_id];
	
	[self.client getPath:path
			  parameters:parameters
				 success:^(AFHTTPRequestOperation *operation, id responseObject) {
					 if ([from_id isEqualToString:self.from_id]) {
						 self.image.image = [UIImage imageWithData:responseObject];
					 }
				 }
				 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
					 NSLog(error.description);
				 }];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
	                                         selector:@selector(preferredContentSizeChanged:)
	                                             name:UIContentSizeCategoryDidChangeNotification
	                                           object:nil];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
	[[self textLabel] setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
}

@end
