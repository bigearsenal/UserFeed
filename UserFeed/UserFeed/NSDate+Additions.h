//
//  NSDate+Additions.h
//  MobileApp
//
//  Created by Aaron Bratcher on 02/21/2013.
//  Copyright (c) 2013 Market Force. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Additions)

-(NSString*) stringValue;
-(NSString*) shortDateString;
-(NSString*) mediumDateString;

-(NSString*) shortRelativeDateString;
-(NSString*) mediumRelativeDateString;
-(NSString*) longRelativeDateString;

-(NSString*) timeString;

-(BOOL) betweenStartDate:(NSDate*) startDate endDate:(NSDate*) endDate;
-(BOOL) betweenStartTime:(NSDate*) startTime endTime:(NSDate*) endTime;
-(BOOL) isSameDateAsDate:(NSDate*)testDate;
@end
