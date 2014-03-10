// NSString+Additions.m
#import "NSString+Additions.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

static NSDateFormatter *dateFormatter;

@implementation NSString (Additions)

- (BOOL)isIn:(NSString *)strings, ... {
  BOOL isFound = NO;

  va_list args;
  va_start(args, strings);
  for (NSString *arg = strings; arg != nil; arg = va_arg(args, NSString *)) {
    if ([self caseInsensitiveCompare:arg] == NSOrderedSame) {
      isFound = YES;
      break;
    }
  }
  va_end(args);

  return isFound;
}

//
// return the string after converting first letter to upper case
//
- (NSString *)camelcaseString {
  NSString *firstChar = [[self substringToIndex:1] lowercaseString];
  return [self stringByReplacingCharactersInRange:(NSRange) {
    .location = 0, .length = 1
  }
                                       withString:firstChar];
}

- (NSString *)capitalizeFirstLetterString {
  NSString *firstChar = [[self substringToIndex:1] capitalizedString];
  return [self stringByReplacingCharactersInRange:(NSRange) {
    .location = 0, .length = 1
  }
                                       withString:firstChar];
}

- (NSString *)md5 {
  NSString *input = self;

  const char *cStr = [input UTF8String];
  unsigned char digest[16];
  CC_MD5(cStr, strlen(cStr), digest); // This is the md5 call

  NSMutableString *output =
      [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];

  for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    [output appendFormat:@"%02x", digest[i]];

  return output;
}

- (NSString *)sha1 {
  NSString *input = self;

  NSData *data =
      [input dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
  uint8_t digest[CC_SHA1_DIGEST_LENGTH];
  CC_SHA1(data.bytes, data.length, digest);
  NSMutableString *output =
      [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

  for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    [output appendFormat:@"%02x", digest[i]];

  return output;
}

- (NSString *)sha2WithDigestLength:(int)length {
  NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
  int digestLength = 0;

  switch (length) {
  case 224:
    digestLength = CC_SHA224_DIGEST_LENGTH;
    break;
  case 256:
    digestLength = CC_SHA256_DIGEST_LENGTH;
    break;
  case 384:
    digestLength = CC_SHA384_DIGEST_LENGTH;
    break;
  case 512:
    digestLength = CC_SHA512_DIGEST_LENGTH;
    break;
  default:
    NSLog(@"Valid digest lengths are 224, 256, 384, 512");
    return @"";
  }

  uint8_t digest[digestLength];

  switch (length) {
  case 224:
    CC_SHA224(data.bytes, data.length, digest);
    break;
  case 256:
    CC_SHA256(data.bytes, data.length, digest);
    break;
  case 384:
    CC_SHA384(data.bytes, data.length, digest);
    break;
  case 512:
    CC_SHA512(data.bytes, data.length, digest);
    break;
  }

  NSMutableString *output =
      [NSMutableString stringWithCapacity:digestLength * 2];

  for (int i = 0; i < digestLength; i++) {
    [output appendFormat:@"%02x", digest[i]];
  }

  return output;
}

- (NSDate *)dateValue {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
      dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.'SSSZZZZZ"];
  });

  NSDate *date = [dateFormatter dateFromString:self];

  return date;
}

- (NSString *)urlEncode {
  return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
      NULL, (__bridge CFStringRef)self, NULL,
      (CFStringRef) @"!*'\"();:@&=+$,/?%#[]% ",
      CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
}

- (NSString *)urlDecode {
  return (__bridge_transfer NSString *)
      CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
          NULL, (__bridge CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8);
}

- (NSString *)sqlEscapeQuotes {
  return [self stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
}

- (NSData *)dataValue {
  return [self dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)stringFromData:(NSData *)dataValue {
  return
      [[NSString alloc] initWithData:dataValue encoding:NSUTF8StringEncoding];
}

- (NSString *)stringByTrimmingLeadingCharactersInSet:
                  (NSCharacterSet *)characterSet {
  NSRange rangeOfFirstWantedCharacter =
      [self rangeOfCharacterFromSet:[characterSet invertedSet]];
  if (rangeOfFirstWantedCharacter.location == NSNotFound) {
    return @"";
  }
  return [self substringFromIndex:rangeOfFirstWantedCharacter.location];
}

- (NSString *)stringByTrimmingLeadingWhitespaceAndNewlineCharacters {
  return [self stringByTrimmingLeadingCharactersInSet:
                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)stringByTrimmingTrailingCharactersInSet:
                  (NSCharacterSet *)characterSet {
  NSRange rangeOfLastWantedCharacter =
      [self rangeOfCharacterFromSet:[characterSet invertedSet]
                            options:NSBackwardsSearch];
  if (rangeOfLastWantedCharacter.location == NSNotFound) {
    return @"";
  }
  return [self substringToIndex:rangeOfLastWantedCharacter.location +
                                1]; // non-inclusive
}

- (NSString *)stringByTrimmingTrailingWhitespaceAndNewlineCharacters {
  return [self stringByTrimmingTrailingCharactersInSet:
                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)trim {
  NSString *rightTrimmedString =
      [self stringByTrimmingTrailingCharactersInSet:
                [NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSString *fullTrimmedString = [rightTrimmedString
      stringByTrimmingLeadingCharactersInSet:
          [NSCharacterSet whitespaceAndNewlineCharacterSet]];

  return fullTrimmedString;
}

@end