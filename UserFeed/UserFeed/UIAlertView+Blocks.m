//
//  UIAlertView+Blocks.m
//  UIKitCategoryAdditions
//

#import "UIAlertView+Blocks.h"

static DismissBlock _dismissBlock;
static CancelBlock _cancelBlock;
static int buttonCount;
static BOOL cancelButton;

@implementation UIAlertView (Blocks)

+ (UIAlertView*) showAlertViewWithTitle:(NSString*) title                    
                                message:(NSString*) message 
                      cancelButtonTitle:(NSString*) cancelButtonTitle
                      otherButtonTitles:(NSArray*) otherButtons
                              onDismiss:(DismissBlock) dismissed                   
                               onCancel:(CancelBlock) cancelled {
  
  _cancelBlock  = [cancelled copy];
  _dismissBlock  = [dismissed copy];
  
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                  message:message
                                                 delegate:[self self]
                                        cancelButtonTitle:nil
                                        otherButtonTitles:nil];
  
	buttonCount = 0;
	cancelButton = NO;
	for(NSString *buttonTitle in otherButtons) {
    	[alert addButtonWithTitle:buttonTitle];
		buttonCount++;
	}
	
	if (cancelButtonTitle) {
		[alert addButtonWithTitle:cancelButtonTitle];
		buttonCount++;
		cancelButton = YES;
	}

  
  [alert show];
  return alert;
}

+ (void)alertView:(UIAlertView*) alertView didDismissWithButtonIndex:(NSInteger) buttonIndex {
  
	if(cancelButton && buttonIndex == (buttonCount - 1))
	{
		if (_cancelBlock) {
			_cancelBlock();
		}
	}
  else
  {
	  if (_dismissBlock) {
		   _dismissBlock(buttonIndex);
	  }
  }  
}


@end