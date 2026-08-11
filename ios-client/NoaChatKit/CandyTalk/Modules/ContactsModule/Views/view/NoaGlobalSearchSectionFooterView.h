//
//  NoaGlobalSearchSectionFooterView.h
//  NoaKit
//
//  Created by Candy on 2026/9/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ZGlobalSearchSectinFooterViewDelegate <NSObject>
- (void)sectionFooterShowMore:(NSInteger)footerSection;
@end

@interface NoaGlobalSearchSectionFooterView : UITableViewHeaderFooterView
@property (nonatomic, assign) NSInteger footerSection;
@property (nonatomic, weak) id <ZGlobalSearchSectinFooterViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
