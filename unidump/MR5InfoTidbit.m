// unidump / 2018 / Tim Clem / github.com/misterfifths
// Public Domain

#import "MR5InfoTidbit.h"


@interface MR5InfoTidbit ()

@property (nullable, nonatomic, copy, readwrite) NSString *label;
@property (nonatomic, copy, readwrite) NSString *value;

@property (nullable, nonatomic) NSMutableArray<MR5InfoTidbit *> *mutableChildren;
@property (nonatomic) NSUInteger longestChildLabelLength;

@end


@implementation MR5InfoTidbit

+(instancetype)tidbitWithLabel:(NSString *)label value:(NSString *)value
{
    return [[MR5InfoTidbit alloc] initWithLabel:label value:value];;
}

+(instancetype)tidbitWithValue:(NSString *)value
{
    return [self tidbitWithLabel:nil value:value];
}

-(instancetype)initWithLabel:(NSString *)label value:(NSString *)value
{
    self = [super init];
    if(self) {
        _mutableChildren = [NSMutableArray new];
        _label = [label copy];
        _value = [value copy];
    }

    return self;
}

-(NSArray<MR5InfoTidbit *> *)children
{
    return self.mutableChildren;
}

-(void)addChild:(MR5InfoTidbit *)child
{
    [self.mutableChildren addObject:child];

    NSUInteger labelLength = child.label.length;
    if(labelLength > self.longestChildLabelLength) {
        self.longestChildLabelLength = labelLength;
    }
}

-(void)addChildWithLabel:(NSString *)label value:(NSString *)value
{
    [self addChild:[[self class] tidbitWithLabel:label value:value]];
}

-(void)addChildWithValue:(NSString *)value
{
    [self addChildWithLabel:nil value:value];
}

-(NSString *)formattedString
{
    return [self formattedStringWithLabelWidth:0];
}

-(NSString *)formattedStringWithLabelWidth:(NSUInteger)labelWidth
{
    return [self formattedStringWithLabelWidth:labelWidth indent:@""];
}

-(NSString *)formattedStringWithLabelWidth:(NSUInteger)labelWidth indent:(NSString *)indent
{
    NSMutableString *res = [NSMutableString new];
    if(self.label.length == 0) {
        [res appendFormat:@"%@%@", indent, self.value];
    }
    else {
        NSString *paddedLabel;

        if(self.label.length > labelWidth) paddedLabel = self.label;
        else paddedLabel = [self.label stringByPaddingToLength:labelWidth withString:@" " startingAtIndex:0];

        [res appendFormat:@"%@%@  %@", indent, paddedLabel, self.value];
    }

    NSString *childIndentation = indent;
    if(self.indentChildren)
        childIndentation = [NSString stringWithFormat:@"  %@", indent];

    for(MR5InfoTidbit *child in self.children) {
        NSString *childString = [child formattedStringWithLabelWidth:self.longestChildLabelLength
                                                              indent:childIndentation];
        [res appendFormat:@"\n%@", childString];
    }

    return res;
}

+(NSString *)formattedStringForTidbits:(NSArray<MR5InfoTidbit *> *)tidbits
{
    NSMutableString *res = [NSMutableString new];

    BOOL first = YES;
    for(MR5InfoTidbit *tidbit in tidbits) {
        if(!first) [res appendString:@"\n"];
        else first = NO;

        [res appendString:tidbit.formattedString];
    }

    return res;
}

-(NSString *)description
{
    return self.formattedString;
}

@end
