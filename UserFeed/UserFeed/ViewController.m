//
//  ViewController.m
//  FacebookFeed
//
//  Created by Aaron Bratcher on 3/10/14.
//  Copyright (c) 2014 Aaron L. Bratcher. All rights reserved.
//

#import "ViewController.h"

#import <Social/Social.h>
#import "UIAlertView+Blocks.h"
#import "FBCell.h"
#import "AFHTTPClient.h"
#import <FacebookSDK/FacebookSDK.h>

NSString *const kSocialServices = @"SocialServices";
NSString *const kFBSetup = @"FBSetup";

@interface ViewController ()

@property (strong) NSArray *posts;
@property (strong) AFHTTPClient *fbClient;
@property (strong) FBSession *fbSession;

@end

@implementation ViewController

BOOL hasTwitter = NO;
BOOL hasFacebook = NO;

- (void)viewDidLoad {
	[super viewDidLoad];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	if (![userDefaults boolForKey:kFBSetup]) {
		[userDefaults setBool:YES
		               forKey:kFBSetup];
		[UIAlertView showAlertViewWithTitle:@"Facebook Setup"
		                            message:@"For your own app, you must edit the plist entries for FacebookAppID, FacebookDisplayName, and URL types. See http://developer.facebook.com for more information."
		                  cancelButtonTitle:@"OK"
		                  otherButtonTitles:nil
		                          onDismiss:nil
		                           onCancel:nil];
	}

	if (![SLComposeViewController
	        isAvailableForServiceType:SLServiceTypeFacebook]) {
		if (![userDefaults boolForKey:kSocialServices]) {
			[userDefaults setBool:YES
			               forKey:kSocialServices];
			[UIAlertView showAlertViewWithTitle:@"Social Accounts"
			                            message:@"To see or post activity to Facebook from this app, the accounts must be setup under Settings."
			                  cancelButtonTitle:@"OK"
			                  otherButtonTitles:nil
			                          onDismiss:nil
			                           onCancel:nil];
		}
	} else {
		if (FBSession.activeSession.state == FBSessionStateOpen ||
		    FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
			self.fbSession = FBSession.activeSession;
			hasFacebook = YES;
		}
	}

	self.fbClient = [[AFHTTPClient alloc]
	    initWithBaseURL:[NSURL URLWithString:@"https://graph.facebook.com"]];
	self.fbClient.parameterEncoding = AFFormURLParameterEncoding;

	[self updatePosts];
	[[NSNotificationCenter defaultCenter]
	    addObserver:self
	       selector:@selector(preferredContentSizeChanged:)
	           name:UIContentSizeCategoryDidChangeNotification
	         object:nil];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
	[self.tableView reloadData];
}

- (void)loginFacebook {
	[FBSession openActiveSessionWithReadPermissions:@[
		                                               @"basic_info",
		                                               @"read_stream"
		                                            ]
	                                   allowLoginUI:YES
	                              completionHandler:^(FBSession *session,
	                                                  FBSessionState state,
	                                                  NSError *error) {
                                    if (error) {
                                      hasFacebook = NO;
                                      NSLog(error.debugDescription);
                                      NSLog(error.description);
                                    } else {
                                      self.fbSession = session;
                                      hasFacebook = YES;
                                      [self updatePosts];
                                    }
		                          }];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	self.posts = nil;
	[self.tableView reloadData];
}

#pragma mark - get posts
- (void)updatePosts {
	self.posts = nil;
	[self.tableView reloadData];

	[self getNewsfeed];
}

- (void)getNewsfeed {
	if (!hasFacebook) {
		[self loginFacebook];
		return;
	}

	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	parameters[@"access_token"] = self.fbSession.accessTokenData;

	[self.fbClient getPath:@"me/home"
	    parameters:parameters
	    success:^(AFHTTPRequestOperation *operation, id responseObject) {
//          NSString *responseString =
//              [[NSString alloc] initWithBytes:[responseObject bytes]
//                                       length:[responseObject length]
//                                     encoding:NSUTF8StringEncoding];
//
//          NSLog(responseString);
          NSDictionary *data =
              [NSJSONSerialization JSONObjectWithData:responseObject
                                              options:0
                                                error:NULL];
          self.posts = [data objectForKey:@"data"];
          [self.tableView reloadData];
		}
	    failure:^(AFHTTPRequestOperation *operation,
	              NSError *error) { NSLog(error.description); }];
}

#pragma mark - tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
	return self.posts.count;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *post = [self.posts objectAtIndex:indexPath.row];
	NSString *string = post[@"message"];
	NSDictionary *attributes = @{
		NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
	};
	CGRect bodyFrame =
	    [string boundingRectWithSize:CGSizeMake(CGRectGetWidth(tableView.bounds),
	                                            CGFLOAT_MAX)
	                         options:(NSStringDrawingUsesLineFragmentOrigin |
	                                  NSStringDrawingUsesFontLeading)
	                      attributes:attributes
	                         context:nil];

	return ceilf(CGRectGetHeight(bodyFrame)) + 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	FBCell *fbCell = [tableView dequeueReusableCellWithIdentifier:@"FBCell"];
	NSDictionary *wallPost = [self.posts objectAtIndex:indexPath.row];
	fbCell.client = self.fbClient;
	fbCell.wallPost = wallPost;

	return fbCell;
}

@end
