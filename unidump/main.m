// unidump / 2018 / Tim Clem / github.com/misterfifths
// Public Domain

#import <Foundation/Foundation.h>
#import <unicode/ustdio.h>
#import "MR5ComposedCharacterSequence.h"
#import "MR5CodePointDescriptor.h"
#import "NSString+MR5StringUtils.h"


int main(int argc, const char * argv[])
{
    @autoreleasepool {
        NSMutableArray *positionalParams = [NSProcessInfo.processInfo.arguments mutableCopy];
        [positionalParams removeObjectAtIndex:0];

        NSString *string = [positionalParams componentsJoinedByString:@" "];

        NSArray *sequences = [MR5ComposedCharacterSequence composedCharacterSequencesFromString:string];
        NSString *res = [sequences componentsJoinedByString:@"\n"];

        u_printf("%S\n", res.mr5_nullTerminatedUTF16Data.bytes);
    }

    return 0;
}
