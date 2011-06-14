## iOSFacebookCommentWidget ##

It's a basic implementation for iOS (Primarly iPad, adaptiong it for iPhone should be easy and on the road! ) of the Facebook Web-based [Comment Social-Plugin](http://developers.facebook.com/docs/reference/plugins/comments/).

For now only login with Facebook ID works, the other three are disabled;

Nothing has to be setted and doesn't rely on any other library just include the 3 files and include the header one:

	#import "FacebookCommentsWidgetViewController.h"
	
Using it is damn simple, it is an indipendent ViewController+View so you just have to add his view to your layout:
	
	FacebookCommentsWidgetViewController *fb = [[FacebookCommentsWidgetViewController alloc] 
													initWithFrame:self.view.bounds 
													type:FacebookCommentsWidgetTypeFixed 
													andUrl:@"http://maustbeavlidurl.com"];
	[self.view addSubview:fb.view];
	
Just two things to note:

* **http://maustbeavlidurl.com** is the url for which you want to retrieve the comments, the page where you have the fbml widget, or if u plan to just use it only on iOS it must be an unique and existent url, it's the identifier to which facebook comments are connected.
* the only option for now is to choose from two types of behaviour of the Widget View:
	* `FacebookCommentsWidgetTypeFixed`	this mode the widget view remains the size of the frame you give when nit the controller and is scrollable
	* `FacebookCommentsWidgetTypeAutosized` in this mode (not fully functional) the view tries to resize its frame according to the content length of the comments.   
	when the frame is resized a `kFacebookCommentsWidgetResizedNotification` is posted to allow layout rearranging.
		


### todos ###

* fully test and fix `FacebookCommentsWidgetTypeAutosized`
* add more customizable pieces like backgroundColor, fbml widget type, 
* fix login modal size on iPhone
* manage the other types of login (Yahoo, AOL, MSN)