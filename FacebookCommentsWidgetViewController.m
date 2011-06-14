    //
//  FacebookCommentsWidgetViewController.m
//  RaiNews24
//
//  Created by Pronetics on 14/06/11.
//  Copyright 2011 Pronetics. All rights reserved.
//

#import "FacebookCommentsWidgetViewController.h"


@implementation FacebookCommentsWidgetViewController

- (id)initWithFrame:(CGRect)_initFrame type:(FacebookCommentsWidgetType)_type andUrl:(NSString *)_url
{
	if (self = [super init]) {
		widgetType = _type;		
		initFrame = _initFrame;
		detailUrl = [_url copy];
	}
	return self;
}

-(void)loadHtmlWidget 
{
	NSString *imagePath = [[NSBundle mainBundle] resourcePath];
	imagePath = [imagePath stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
	imagePath = [imagePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	NSMutableString *html = [[NSMutableString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fb-comments" ofType:@"html"]];
	[html replaceOccurrencesOfString:@"PAGEURL" withString:detailUrl options:NSLiteralSearch range: NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:@"WIDGETWIDTH" withString:[NSString stringWithFormat:@"%f",rootWebView.bounds.size.width-15] options:NSLiteralSearch range: NSMakeRange(0, [html length])];
	[rootWebView loadHTMLString:html baseURL:[NSURL URLWithString: [NSString stringWithFormat:@"file://%@/",imagePath]]];
	[html release];
}

- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:initFrame];
	self.view.backgroundColor = [UIColor clearColor];
	
	rootWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
	rootWebView.delegate = self;
	rootWebView.backgroundColor = [UIColor clearColor];
	
	if (widgetType == FacebookCommentsWidgetTypeAutosized) {
		for (id subview in rootWebView.subviews)
			if ([[subview class] isSubclassOfClass: [UIScrollView class]])
				((UIScrollView *)subview).bounces = NO;
	}
	[self loadHtmlWidget];
	
	[self.view addSubview:rootWebView];
	[rootWebView release];
}




- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
	// Sono le richieste della Webview principale
	if (aWebView == rootWebView) {
		if (widgetType == FacebookCommentsWidgetTypeAutosized) {
			NSString *output = [rootWebView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"fb-comments\").offsetHeight;"];
			self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.bounds.size.width,([output floatValue] + 100));
			rootWebView.frame = CGRectMake(0, 0, aWebView.bounds.size.width,([output floatValue] + 100));
			[[NSNotificationCenter defaultCenter] postNotificationName:kFacebookCommentsWidgetResizedNotification object:rootWebView];
		}
	}else {
	// Richieste del popup
		[aWebView stringByEvaluatingJavaScriptFromString:@"window.close = function() {  window.location = \"close://close\"; }"];
	}

	


}


-(BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
navigationType:(UIWebViewNavigationType)navigationType;
{
	// Sono le richieste della Webview principale
	if (webView == rootWebView) {
		NSLog(@"root navigation type %d url tryed to call %@",navigationType,  [[request URL] absoluteString]);
		
		// FACEBOOK
		NSRange FBloginRequest = [[[request URL] absoluteString]
							   rangeOfString:@"www.facebook.com/login.php"];
		
		if (FBloginRequest.location != NSNotFound) {
			// mostro il popup
			NSLog(@"asd");
			[self loadAndPresentPopupWithRequest:request];
			return NO;
		}
		
		NSRange loggedInBackUrlRange = [[[request URL] absoluteString]
						  rangeOfString:@"www.facebook.com/connect/window_comm.php"];
		
		if (loggedInBackUrlRange.location != NSNotFound) {
			[self loadHtmlWidget];
			return NO;
		}	
		//YAHOO
		NSRange YahooRequestRange = [[[request URL] absoluteString]
										rangeOfString:@"yahoo.com"];
		if (YahooRequestRange.location != NSNotFound) {
			NSLog(@"NOt SUpported Yet");	
			return NO;
		}

		//AOL
		NSRange AolRequestRange = [[[request URL] absoluteString]
									 rangeOfString:@"aol.com"];
		if (AolRequestRange.location != NSNotFound) {
			NSLog(@"NOt SUpported Yet");	
			return NO;
		}
		//MSN
		NSRange HotmailRequestRange = [[[request URL] absoluteString]
									 rangeOfString:@"live.com"];
		if (HotmailRequestRange.location != NSNotFound) {
			NSLog(@"NOt SUpported Yet");	
			return NO;
		}
	} else {
	// Sono le richieste del popup 	
		NSLog(@"POPUP navigation type %d url tryed to call %@",navigationType,  [[request URL] absoluteString]);
		if ([[[request URL] scheme] isEqualToString:@"close"]) {
			[self closePopup];
			return NO;
		}

		NSRange loggedInBackUrlRange = [[[request URL] absoluteString]
						  rangeOfString:@"www.facebook.com/connect/window_comm.php"];
		if (loggedInBackUrlRange.location != NSNotFound) {
			[rootWebView loadRequest:request];
			[self closePopup];
			return NO;
		}
		
	}
	return navigationType != UIWebViewNavigationTypeLinkClicked;
}

- (void) loadAndPresentPopupWithRequest:(NSURLRequest *)request
{
	UIViewController *popupView = [[UIViewController alloc] init];
	popupView.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 540, 576)];
	popupView.view.backgroundColor = [UIColor yellowColor];
	
	UIWebView *popupWebView = [[UIWebView alloc] initWithFrame:popupView.view.bounds];
	popupWebView.delegate = self;
	[popupView.view addSubview:popupWebView];
	[popupWebView release];
	[popupWebView loadRequest:request];

	UINavigationController *popupNavController = [[UINavigationController alloc] initWithRootViewController:popupView];
	[popupView release];
	popupNavController.modalPresentationStyle = UIModalPresentationFormSheet;
	
	popupView.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
												initWithBarButtonSystemItem:UIBarButtonSystemItemDone
												target:self
												action:@selector(closePopup)] autorelease];
	
	[self presentModalViewController:popupNavController animated:YES];
	[popupNavController release];
}


-(void)closePopup
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
	[detailUrl release];
	[rootWebView release];
    [super dealloc];
}


@end
