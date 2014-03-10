// NSString+Additions.h
#import <Foundation/Foundation.h>

@interface NSString (Additions)
- (BOOL)isIn:(NSString *)strings, ... NS_REQUIRES_NIL_TERMINATION;
- (NSString *)camelcaseString;
- (NSString *)capitalizeFirstLetterString;
- (NSString *)md5;
- (NSString *)sha1;
- (NSString *)sha2WithDigestLength:(int)length;
- (NSDate *)dateValue;
- (NSString *)urlEncode;
- (NSString *)urlDecode;
- (NSString *)sqlEscapeQuotes;
- (NSData *)dataValue;
- (NSString *)stringByTrimmingLeadingCharactersInSet: (NSCharacterSet *)characterSet;
- (NSString *)stringByTrimmingLeadingWhitespaceAndNewlineCharacters;
- (NSString *)stringByTrimmingTrailingCharactersInSet: (NSCharacterSet *)characterSet;
- (NSString *)stringByTrimmingTrailingWhitespaceAndNewlineCharacters;

- (NSString *)trim;

+ (NSString *)stringFromData:(NSData *)dataValue;

@end