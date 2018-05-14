// unidump / 2018 / Tim Clem / github.com/misterfifths
// Public Domain

#import <Foundation/Foundation.h>
#import <unicode/utypes.h>


typedef NSString * const MR5CodePointAliasType NS_STRING_ENUM;


NS_ASSUME_NONNULL_BEGIN


@interface MR5CodePointAlias : NSObject

@property (nonatomic, copy, readonly) NSString *value;
@property (nonatomic, copy, readonly) MR5CodePointAliasType type;

+(nullable NSArray<MR5CodePointAlias *> *)aliasesForCodePoint:(UChar32)codePoint;


-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

@end


NS_ASSUME_NONNULL_END
