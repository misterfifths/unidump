// unidump / 2018 / Tim Clem / github.com/misterfifths
// Public Domain

#import "MR5ComposedCharacterSequence.h"
#import "MR5SequenceNameData.h"
#import "MR5CodePointDescriptor.h"
#import "NSString+MR5StringUtils.h"
#import "EMFEmojiToken.h"


@interface MR5ComposedCharacterSequence ()

@property (nonatomic, strong) NSMutableArray<MR5ComposedCharacterSequence *> *mutableSubsequences;
@property (nonatomic, strong, readwrite) NSArray<MR5CodePointDescriptor *> *codePointDescriptors;

@property (nonatomic, copy, readwrite) NSString *string;

@end


@implementation MR5ComposedCharacterSequence

+(NSArray<MR5ComposedCharacterSequence *> *)composedCharacterSequencesFromString:(NSString *)string
{
    NSMutableArray *res = [NSMutableArray new];

    __block MR5ComposedCharacterSequence *previousSequence = nil;
    __block NSRange previousSubstringRange = NSMakeRange(NSNotFound, 0);

    [string enumerateSubstringsInRange:NSMakeRange(0, string.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
    {
        NSRange rangeIntersection = NSIntersectionRange(substringRange, previousSubstringRange);
        if(res.count > 0 && rangeIntersection.length != 0) {
            // blammo... nested sequences

            // make a new CCS that covers the union of the ranges
            // make another new CCS that covers just the unique characters in this new substring
            // the subsequences of the union sequence are [oldSequence, newSequence]

            NSRange unionedRange = NSUnionRange(previousSubstringRange, substringRange);

            NSString *unionedSubstring = [string substringWithRange:unionedRange];
            MR5ComposedCharacterSequence *unionedSequence = [MR5ComposedCharacterSequence composedCharacterSequenceWithStringNoAutoSubsequences:unionedSubstring];

            MR5ComposedCharacterSequence *oldSequence = previousSequence;
            NSString *uniquePartOfNewSubstring = [substring substringFromIndex:rangeIntersection.length];
            MR5ComposedCharacterSequence *newSequence = [MR5ComposedCharacterSequence composedCharacterSequenceWithString:uniquePartOfNewSubstring];

            [unionedSequence.mutableSubsequences addObject:oldSequence];
            [unionedSequence.mutableSubsequences addObject:newSequence];

            [res replaceObjectAtIndex:res.count - 1 withObject:unionedSequence];

            previousSequence = unionedSequence;
            previousSubstringRange = unionedRange;
        }
        else {
            // distinct sequence
            MR5ComposedCharacterSequence *sequence = [self composedCharacterSequenceWithString:substring];

            [res addObject:sequence];
            previousSubstringRange = substringRange;
            previousSequence = sequence;
        }
    }];

    return res;
}

+(instancetype)composedCharacterSequenceWithStringNoAutoSubsequences:(NSString *)string
{
    MR5ComposedCharacterSequence *sequence = [[self alloc] init];
    sequence.string = string;

    sequence.codePointDescriptors = string.mr5_codePointDescriptors;

    sequence.mutableSubsequences = [NSMutableArray new];

    return sequence;
}

+(instancetype)composedCharacterSequenceWithString:(NSString *)string
{
    MR5ComposedCharacterSequence *sequence = [self composedCharacterSequenceWithStringNoAutoSubsequences:string];

    for(MR5CodePointDescriptor *descriptor in sequence.codePointDescriptors) {
        MR5ComposedCharacterSequence *subsequence = [MR5ComposedCharacterSequence composedCharacterSequenceWithCodePointDescriptor:descriptor];
        [sequence.mutableSubsequences addObject:subsequence];
    }

    return sequence;
}

+(instancetype)composedCharacterSequenceWithCodePointDescriptor:(MR5CodePointDescriptor *)descriptor
{
    MR5ComposedCharacterSequence *sequence = [[self alloc] init];
    sequence.string = descriptor.string;
    sequence.codePointDescriptors = @[descriptor];
    sequence.mutableSubsequences = [NSMutableArray new];
    return sequence;
}

+(instancetype)composedCharacterSequenceWithCodePoint:(UChar32)codePoint
{
    return [self composedCharacterSequenceWithString:[NSString mr5_stringWithCodePoint:codePoint]];
}

-(NSArray<MR5ComposedCharacterSequence *> *)subsequences
{
    return self.mutableSubsequences;
}

-(NSUInteger)codePointCount
{
    return self.codePointDescriptors.count;
}


#pragma mark Combiner stuff

-(NSString *)stringByIsolatingLeadingAndTrailingCombiningCharactersWithString:(NSString *)isolator
{
    if(self.string.length == 0) return self.string;

    NSArray<MR5CodePointDescriptor *> *codePointDescriptors = self.codePointDescriptors;
    if(codePointDescriptors.count == 1)
        return [codePointDescriptors[0] stringByIsolatingCombinerWithString:isolator];

    NSMutableString *res = [self.string mutableCopy];

    // prepend an isolator if the first character is a dangling single or double combiner
    MR5CodePointDescriptor *firstDescriptor = codePointDescriptors[0];
    if(firstDescriptor.combinerType != MR5CombinerTypeNoncombiner)
        [res insertString:isolator atIndex:0];

    // Have to append an isolator if the final character is a dangling double combiner
    MR5CodePointDescriptor *lastDescriptor = codePointDescriptors.lastObject;
    if(lastDescriptor.combinerType == MR5CombinerTypeDouble)
        [res appendString:isolator];

    return res;
}


#pragma mark Emoji & name stuff

-(NSString *)sequenceName
{
    return MR5NameForSequence(self.string);
}

-(BOOL)isSingleEmoji
{
    return self.string._isSingleEmoji;
}

-(NSString *)localizedEmojiName
{
    return [self emojiNameWithLocale:[NSLocale currentLocale]];
}

-(NSString *)emojiNameWithLocale:(NSLocale *)locale
{
    if(!self.isSingleEmoji) return nil;

    EMFEmojiLocaleData *emojiLocaleData = [EMFEmojiLocaleData emojiLocaleDataWithLocaleIdentifier:locale.localeIdentifier];

    EMFEmojiToken *emojiToken = [EMFEmojiToken emojiTokenWithString:self.string localeData:emojiLocaleData];
    return [emojiToken nameForType:EMFEmojiTokenNameTypeVoiceover];
}


#pragma mark Builtins

-(NSString *)singleDescription
{
    if(self.codePointCount == 1)
        return [self.codePointDescriptors.firstObject description];

    NSMutableString *res = [NSMutableString new];
    [res appendFormat:@"'%@'", [self stringByIsolatingLeadingAndTrailingCombiningCharactersWithString:MR5DefaultCombiningCharacterIsolator]];

    [res appendString:@"\n"];

    NSString *sequenceName = self.sequenceName;
    if(sequenceName) {
        [res appendString:sequenceName];

        [res appendString:@"\n"];
    }
    else if(self.isSingleEmoji) {
        [res appendFormat:@"Composed emoji: '%@'", self.localizedEmojiName];

        [res appendString:@"\n"];
    }

    [res appendString:@"[\n"];

    for(NSUInteger i = 0; i < self.subsequences.count; i++) {
        MR5ComposedCharacterSequence *subsequence = self.subsequences[i];
        NSString *description = [subsequence singleDescription];
        [res appendString:description.mr5_indentedString];

        if(i != self.subsequences.count - 1)
            [res appendString:@"\n\n"];
    }

    [res appendString:@"\n]"];

    return res;
}

-(NSString *)description
{
    return [self singleDescription];
}

@end
