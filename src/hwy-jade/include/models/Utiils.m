#import <Foundation/Foundation.h>
#import "Utils.h"
@interface Utils()

@end
@implementation Utils

-(NSString*) genCuid {
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    
    CFRelease(uuid_string_ref);
    return uuid;
}

-(NSDictionary *)parseQuery:(NSString*)query {
    NSDictionary *params = [[NSDictionary alloc]init];
    NSLog(@"query %@",query);
    NSArray *tmp = [query componentsSeparatedByString:@"&"];
    id i;
    for (i in tmp) {
        NSArray* kp =[i componentsJoinedByString:@"="];
        if ([kp count] != 2) {
            continue;
        }
        [params setValue:kp[1] forKeyPath:kp[0]];
    }
    return params;
}

@end