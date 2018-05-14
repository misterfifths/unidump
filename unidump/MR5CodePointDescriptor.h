// unidump / 2018 / Tim Clem / github.com/misterfifths
// Public Domain

#import <Foundation/Foundation.h>
#import <unicode/utypes.h>

@class MR5CodePointAlias;


NS_ASSUME_NONNULL_BEGIN


extern NSString * const MR5DefaultCombiningCharacterIsolator;


typedef NS_ENUM(NSUInteger, MR5CombinerType) {
    MR5CombinerTypeNoncombiner,
    MR5CombinerTypeSingle,
    MR5CombinerTypeDouble,
};


@interface MR5CodePointDescriptor : NSObject

@property (nonatomic, readonly) UChar32 codePoint;
@property (nonatomic, copy, readonly) NSString *formattedCodePoint;  // U+%04x

@property (nonatomic, copy, readonly) NSString *string;

@property (nonatomic, readonly) BOOL isPrintable;

@property (nonatomic, readonly) MR5CombinerType combinerType;
-(NSString *)stringByIsolatingCombinerWithString:(NSString *)isolator;

@property (nonatomic, copy, readonly, nullable) NSString *name;
@property (nonatomic, strong, readonly, nullable) NSArray<MR5CodePointAlias *> *aliases;

@property (nonatomic, copy, readonly) NSString *scriptName;

@property (nonatomic, copy, readonly) NSString *longGeneralCategoryName;
@property (nonatomic, copy, readonly) NSString *shortGeneralCategoryName;

@property (nonatomic, copy, readonly) NSString *shortBlockName;
@property (nonatomic, copy, readonly) NSString *longBlockName;

+(instancetype)codePointDescriptorWithCodePoint:(UChar32)codePoint;


+(instancetype)new NS_UNAVAILABLE;
-(instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
