// unidump / 2018 / Tim Clem / github.com/misterfifths
// Public Domain

#import "NSString+MR5StringUtils.h"
#import "MR5ComposedCharacterSequence.h"
#import "MR5CodePointDescriptor.h"


@implementation NSString (MR5StringUtils)

-(NSArray<MR5ComposedCharacterSequence *> *)mr5_composedCharacterSequences
{
    return [MR5ComposedCharacterSequence composedCharacterSequencesFromString:self];
}

-(NSArray<MR5CodePointDescriptor *> *)mr5_codePointDescriptors
{
    NSMutableArray *res = [NSMutableArray new];
    [self mr5_enumerateCodePoints:^(NSUInteger codePointIndex, UChar32 codePoint, BOOL *stop) {
        MR5CodePointDescriptor *descriptor = [MR5CodePointDescriptor codePointDescriptorWithCodePoint:codePoint];
        [res addObject:descriptor];
    }];

    return res;
}

-(void)mr5_enumerateCodePoints:(void (^)(NSUInteger, UChar32, BOOL *))block
{
    NSData *utf32Data = [self dataUsingEncoding:NSUTF32LittleEndianStringEncoding];
    UChar32 c;

    NSUInteger i = 0;
    BOOL shouldStop = NO;
    for(NSUInteger charOffset = 0; charOffset <= utf32Data.length - 4; charOffset += 4) {
        [utf32Data getBytes:&c range:NSMakeRange(charOffset, 4)];

        block(i, c, &shouldStop);
        if(shouldStop) break;
        i++;
    }
}

-(NSUInteger)mr5_codePointCount
{
    return [self lengthOfBytesUsingEncoding:NSUTF32LittleEndianStringEncoding] / 4;
}

-(NSData *)mr5_nullTerminatedUTF16Data
{
    NSMutableData *d = [[self dataUsingEncoding:NSUTF16LittleEndianStringEncoding] mutableCopy];

    UChar32 zero = 0;
    [d appendBytes:&zero length:sizeof(zero)];
    return d;
}

-(NSString *)mr5_formattedUTF8Representation
{
    NSMutableString *res = [NSMutableString new];
    NSData *utf8Data = [self dataUsingEncoding:NSUTF8StringEncoding];
    for(NSUInteger i = 0; i < utf8Data.length; i++) {
        [res appendFormat:@"%02x ", ((const char *)utf8Data.bytes)[i] & 0xff];
    }

    return res;
}

-(NSString *)mr5_indentedString
{
    NSMutableString *res = [NSMutableString new];

    [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByLines usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        [res appendFormat:@"\t%@", substring];

        if(NSMaxRange(enclosingRange) != self.length)
            [res appendString:@"\n"];
    }];

    return res;
}

+(instancetype)mr5_stringWithCodePoint:(UChar32)codePoint
{
    UChar32 swappedCodePoint = NSSwapHostIntToLittle(codePoint);
    return [[NSString alloc] initWithBytes:&swappedCodePoint length:4 encoding:NSUTF32LittleEndianStringEncoding];
}

@end
