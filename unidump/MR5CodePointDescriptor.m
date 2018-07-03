// unidump / 2018 / Tim Clem / github.com/misterfifths
// Public Domain

#import "MR5CodePointDescriptor.h"
#import "NSString+MR5StringUtils.h"
#import "MR5CodePointAlias.h"
#import "MR5InfoTidbit.h"
#import <unicode/uchar.h>
#import <unicode/uscript.h>


NSString * const MR5DefaultCombiningCharacterIsolator = @"◌";


// See http://www.unicode.org/reports/tr44/#Canonical_Combining_Class_Values
typedef enum : uint8_t {
    MR5CanonicalCombiningClassNotReordered = 0,
    MR5CanonicalCombiningClassDoubleBelow = 233,
    MR5CanonicalCombiningClassDoubleAbove = 234,
} MR5CanonicalCombiningClass;


@interface MR5CodePointDescriptor ()

@property (nonatomic, readwrite) UChar32 codePoint;

@property (nonatomic, copy, readwrite) NSString *string;

@property (nonatomic, readonly) MR5CanonicalCombiningClass canonicalCombiningClass;

@end


@implementation MR5CodePointDescriptor

+(instancetype)codePointDescriptorWithCodePoint:(UChar32)codePoint
{
    MR5CodePointDescriptor *descriptor = [[self alloc] init];
    descriptor.codePoint = codePoint;
    descriptor.string = [NSString mr5_stringWithCodePoint:codePoint];
    return descriptor;
}

-(NSString *)formattedCodePoint
{
    return [NSString stringWithFormat:@"U+%04x", self.codePoint];
}

-(BOOL)isPrintable
{
    return !u_iscntrl(self.codePoint);
}


#pragma mark Combiner stuff

-(MR5CanonicalCombiningClass)canonicalCombiningClass
{
    return u_getCombiningClass(self.codePoint);
}

-(UJoiningType)joiningType
{
    return u_getIntPropertyValue(self.codePoint, UCHAR_JOINING_TYPE);
}

-(MR5CombinerType)combinerType
{
    switch(self.canonicalCombiningClass) {
        case MR5CanonicalCombiningClassNotReordered:
            // This is not good enough, sometimes. For instance, some of the Cyrillic combiners
            // say NotReordered. Ugh. Falling back on joining type in this case, though I don't
            // know if that's accurate.
            return [self joiningType] == U_JT_TRANSPARENT ? MR5CombinerTypeSingle : MR5CombinerTypeNoncombiner;

        case MR5CanonicalCombiningClassDoubleAbove:
        case MR5CanonicalCombiningClassDoubleBelow:
            return MR5CombinerTypeDouble;

        default:
            return MR5CombinerTypeSingle;
    }
}

-(NSString *)stringByIsolatingCombinerWithString:(NSString *)isolator
{
    MR5CombinerType combinerType = self.combinerType;
    if(combinerType == MR5CombinerTypeNoncombiner) return self.string;
    if(combinerType == MR5CombinerTypeSingle) return [NSString stringWithFormat:@"%@%@", isolator, self.string];
    return [NSString stringWithFormat:@"%@%@%@", isolator, self.string, isolator];
}


#pragma mark Name stuff

-(NSString *)nameForNameChoice:(UCharNameChoice)nameChoice bufferLength:(int32_t)bufferLength nameLength:(out int32_t * __nonnull)nameLength
{
    char *buffer = malloc(bufferLength);
    UErrorCode error = 0;
    *nameLength = u_charName(self.codePoint, nameChoice, buffer, bufferLength, &error);

    if(!U_SUCCESS(error)) {
        free(buffer);
        return @"<error getting name>";
    }

    if(*nameLength == 0) {
        free(buffer);
        return nil;
    }

    NSString *name = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
    free(buffer);
    return name;
}

-(NSString *)nameForNameChoice:(UCharNameChoice)nameChoice
{
    const size_t initialBufferLength = 256;
    int32_t nameLength = 0;

    NSString *name = [self nameForNameChoice:U_UNICODE_CHAR_NAME bufferLength:initialBufferLength nameLength:&nameLength];

    if(initialBufferLength <= nameLength) {
        // buffer was too short
        name = [self nameForNameChoice:U_UNICODE_CHAR_NAME bufferLength:nameLength nameLength:&nameLength];
    }

    return name;
}

-(NSString *)name
{
    return [self nameForNameChoice:U_UNICODE_CHAR_NAME];
}

-(NSArray<MR5CodePointAlias *> *)aliases
{
    return [MR5CodePointAlias aliasesForCodePoint:self.codePoint];
}


#pragma mark Misc. string properties

-(NSString *)scriptName
{
    UErrorCode err = 0;
    UScriptCode scriptCode = uscript_getScript(self.codePoint, &err);

    if(!U_SUCCESS(err))
        return @"<error getting script>";

    const char *scriptName = uscript_getName(scriptCode);
    return [NSString stringWithCString:scriptName encoding:NSASCIIStringEncoding];
}

-(NSString *)nameForValue:(int32_t)value inEnumeration:(UProperty)enumeration short:(BOOL)shortFlag
{
    const char *name = u_getPropertyValueName(enumeration, value, shortFlag ? U_SHORT_PROPERTY_NAME : U_LONG_PROPERTY_NAME);
    return [NSString stringWithCString:name encoding:NSASCIIStringEncoding];
}

-(NSString *)valueNameForProperty:(UProperty)property short:(BOOL)shortFlag
{
    int32_t value = u_getIntPropertyValue(self.codePoint, property);
    return [self nameForValue:value inEnumeration:property short:shortFlag];
}

-(NSString *)longGeneralCategoryName
{
    return [self valueNameForProperty:UCHAR_GENERAL_CATEGORY short:NO];
}

-(NSString *)shortGeneralCategoryName
{
    return [self valueNameForProperty:UCHAR_GENERAL_CATEGORY short:YES];
}

-(NSString *)longBlockName
{
    return [self valueNameForProperty:UCHAR_BLOCK short:NO];
}

-(NSString *)shortBlockName
{
    return [self valueNameForProperty:UCHAR_BLOCK short:YES];
}


#pragma mark Builtins

-(MR5InfoTidbit *)infoTidbit
{
    NSString *printedString;
    if(self.isPrintable)
        printedString = [NSString stringWithFormat:@"'%@'", [self stringByIsolatingCombinerWithString:MR5DefaultCombiningCharacterIsolator]];
    else
        printedString = @"<unprintable>";

    MR5InfoTidbit *tidbit = [MR5InfoTidbit tidbitWithValue:printedString];


    [tidbit addChildWithValue:self.name ?: @"<no name>"];


    NSArray *aliases = self.aliases;
    if(aliases) {
        MR5InfoTidbit *aliasesTidbit = [MR5InfoTidbit tidbitWithValue:@"Aliases"];
        aliasesTidbit.indentChildren = YES;

        for(MR5CodePointAlias *alias in aliases)
            [aliasesTidbit addChildWithValue:alias.description];

        [tidbit addChild:aliasesTidbit];
    }


    [tidbit addChildWithLabel:@"Unicode" value:self.formattedCodePoint];


    [tidbit addChildWithLabel:@"UTF-8 (hex)" value:self.string.mr5_formattedUTF8Representation];


    [tidbit addChildWithLabel:@"UTF-16LE (hex)" value:self.string.mr5_formattedUTF16LERepresentation];


    if([self.longBlockName isEqualToString:@"Basic_Latin"]) {
        [tidbit addChildWithLabel:@"ASCII (dec)" value:[NSString stringWithFormat:@"%u", self.codePoint]];
    }


    NSString *categoryString = [NSString stringWithFormat:@"%@ (%@)", self.longGeneralCategoryName, self.shortGeneralCategoryName];
    [tidbit addChildWithLabel:@"Category" value:categoryString];


    NSString *longBlockName = self.longBlockName;
    NSString *shortBlockName = self.shortBlockName;
    NSString *blockString;
    if([longBlockName isEqualToString:shortBlockName])
        blockString = longBlockName;
    else
        blockString = [NSString stringWithFormat:@"%@ (%@)", longBlockName, shortBlockName];

    [tidbit addChildWithLabel:@"Block" value:blockString];


    NSString *scriptName = self.scriptName;
    if(![scriptName isEqualToString:@"Common"] && ![scriptName isEqualToString:@"Inherited"])
        [tidbit addChildWithLabel:@"Script" value:scriptName];


    MR5CombinerType combinerType = self.combinerType;
    if(combinerType != MR5CombinerTypeNoncombiner)
        [tidbit addChildWithLabel:@"Combiner" value:combinerType == MR5CombinerTypeSingle ? @"Single" : @"Double"];

    return tidbit;
}

-(NSString *)description
{
    return [self infoTidbit].formattedString;
}

@end
