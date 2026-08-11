//
//  NoaFixedSizeRightView.m
//  NoaChatKit
//
//  Created by phl on 2025/11/7.
//

#import "NoaFixedSizeRightView.h"

@implementation NoaFixedSizeRightView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (CGSizeEqualToSize(self.fixedSize, CGSizeZero) && !CGRectIsEmpty(frame)) {
            self.fixedSize = frame.size;
        }
    }
    return self;
}

- (instancetype)initWithFixedSize:(CGSize)size {
    self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    if (self) {
        self.fixedSize = size;
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (!CGSizeEqualToSize(self.fixedSize, CGSizeZero)) {
        return self.fixedSize;
    }
    return [super sizeThatFits:size];
}

- (CGSize)intrinsicContentSize {
    if (!CGSizeEqualToSize(self.fixedSize, CGSizeZero)) {
        return self.fixedSize;
    }
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}

@end

