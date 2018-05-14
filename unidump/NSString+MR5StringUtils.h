// unidump / 2018 / Tim Clem / github.com/misterfifths
// Public Domain

#import <Foundation/Foundation.h>
#import <unicode/utypes.h>

@class MR5ComposedCharacterSequence;
@class MR5CodePointDescriptor;


NS_ASSUME_NONNULL_BEGIN


@interface NSString (MR5StringUtils)

@property (nonatomic, copy, readonly) NSArray<MR5ComposedCharacterSequence *> *mr5_composedCharacterSequences;
@property (nonatomic, copy, readonly) NSArray<MR5CodePointDescriptor *> *mr5_codePointDescriptors;
-(void)mr5_enumerateCodePoints:(void (^)(NSUInteger codePointIndex, UChar32 codePoint, BOOL *stop))block;

@property (nonatomic, readonly) NSUInteger mr5_codePointCount;

@property (nonatomic, copy, readonly) NSData *mr5_nullTerminatedUTF16Data;

@property (nonatomic, copy, readonly) NSString *mr5_formattedUTF8Representation;  // fe 01 a0, e.g.

@property (nonatomic, copy, readonly) NSString *mr5_indentedString;  // indents every line by a tab. Trailing newlines stripped

+(instancetype)mr5_stringWithCodePoint:(UChar32)codePoint;

@end


NS_ASSUME_NONNULL_END
