//
//  CheckoutRequest.m
//  AcmeMobileShopping
//
//  Created by Adam Leftik on 8/29/13.
//  Copyright (c) 2013 Adam Leftik. All rights reserved.
//

#import "CheckoutRequest.h"
#import "AppDelegate.h"
#import <ADEUMInstrumentation/ADEUMInstrumentation.h>

@implementation CheckoutRequest
@synthesize checkoutResponse;

-(id) init {
    self = [super init];
    return self;
}

-(void) checkout {
    // AppDynamics Information Point for checkout method - START
    id tracker = [ADEumInstrumentation beginCall:self selector:_cmd];
    NSLog(@"----- Starting Info Point for checkout");
    
    // Stop custom timer for total shopping time (between app open and start of checkout)
    [ADEumInstrumentation stopTimerWithName:@"ShoppingTime"];
    NSLog(@"----- Stopping Custom Timer for Total Shopping Time");
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if ([appDelegate.session shouldLogin])  {
        [appDelegate.session login];
    }
    NSString *checkoutUrl = [appDelegate.url stringByAppendingString:@"rest/cart/co/"];
    
    NSURL *url = [NSURL URLWithString:checkoutUrl];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setValue:appDelegate.session.sessionId forHTTPHeaderField:@"JSESSIONID"];
    [request setValue:appDelegate.username forHTTPHeaderField:@"USERNAME"];
    [request setValue:@"true" forHTTPHeaderField:@"appdynamicssnapshotenabled"];
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *body = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"Response error %@ and ressponse body %@", error, body);
    const char *responseBytes = [body bytes];
    if (responseBytes == nil)
        checkoutResponse = [NSString stringWithUTF8String:"Could not connect to the server"];
    else
        checkoutResponse = [NSString stringWithUTF8String:responseBytes];
    
    // AppDynamics Information Point for checkout method - END
    NSLog(@"----- Ending Info Point for checkout");
    [ADEumInstrumentation endCall:tracker];
}


- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"Checkout got Data");
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"Response started");
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Done loading");
}


@end
