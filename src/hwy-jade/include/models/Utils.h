#ifndef Utils_h
#define Utils_h
#import <UIKit/UIKit.h>

@interface Utils:NSObject;

-(NSString*) genCuid;

-(NSDictionary *)parseQuery:(NSString*)query;
@end
#endif