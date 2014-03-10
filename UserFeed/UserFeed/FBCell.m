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

@interface FBCell ()

@property (weak, nonatomic) IBOutlet UILabel *source;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UITextView *body;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIImageView *postImage;

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

	// define a block that will load an image from a URL
	void (^loadImage)(NSString *, UIImageView *) = ^void(NSString *url, UIImageView *view) {
		NSURL *imageURL = [NSURL URLWithString:url];
		dispatch_queue_t postImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
		dispatch_async(postImageQueue, ^{
			NSData *image = [[NSData alloc] initWithContentsOfURL:imageURL];

			dispatch_async(dispatch_get_main_queue(), ^{
				if ([from_id isEqualToString:self.from_id]) {
					view.image = [UIImage imageWithData:image];
				}
			});
		});
	};

	// load post picture
	if (wallPost[@"picture"]) {
		loadImage(wallPost[@"picture"], self.postImage);
	}

	// load profile picture
	NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?redirect=false&type=normal&width=110&height=110", from_id]];
	dispatch_queue_t profileURLQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(profileURLQueue, ^{
		NSData *result = [NSData dataWithContentsOfURL:jsonURL];
		if (result) {
			
			NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:result
																	   options:NSJSONReadingMutableContainers
																		 error:NULL];
			loadImage(resultDict[@"data"][@"url"],self.image);
		}
	});

	[[NSNotificationCenter defaultCenter] addObserver:self
	                                         selector:@selector(preferredContentSizeChanged:)
	                                             name:UIContentSizeCategoryDidChangeNotification
	                                           object:nil];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
	[[self textLabel] setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
}

@end
