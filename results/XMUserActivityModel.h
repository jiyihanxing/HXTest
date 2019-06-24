#import "XMBaseModel.h"

@interface XMUserActivityModel : XMBaseModel
@property (nonatomic, copy) NSString *linkUrl;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *activityId;
@property (nonatomic, strong) NSNumber *height;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, strong) NSNumber *width;
@end
