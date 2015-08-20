
#import "CoreAPI.h"
#import "CoreApiConnection.h"
#import "AppDelegate.h"


static int const kTimeInterval = 30;

static NSString *const kUrlServer = @"http://develop.bonuseka.ru/core/core.php";
static NSString *const kUrlImages = @"http://develop.bonuseka.ru/images/";

static NSString *const kActionLoadBeacons = @"load_beacons";
static NSString *const kActionGetOffers = @"get_offers";
static NSString *const kActionGetAssets = @"get_assets";
static NSString *const kActionGetEverything = @"refresh";

static NSString *const kParamAction = @"action";
static NSString *const kParamName = @"name";
static NSString *const kParamCountEvents = @"images";

static NSString *const kParamSuccess = @"success";
static NSString *const kParamUsers = @"users";
static NSString *const kParamBeacons = @"beacons";
static NSString *const kParamAssets = @"assets";
static NSString *const kParamOffers = @"offers";
static NSString *const kParamOfferImage = @"offerImage";
static NSString *const kParamOrgs = @"orgs";
static NSString *const kParamGifts = @"gifts";
static NSString *const kParamExpressions = @"expressions";
static NSString *const kParamTransctions = @"transactions";

@interface CoreAPI()

+(NSString *)encodeParam:(NSString *)param;

@end

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

@implementation CoreAPI

#pragma mark - User

- (void)getListOfOffers{
    NSDictionary *requestParams = @{kParamAction : kActionGetOffers};
    
    NSString *requestParamsString = [self parametersStringFromDictionary:requestParams];
    
    NSURLRequest *request = [self preparePostRequestToUrlString:kUrlServer withParams:requestParamsString];
    
    CoreApiConnection *connection = [[CoreApiConnection alloc] initWithRequest:request delegate:self];
    connection.apiRequestType = ApiRequestTypeGetOffers;
    [connection start];
}

- (void)performListOfOffersFromData:(NSData *)data{
    NSError *error;
    NSDictionary *successData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSDictionary *someData = [successData valueForSafetyKey:kParamSuccess];
    NSArray *offersArray = [someData valueForSafetyKey:kParamOffers];
    if (offersArray.count > 0) {
        for (NSDictionary *offer in offersArray) {
            NSString *offerId = [offer objectForSafetyKey:@"offerId"];
            NSString *offerHeader = [offer objectForSafetyKey:@"offerHeader"];
            NSString *offerBody = [offer objectForSafetyKey:@"offerBody"];
            NSString *offerImageName = [offer objectForSafetyKey:@"offerImage"];
            NSData *offerImageData;
            
            NSError *error;
            
            AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
            NSFetchRequest *fetchRequest = [NSFetchRequest new];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Offers" inManagedObjectContext:delegate.managedObjectContext];
            fetchRequest.entity = entity;
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"offerId==%lu",offerId.integerValue];
            NSArray *fetchedObjects = [delegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (fetchedObjects.count > 0) {
                Offers *assetForDeletting = [fetchedObjects objectAtSafetyIndex:0];
                offerImageData = assetForDeletting.offerImageData;
                [delegate.managedObjectContext deleteObject:assetForDeletting];
            } else {
                offerImageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[kUrlImages stringByAppendingString:offerImageName]]];
            }
            Offers *theOffer = [NSEntityDescription insertNewObjectForEntityForName:@"Offers" inManagedObjectContext:delegate.managedObjectContext];
            theOffer.offerId = [NSNumber numberWithInteger:offerId.integerValue];
            theOffer.offerHeader = offerHeader;
            theOffer.offerBoby = offerBody;
            theOffer.offerImageName = offerImageName;
            theOffer.offerImageData = offerImageData;
            [delegate saveContext];
        }
    }
}

- (void)getListOfAssets{
    NSDictionary *requestParams = @{kParamAction : kActionGetAssets};
    
    NSString *requestParamsString = [self parametersStringFromDictionary:requestParams];
    
    NSURLRequest *request = [self preparePostRequestToUrlString:kUrlServer withParams:requestParamsString];
    
    CoreApiConnection *connection = [[CoreApiConnection alloc] initWithRequest:request delegate:self];
    connection.apiRequestType = ApiRequestTypeGetAssets;
    [connection start];
}

- (void)performListOfAssetsFromData:(NSData *)data{
    NSError *error;
    NSDictionary *successData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSDictionary *someData = [successData valueForSafetyKey:kParamSuccess];
   
    NSArray *assetsArray = [someData valueForSafetyKey:kParamAssets];
    if (assetsArray.count > 0) {
        for (NSDictionary *asset in assetsArray) {
            NSString *assetName = [asset objectForSafetyKey:@"beaconName"];
            NSString *assetId = [asset objectForSafetyKey:@"beaconId"];
            NSString *assetUuid = [asset objectForSafetyKey:@"beaconUuid"];
            NSString *assetOfferId = [asset objectForSafetyKey:@"beaconOffer"];
            NSError *error;
            
            AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
            NSFetchRequest *fetchRequest = [NSFetchRequest new];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Assets" inManagedObjectContext:delegate.managedObjectContext];
            fetchRequest.entity = entity;
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"assetId==%lu",assetId.integerValue];
            NSArray *fetchedObjects = [delegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (fetchedObjects.count > 0) {
                NSManagedObject *assetForDeletting = [fetchedObjects objectAtSafetyIndex:0];
                [delegate.managedObjectContext deleteObject:assetForDeletting];
            }
            Assets *theAsset = [NSEntityDescription insertNewObjectForEntityForName:@"Assets" inManagedObjectContext:delegate.managedObjectContext];
            theAsset.assetId = [NSNumber numberWithInteger:assetId.integerValue];
            theAsset.assetName = assetName;
            theAsset.assetUuid = assetUuid;
            theAsset.offerId = [NSNumber numberWithInteger:assetOfferId.integerValue];
            NSFetchRequest *offerFetchRequest = [NSFetchRequest new];
            NSEntityDescription *offerEntity = [NSEntityDescription entityForName:@"Offers" inManagedObjectContext:delegate.managedObjectContext];
            offerFetchRequest.entity = offerEntity;
            offerFetchRequest.predicate = [NSPredicate predicateWithFormat:@"offerId==%@",assetOfferId];
            NSArray *offerFetchedObjects = [delegate.managedObjectContext executeFetchRequest:offerFetchRequest error:&error];
            theAsset.offer = [offerFetchedObjects objectAtSafetyIndex:0];
            
            [delegate saveContext];
        }
    }
}

- (void)connectionDidFinishLoading:(CoreApiConnection *)connection {
    switch (connection.apiRequestType) {
        case ApiRequestTypeGetOffers:
            [self performListOfOffersFromData:connection.responseData];
            break;
        case ApiRequestTypeGetAssets:
            [self performListOfAssetsFromData:connection.responseData];
            break;
            
        default:
            break;
    }
}

- (void)connection:(CoreApiConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [connection.responseData appendData:data];
}

- (void)connection:(CoreApiConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

#pragma mark - Supply

// Build Request

- (NSURLRequest *)preparePostRequestToUrlString:(NSString *)url withParams:(NSString *)parametersString{
    // Готовим строку с адресом
    NSURL *urlRequest = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:
                                              NSUTF8StringEncoding]];
    // Готовим запрос по строке
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlRequest
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:kTimeInterval];
    // Добавляем параметры запроса

    
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%i", (int)parametersString.length] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:[parametersString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    
    return request;
}

// POST Parameters in One long string

-(NSString *)parametersStringFromDictionary:(NSDictionary *)params{
NSArray *paramList = @[];
for (NSString *name in params) {
    if ([[params objectForKey:name] isKindOfClass:NSNull.class]) {
        continue;
    }
    NSString *value = [NSString stringWithFormat:@"%@", [params objectForKey:name]];
    paramList = [paramList arrayByAddingObject:[NSString stringWithFormat:@"%@=%@", name, [CoreAPI encodeParam:value]]];
}
    NSString *parametersString = [paramList componentsJoinedByString:@"&"];
    return parametersString;
}

// UTF8 Encoding

+ (NSString *)encodeParam:(NSString *)param
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (__bridge CFStringRef) param,
                                                                                 NULL,
                                                                                 CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                 kCFStringEncodingUTF8));
}

@end
