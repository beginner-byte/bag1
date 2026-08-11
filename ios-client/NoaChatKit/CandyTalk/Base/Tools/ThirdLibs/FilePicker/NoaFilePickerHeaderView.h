//
//  NoaFilePickerHeaderView.h
//  NoaKit
//
//  Created by Candy on 2023/1/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaFilePickerHeaderView : UITableViewHeaderFooterView

@property (nonatomic, copy)NSString *contentStr;
@property (nonatomic, assign)BOOL unFlod;
@property (nonatomic, copy) void(^ZFileHeaderClick)(void);

@end

NS_ASSUME_NONNULL_END
