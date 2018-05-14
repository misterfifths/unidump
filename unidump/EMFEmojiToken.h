// unidump / 2018 / Tim Clem / github.com/misterfifths
// Public Domain

// Bits of the private framework EmojiFoundation.

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, EMFEmojiTokenNameType) {
    EMFEmojiTokenNameTypeUnknown = 0,
    EMFEmojiTokenNameTypeVoiceover = 1,  // includes skin tone information
    EMFEmojiTokenNameTypeApple = 2       // just describes the emoji without modifiers
};


@interface NSString (EMFEmojiExtras)

@property (nonatomic, readonly) BOOL _isSingleEmoji;

@end


@interface EMFEmojiLocaleData

+(nullable instancetype)emojiLocaleDataWithLocaleIdentifier:(NSString *)localeIdentifier;


-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

@end


@interface EMFEmojiToken : NSObject

@property(copy, nonatomic) NSString *string;
-(NSString *)nameForType:(EMFEmojiTokenNameType)nameType;

+(nullable instancetype)emojiTokenWithString:(NSString *)string localeData:(EMFEmojiLocaleData *)localeData;


-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

@end


NS_ASSUME_NONNULL_END
