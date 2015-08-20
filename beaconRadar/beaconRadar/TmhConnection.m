//
//  TmhConnection.m
//  Tmh
//
//  Created by Стеценко Руслан on 12.02.13.
//  Copyright (c) 2013 Tmh. All rights reserved.
//

#import "TmhConnection.h"
#import "Reachability.h"

static int const kCacheMaxCount = 100;
static int const kCacheInterval = 86400;
static int const kTimeInterval = 40;

NSString *const kTmhConnectionData = @"data";
NSString *const kTmhConnectionName = @"name";
NSString *const kTmhConnectionFilename = @"filename";


@interface TmhConnection()
{
    int statusCode;
}
@end

@implementation TmhConnection

static NSMutableArray *cachedData;

- (void)defineVariables
{
    self.type = TmhConnectionTypeJSON;
    self.cache = NO;
    self.encodeUrl = YES;
    self.requestJSON = NO;
    
    if (! cachedData) {
        cachedData = [NSMutableArray new];
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        [self defineVariables];
    }
    return self;
}

#pragma mark - Property

- (BOOL)isConnected
{
    return [TmhConnection connected];
}

#pragma mark - Check connection

/*
 * Check device connection to Internet
 */
+ (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

#pragma mark - Methods

- (void)GET:(NSString *)url onSuccess:(TmhConnectionSuccess)onSuccess onError:(TmhConnectionError)onError onFinal:(TmhConnectionFinal)onFinal
{
    [self request:@"GET" url:url onSuccess:onSuccess onError:onError onFinal:onFinal];
}

- (void)GET:(NSString *)url withParams:(NSDictionary *)params andHeaders:(NSDictionary *)headers onSuccess:(TmhConnectionSuccess)onSuccess onError:(TmhConnectionError)onError onFinal:(TmhConnectionFinal)onFinal
{
    [self request:@"GET" url:url withParams:params andHeaders:headers andFiles:nil onSuccess:onSuccess onError:onError onFinal:onFinal];
}

- (void)DELETE:(NSString *)url onSuccess:(TmhConnectionSuccess)onSuccess onError:(TmhConnectionError)onError onFinal:(TmhConnectionFinal)onFinal
{
    [self request:@"DELETE" url:url onSuccess:onSuccess onError:onError onFinal:onFinal];
}

- (void)POST:(NSString *)url withParams:(NSDictionary *)params andHeaders:(NSDictionary *)headers onSuccess:(TmhConnectionSuccess)onSuccess onError:(TmhConnectionError)onError onFinal:(TmhConnectionFinal)onFinal
{
    [self request:@"POST" url:url withParams:params andHeaders:headers andFiles:nil onSuccess:onSuccess onError:onError onFinal:onFinal];
}

- (void)POST:(NSString *)url withParams:(NSDictionary *)params andHeaders:(NSDictionary *)headers andFiles:(NSArray *)files onSuccess:(TmhConnectionSuccess)onSuccess onError:(TmhConnectionError)onError onFinal:(TmhConnectionFinal)onFinal
{
    [self request:@"POST" url:url withParams:params andHeaders:headers andFiles:files onSuccess:onSuccess onError:onError onFinal:onFinal];
}

- (void)PUT:(NSString *)url withParams:(NSDictionary *)params andHeaders:(NSDictionary *)headers onSuccess:(TmhConnectionSuccess)onSuccess onError:(TmhConnectionError)onError onFinal:(TmhConnectionFinal)onFinal
{
    [self request:@"PUT" url:url withParams:params andHeaders:headers andFiles:nil onSuccess:onSuccess onError:onError onFinal:onFinal];
}

#pragma mark - Request

/*
 * Send request
 */
- (void)request:(NSString *)method url:(NSString *)url onSuccess:(TmhConnectionSuccess)onSuccess onError:(TmhConnectionError)onError onFinal:(TmhConnectionFinal)onFinal
{
    DLog(@"Request url : %@", url);
    
    if (self.isCache
        && [method isEqualToString:@"GET"]) {
        
        [self cacheWithUrl:url onFinal:^(NSDictionary *info) {
            if (! info) {
                DLog(@"Request not cached");
                
                [self requestWithoutCache:method url:url onSuccess:onSuccess onError:onError onFinal:onFinal];
                return;
            }
            DLog(@"Request cached");
            
            if (onSuccess) {
                onSuccess(info);
            }
            if (onFinal) {
                onFinal();
            }
        }];
    } else {
        DLog(@"Request without cache");

        [self requestWithoutCache:method url:url onSuccess:onSuccess onError:onError onFinal:onFinal];
    }
}

/*
 * Send asynchronous request
 */
- (void)sendAsynchronousRequest:(NSURLRequest *)request onSuccess:(TmhConnectionSuccess)onSuccess onError:(TmhConnectionError)onError onFinal:(TmhConnectionFinal)onFinal
{
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               
                               dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                   statusCode = (int)[httpResponse statusCode];
                                   
                                   if (error) {
                                       DLog(@"Connection error : %@", error.localizedDescription);
                                       
                                       if (onError) {
                                           DLog(@"Status code %i, content : %@", statusCode, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onError(statusCode, nil);
                                           });
                                       }
                                   } else {
                                       
                                       NSDictionary *info = [self info:data];
                                       
                                       DLog(@"Request finished loading");
                                       
                                       if (! (statusCode >= 200
                                              && statusCode < 300)) {
                                           if (onError) {
                                               DLog(@"Status code %i, content : %@", statusCode, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   onError(statusCode, info);
                                               });
                                           }
                                       } else {
                                           if (self.isCache
                                               && info) {
                                               [self addCache:info url:request.URL.absoluteString];
                                           }
                                           if (onSuccess) {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   onSuccess(info);
                                               });
                                           }
                                       }
                                   }
                                   if (onFinal) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           onFinal();
                                       });
                                   }
                               });
                               
                           }];
}

/*
 * Send request without using cache
 */
- (void)requestWithoutCache:(NSString *)method url:(NSString *)url onSuccess:(TmhConnectionSuccess)onSuccess onError:(TmhConnectionError)onError onFinal:(TmhConnectionFinal)onFinal
{
    if (! self.isConnected) {
        if (onError) {
            onError(TmhConnectionStatusInternet, nil);
        }
        if (onFinal) {
            onFinal();
        }
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURL *urlRequest = [NSURL URLWithString:self.isEncodeUrl ? [url stringByAddingPercentEscapesUsingEncoding:
                                                                     NSUTF8StringEncoding] : url];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlRequest
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                           timeoutInterval:kTimeInterval];
        
        [request addValue:@"0" forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
        
        [request setHTTPMethod:method];
        
        [self sendAsynchronousRequest:request onSuccess:onSuccess onError:onError onFinal:onFinal];
    });
}

/*
 * Request with params and headers
 */
- (void)request:(NSString *)method url:(NSString *)url withParams:(NSDictionary *)params andHeaders:(NSDictionary *)headers andFiles:(NSArray *)files onSuccess:(TmhConnectionSuccess)onSuccess onError:(TmhConnectionError)onError onFinal:(TmhConnectionFinal)onFinal
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        DLog(@"Request url : %@", url);
        
        NSURL *urlRequest = [NSURL URLWithString:self.isEncodeUrl ? [url stringByAddingPercentEscapesUsingEncoding:
                                                                     NSUTF8StringEncoding] : url];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlRequest
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                           timeoutInterval:kTimeInterval];
        [request setHTTPMethod:method];
        
        if (headers) {
            for (NSString *name in headers) {
                DLog(@"Header %@: %@", name, [headers objectForKey:name]);
                [request addValue:[headers objectForKey:name] forHTTPHeaderField:name];
            }
        }
        
        if (params
            || files) {
            
            if (self.isRequestJSON) {
                
                NSError *error;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                                   options:0
                                                                     error:&error];
                
                if (! jsonData) {
                    DLog(@"Got an error: %@", error);
                } else {
                    NSString *stringContent = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    NSString *length = (stringContent ? [NSString stringWithFormat:@"%i", (int)stringContent.length] : @"0");
                    [request addValue:length forHTTPHeaderField:@"Content-Length"];
                    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                    
                    [request setHTTPBody:jsonData];
                    
                    DLog(@"Request content : %@", stringContent);
                }
            } else {
                NSArray *paramList = @[];
                
                for (NSString *name in params) {
                    
                    if ([[params objectForKey:name] isKindOfClass:NSNull.class]) {
                        continue;
                    }
                    NSString *value = [NSString stringWithFormat:@"%@", [params objectForKey:name]];
                    paramList = [paramList arrayByAddingObject:[NSString stringWithFormat:@"%@=%@", name, [self encodeParam:value]]];
                }
                
                NSString *stringContent = [paramList componentsJoinedByString:@"&"];
                
                if ([method isEqualToString:@"GET"]) {
                    request.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", [request.URL absoluteString], stringContent]];
                    
                    DLog(@"Request url with params : %@", [request.URL absoluteString]);
                    
                } else {
                    
                    if (files) {
                        
                        NSMutableData *body = [NSMutableData data];
                        
                        NSString* boundary = [self uniqueString];
                        
                        [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
                        
                        NSData *header = [[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding];
                        NSData *footer = [[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding];
                        
                        for (NSString *name in params) {
                            
                            [body appendData:header];
                            
                            NSString *value = [NSString stringWithFormat:@"%@", [params objectForKey:name]];
                            [body appendData: [[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", name, value] dataUsingEncoding:NSUTF8StringEncoding]];
                            
                            [body appendData:footer];
                        }
                        
                        for (NSDictionary *file in files) {
                            
                            NSString *name = [file objectForKey:kTmhConnectionName];
                            NSString *filename = [file objectForKey:kTmhConnectionFilename];
                            
                            NSData *data = [file objectForKey:kTmhConnectionData];
                            
                            [body appendData:header];
                            
                            [body appendData: [[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n\r\n", name, filename] dataUsingEncoding:NSUTF8StringEncoding]];
                            [body appendData: [NSData dataWithData:data]];
                            [body appendData: [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                            
                            [body appendData:footer];
                        }
                        
                        [request setValue:[NSString stringWithFormat:@"%i", (int)[body length]] forHTTPHeaderField:@"Content-Length"];
                        [request setHTTPBody:body];
                    } else {
                        [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                        
                        DLog(@"Request content : %@", stringContent);
                        
                        [request addValue:[NSString stringWithFormat:@"%i", (int)stringContent.length] forHTTPHeaderField:@"Content-Length"];
                        
                        [request setHTTPBody:[stringContent dataUsingEncoding:NSUTF8StringEncoding]];
                    }
                }
            }
        }
        
        [self sendAsynchronousRequest:request onSuccess:onSuccess onError:onError onFinal:onFinal];
    });
}

#pragma mark -

- (NSString *)uniqueString
{
    CFUUIDRef uuid = CFUUIDCreate(nil);
    NSString *uuidString = (NSString *) CFBridgingRelease(CFUUIDCreateString(nil, uuid));
    CFRelease(uuid);
    return uuidString;
}

/*
 * Encode param for using in url
 */
- (NSString *)encodeParam:(NSString *)param
{
    return [TmhConnection encodeParam:param];
}

/*
 * Encode param for using in url
 */
+ (NSString *)encodeParam:(NSString *)param
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (__bridge CFStringRef) param,
                                                                                 NULL,
                                                                                 CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                 kCFStringEncodingUTF8));
}

/*
 * Get info with JSON or raw data
 */
- (NSDictionary *)info:(NSData *)data
{
    NSDictionary *info;
    
    switch (self.type) {
        case TmhConnectionTypeJSON:{
            NSError *error;
            info = [NSJSONSerialization JSONObjectWithData:data
                                                   options:0
                                                     error:&error];
            break;
        }
        case TmhConnectionTypeText:{
            info = [NSDictionary dictionaryWithObject:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]  forKey:kTmhConnectionData];
            break;
        }
        default:
            info = [NSDictionary dictionaryWithObject:data forKey:kTmhConnectionData];
    }
    DLog(@"Response: %@", info);

    return info;
}

#pragma mark - Cache

/*
 * Get cahced info by url, nil otherwise
 */
- (void)cacheWithUrl:(NSString *)url onFinal:(TmhConnectionSuccess)onFinal
{
    // to avoid some lag
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        
        NSDictionary *info;
        
        for (NSDictionary *data in cachedData) {
            if ([[data objectForKey:@"url"] isEqualToString:url]) {
                if (((NSDate *)[data objectForKey:@"date"]).timeIntervalSince1970 + kCacheInterval
                    < [NSDate new].timeIntervalSince1970) {
                    [cachedData removeObject:data];
                    break;
                }
                info = [data objectForKey:@"info"];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            onFinal(info);
        });
    });
}

/*
 * Add info to cache
 */
- (void)addCache:(NSDictionary *)info url:(NSString *)url
{
    [cachedData addObject:@{@"url": url, @"info": info, @"date":[NSDate new]}];
    
    if ([cachedData count] > kCacheMaxCount) {
        [cachedData removeObjectsInRange:NSMakeRange(0, [cachedData count] - kCacheMaxCount)];
    }
}

/*
 * Get cached data
 */
- (NSArray *)cachedData
{
    return cachedData;
}

/*
 * Clear cached info
 */
+ (void)clearCache
{
    [cachedData removeAllObjects];
}



@end
