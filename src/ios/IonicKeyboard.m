#import "IonicKeyboard.h"
#import "UIWebViewAccessoryHiding.h"
#import <Cordova/CDVAvailability.h>

@implementation IonicKeyboard

@synthesize hideKeyboardAccessoryBar = _hideKeyboardAccessoryBar;
@synthesize disableScroll = _disableScroll;

- (void)pluginInitialize
{
  
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    __weak IonicKeyboard* weakSelf = self;

    //set defaults
    self.hideKeyboardAccessoryBar = NO;
    self.disableScroll = NO;
  
    self.webView.scrollView.delegate = self;
    
    _keyboardShowObserver = [nc addObserverForName:UIKeyboardWillShowNotification
                               object:nil
                               queue:[NSOperationQueue mainQueue]
                               usingBlock:^(NSNotification* notification) {
                                   
                                   CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
                                   keyboardFrame = [self.viewController.view convertRect:keyboardFrame fromView:nil];
                                   
                                   [weakSelf.commandDelegate evalJs:[NSString stringWithFormat:@"cordova.plugins.Keyboard.isVisible = true; cordova.fireWindowEvent('native.showkeyboard', { 'keyboardHeight': %@ }); ", [@(keyboardFrame.size.height) stringValue]]];
                              
                                   
                               }];
    
    _keyboardHideObserver = [nc addObserverForName:UIKeyboardWillHideNotification
                               object:nil
                               queue:[NSOperationQueue mainQueue]
                               usingBlock:^(NSNotification* notification) {
                                   [weakSelf.commandDelegate evalJs:@"cordova.plugins.Keyboard.isVisible = false; cordova.fireWindowEvent('native.hidekeyboard'); "];
                               }];
}
- (BOOL)disableScroll
{
    return _disableScroll;
}

- (void)setDisableScroll:(BOOL)disableScroll
{
    if (disableScroll == _disableScroll) {
        return;
    }
    if (disableScroll){
        self.webView.scrollView.scrollEnabled = NO;
    }
    else {
        self.webView.scrollView.scrollEnabled = YES;
    }

    _disableScroll = disableScroll;
}


- (BOOL)hideKeyboardAccessoryBar
{
    return _hideKeyboardAccessoryBar;
}

- (void)setHideKeyboardAccessoryBar:(BOOL)hideKeyboardAccessoryBar
{
    if (hideKeyboardAccessoryBar == _hideKeyboardAccessoryBar) {
        return;
    }
    if (hideKeyboardAccessoryBar){
        self.webView.hackishlyHidesInputAccessoryView = YES;
    }
    else {
        self.webView.hackishlyHidesInputAccessoryView = NO;
    }

    _hideKeyboardAccessoryBar = hideKeyboardAccessoryBar;
}


/* ------------------------------------------------------------- */

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [scrollView setContentOffset: CGPointZero];
}

/* ------------------------------------------------------------- */

- (void)dealloc
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];

    [nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [nc removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    [super dealloc];
}

/* ------------------------------------------------------------- */

- (void) disableScroll:(CDVInvokedUrlCommand*)command
{
    if (!command.arguments || ![command.arguments count]){
      return;
    }
    id value = [command.arguments objectAtIndex:0];
    
    self.disableScroll = [value boolValue];
}

- (void) hideKeyboardAccessoryBar:(CDVInvokedUrlCommand*)command
{
    if (!command.arguments || ![command.arguments count]){
      return;
    }
    id value = [command.arguments objectAtIndex:0];
    
    self.hideKeyboardAccessoryBar = [value boolValue];
}

- (void) close:(CDVInvokedUrlCommand*)command
{
    [self.webView endEditing:YES];
}

@end
