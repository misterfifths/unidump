// unidump / 2018 / Tim Clem / github.com/misterfifths
// Public Domain

#import <Foundation/Foundation.h>
#import <unicode/utypes.h>

@class MR5CodePointDescriptor;


NS_ASSUME_NONNULL_BEGIN


extern NSString * const MR5DefaultCombiningCharacterIsolator;


@interface MR5ComposedCharacterSequence : NSObject

@property (nonatomic, strong, readonly) NSArray<MR5ComposedCharacterSequence *> *subsequences;

@property (nonatomic, copy, readonly) NSString *string;
@property (nonatomic, readonly) NSUInteger codePointCount;
@property (nonatomic, strong, readonly) NSArray<MR5CodePointDescriptor *> *codePointDescriptors;

@property (nonatomic, copy, readonly, nullable) NSString *sequenceName;

@property (nonatomic, readonly) BOOL isSingleEmoji;
@property (nonatomic, copy, readonly, nullable) NSString *localizedEmojiName;
-(nullable NSString *)emojiNameWithLocale:(NSLocale *)locale;

-(NSString *)stringByIsolatingLeadingAndTrailingCombiningCharactersWithString:(NSString *)isolator;

+(NSArray<MR5ComposedCharacterSequence *> *)composedCharacterSequencesFromString:(NSString *)string;

+(instancetype)composedCharacterSequenceWithString:(NSString *)string;
+(instancetype)composedCharacterSequenceWithCodePoint:(UChar32)codePoint;


+(instancetype)new NS_UNAVAILABLE;
-(instancetype)init NS_UNAVAILABLE;

@end


NS_ASSUME_NONNULL_END
