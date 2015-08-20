
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Offers.h"
#import "Assets.h"

@interface CoreAPI : NSObject <NSURLConnectionDelegate> {
NSMutableData *_responseData;
}

typedef NS_ENUM(NSUInteger, ApiRequestType) {
    ApiRequestTypeGetAssets = 10,
    ApiRequestTypeGetOffers
};

- (void)getListOfOffers;
- (void)getListOfAssets;
@end
