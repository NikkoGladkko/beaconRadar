
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TmhAPI : NSObject <NSURLConnectionDelegate> {
NSMutableData *_responseData;
}

-(void)getListOfBeacons;

@end
