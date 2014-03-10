//
//  NSDate+Additions.m
//  MobileApp
//
//  Created by Aaron Bratcher on 02/21/2013.
//  Copyright (c) 2013 Market Force. All rights reserved.
//

#import "NSDate+Additions.h"

static NSDateFormatter* stringValueFormatter;
static NSDateFormatter* shortDateFormatter;
static NSDateFormatter* mediumDateFormatter;
static NSDateFormatter* longDateFormatter;
static NSDateFormatter* timeFormatter;

@implementation NSDate (Additions)

-(NSString*) stringValue {
	if (!stringValueFormatter) {
		stringValueFormatter = [[NSDateFormatter alloc] init];
		[stringValueFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.'SSSZZZZZ"];
	}
	
	NSString *strDate = [stringValueFormatter stringFromDate:self];

	return strDate;
}

-(NSString*) shortDateString {
	if (!shortDateFormatter) {
		shortDateFormatter = [[NSDateFormatter alloc] init];
		[shortDateFormatter setDateStyle:NSDateFormatterShortStyle];
	}
	
	[shortDateFormatter setDoesRelativeDateFormatting:NO];
	NSString* dateString = [shortDateFormatter stringFromDate:self];
	return dateString;
}

-(NSString*) mediumDateString {
	if (!mediumDateFormatter) {
		mediumDateFormatter = [[NSDateFormatter alloc] init];
		[mediumDateFormatter setDateStyle:NSDateFormatterMediumStyle];
	}
	
	[mediumDateFormatter setDoesRelativeDateFormatting:NO];
	NSString* dateString = [mediumDateFormatter stringFromDate:self];
	return dateString;
}

-(NSString*) shortRelativeDateString {
	if (!shortDateFormatter) {
		shortDateFormatter = [[NSDateFormatter alloc] init];
		[shortDateFormatter setDateStyle:NSDateFormatterShortStyle];
	}
	
	[shortDateFormatter setDoesRelativeDateFormatting:YES];
	NSString* dateString = [shortDateFormatter stringFromDate:self];
	return dateString;

}

-(NSString*) mediumRelativeDateString {
	if (!mediumDateFormatter) {
		mediumDateFormatter = [[NSDateFormatter alloc] init];
		[mediumDateFormatter setDateStyle:NSDateFormatterMediumStyle];
	}
	
	[mediumDateFormatter setDoesRelativeDateFormatting:YES];
	NSString* dateString = [mediumDateFormatter stringFromDate:self];
	return dateString;
}

-(NSString*) longRelativeDateString {
	if (!longDateFormatter) {
		longDateFormatter = [[NSDateFormatter alloc] init];
		[longDateFormatter setDateStyle:NSDateFormatterLongStyle];
	}
	
	[longDateFormatter setDoesRelativeDateFormatting:YES];
	NSString* dateString = [longDateFormatter stringFromDate:self];
	return dateString;

}

-(NSString*) timeString {
	if (!timeFormatter) {
		timeFormatter = [[NSDateFormatter alloc] init];
		[timeFormatter setDateFormat:@"h:mm a"];
	}
	
	NSString* dateString =[timeFormatter stringFromDate:self];
	return dateString;
}

-(BOOL) betweenStartDate:(NSDate*) startDate endDate:(NSDate*) endDate {
	BOOL between = NO;
	
	if (([self compare:startDate] == NSOrderedDescending) &&
		([self compare:endDate] == NSOrderedAscending)) {
		
		between = YES;
	}
	
	return between;
}

-(BOOL) betweenStartTime:(NSDate *)startTime endTime:(NSDate *)endTime {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
		
	NSDate *thisDate = [gregorian dateFromComponents: [gregorian components: (NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate: self]];
	NSDate *startDate = [gregorian dateFromComponents: [gregorian components: (NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate: startTime]];
	NSDate *endDate = [gregorian dateFromComponents: [gregorian components: (NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate: endTime]];
	
	BOOL between = NO;
	
	if (([thisDate compare:startDate] == NSOrderedDescending) &&
		([thisDate compare:endDate] == NSOrderedAscending)) {
		
		between = YES;
	}
	
	return between;
}

-(BOOL) isSameDateAsDate:(NSDate*)testDate {
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
		
	NSDate *thisDate = [gregorian dateFromComponents: [gregorian components: (NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit ) fromDate: self]];
	NSDate *compareDate = [gregorian dateFromComponents: [gregorian components: (NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate: testDate]];

	return [thisDate isEqualToDate:compareDate];
}

@end
