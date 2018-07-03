// unidump / 2018 / Tim Clem / github.com/misterfifths
// Public Domain

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


@interface MR5InfoTidbit : NSObject

@property (nullable, nonatomic, copy, readonly) NSString *label;
@property (nonatomic, copy, readonly) NSString *value;

@property (nonatomic) BOOL indentChildren;

@property (nonatomic, readonly) NSArray<MR5InfoTidbit *> *children;
-(void)addChild:(MR5InfoTidbit *)child;
-(void)addChildWithLabel:(nullable NSString *)label value:(NSString *)value;
-(void)addChildWithValue:(NSString *)value;

@property (nonatomic, readonly) NSString *formattedString;
+(NSString *)formattedStringForTidbits:(NSArray<MR5InfoTidbit *> *)tidbits;


+(instancetype)tidbitWithLabel:(nullable NSString *)label value:(NSString *)value;
+(instancetype)tidbitWithValue:(NSString *)value;

-(instancetype)initWithLabel:(nullable NSString *)label value:(NSString *)value;


-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

@end


NS_ASSUME_NONNULL_END
