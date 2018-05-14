// unidump / 2018 / Tim Clem / github.com/misterfifths
// Public Domain

#import "MR5CodePointAlias.h"
#import "MR5CodePointAliasData.h"


@interface MR5CodePointAlias ()

@property (nonatomic, copy, readwrite) NSString *value;
@property (nonatomic, copy, readwrite) MR5CodePointAliasType type;

@end


@implementation MR5CodePointAlias

+(NSArray<MR5CodePointAlias *> *)aliasesForCodePoint:(UChar32)codePoint
{
    static NSMutableDictionary *cache;  // @(codePoint) -> Array or NSNull (meaning we know this is a miss)
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [NSMutableDictionary new];
    });

    id cachedAliases = cache[@(codePoint)];
    if(cachedAliases) {
        if(cachedAliases == [NSNull null]) return nil;
        return cachedAliases;
    }


    MR5CodePointAliases *aliasesStruct = MR5AliasesForCodePoint(codePoint);

    if(!aliasesStruct) {
        cache[@(codePoint)] = [NSNull null];
        return nil;
    }

    NSMutableArray *res = [NSMutableArray arrayWithCapacity:aliasesStruct->aliasCount];
    for(size_t i = 0; i < aliasesStruct->aliasCount; i++) {
        MR5CodePointSingleAlias aliasStruct = aliasesStruct->aliases[i];
        MR5CodePointAlias *alias = [MR5CodePointAlias aliasWithValue:aliasStruct.value type:aliasStruct.type];
        [res addObject:alias];
    }

    cache[@(codePoint)] = res;

    return res;
}

+(instancetype)aliasWithValue:(NSString *)value type:(MR5CodePointAliasType)type
{
    MR5CodePointAlias *alias = [[self alloc] init];
    alias.value = value;
    alias.type = type;
    return alias;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%@)", self.value, self.type];
}

@end
