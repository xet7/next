//
// Copyright © 2017-2018 Atlas Engineer LLC.
// Use of this file is governed by the license that can be found in LICENSE.
//

#import "Buffer.h"

#include <xmlrpc-c/base.h>
#include <xmlrpc-c/client.h>
#include <xmlrpc-c/config.h>
#include "Global.h"


@implementation Buffer
@synthesize callBackCount;
@synthesize identifier;

- (instancetype)init
{
    self = [super init];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self setCallBackCount:0];
    [self setNavigationDelegate:self];
    return self;
}

- (NSString *)evaluateJavaScript:(NSString *) javaScript
{
    [self setCallBackCount:[self callBackCount] + 1];
    [self evaluateJavaScript:javaScript completionHandler:^(id result, NSError *error) {
        if (error == nil) {
            if (result != nil) {
                NSString* transformedResult = [NSString stringWithFormat:@"%@", result];
                // Call XML RPC With Result
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    xmlrpc_env env = [[Global sharedInstance] getXMLRPCEnv];
                    const char * const serverUrl = "http://localhost:8081/RPC2";
                    const char * const methodName = "BUFFER-JAVASCRIPT-CALL-BACK";
                    
                    // Make the remote procedure call
                    xmlrpc_client_call(&env, serverUrl, methodName,
                                       "(sss)",
                                       [[self identifier] UTF8String],
                                       [transformedResult UTF8String],
                                       [[@([self callBackCount]) stringValue] UTF8String]);
                });
            }
        } else {
            NSLog(@"evaluateJavaScript error : %@", [error description]);
        }
    }];
    return [@([self callBackCount]) stringValue];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSString *url = [[self URL] absoluteString];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        xmlrpc_env env = [[Global sharedInstance] getXMLRPCEnv];
        const char * const serverUrl = "http://localhost:8081/RPC2";
        const char * const methodName = "BUFFER-DID-COMMIT-NAVIGATION";
        
        // Make the remote procedure call
        xmlrpc_client_call(&env, serverUrl, methodName,
                           "(ss)",
                           [[self identifier] UTF8String],
                           [url UTF8String]);
    });
}

@end
