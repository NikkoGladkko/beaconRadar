
#import "TmhAPI.h"

static NSString *const kUrlServer = @"http://develop.bonuseka.ru/core/core.php";
static NSString *const kUrlLoadBeacons = @"load_beacons";
static NSString *const kUrlImages = @"http://develop.bonuseka.ru/images/";


static NSString *const kParamAction = @"action";
static NSString *const kParamName = @"name";
static NSString *const kParamCountEvents = @"images";


NSString *const TmhAPINotificationSignin = @"signin";
NSString *const TmhAPINotificationSignout = @"signout";
NSString *const TmhAPINotificationTrackers = @"trackers";

@implementation NSArray (Reverse)

- (NSArray *)reversedArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

@end

@implementation TmhAPI
{
    //TmhSettings *settings;
}

- (id)init
{
    self = [super init];
    _responseData = [[NSMutableData alloc] init];
    //settings = [TmhSettings new];
    
    return self;
}

- (NSString *)url:(NSString *)part
{
    return [NSString stringWithFormat:@"%@/%@", kUrlServer, part];
}

#pragma mark - User

- (void)getListOfBeacons{
    [[self makeConnectionWithRequestFromURLString:kUrlServer withValues:@"action=load_beacons"] start];
}

- (NSURLConnection *)makeConnectionWithRequestFromURLString:(NSString *)requestURLString withValues:(NSString *)values;
{
    // Create the ASSYNC request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURLString]];
    
    // Specify that it will be a POST request
    request.HTTPMethod = @"POST";
    
    //Content Type string
    //NSString *contentType = @"application/json; charset=utf-8";
    NSString *contentType = @"application/x-www-form-urlencoded; charset=utf-8";
    
    // This is how we set header fields
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    // Convert your data and set your request's HTTPBody property
    NSString *postingData = values;
    
    NSData *requestBodyData = [postingData dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestBodyData;
    // Create url connection and fire request ASSYNC
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    return connection;
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSError *error;
    NSDictionary *someData = [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:&error];
    NSArray *offers = [someData valueForKey:@"success"];
    for (NSDictionary *offer in offers) {
        NSString *image = [offer valueForKey:@"offerImage"];
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [kUrlImages stringByAppendingString:image]]];
        UIImage *imageScreen = [UIImage imageWithData: imageData];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

@end
