//
//  FacebookCommentsWidgetViewController.h
//  RaiNews24
//
//  Created by Pronetics on 14/06/11.
//  Copyright 2011 Pronetics. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kFacebookCommentsWidgetResizedNotification @"kFacebookCommentsWidgetResizedNotification"

typedef enum {
	FacebookCommentsWidgetTypeFixed,
	FacebookCommentsWidgetTypeAutosized
} FacebookCommentsWidgetType;


@interface FacebookCommentsWidgetViewController : UIViewController <UIWebViewDelegate> {
	CGRect initFrame;
	NSString *detailUrl;
	FacebookCommentsWidgetType widgetType;
	
	UIWebView *rootWebView;
}
- (id)initWithFrame:(CGRect)_initFrame type:(FacebookCommentsWidgetType)_type andUrl:(NSString *)_url;
-(void)closePopup;
- (void) loadAndPresentPopupWithRequest:(NSURLRequest *)request;
@end
