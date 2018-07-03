#!/usr/bin/env python3

import sys
import os
from collections import defaultdict, namedtuple


Alias = namedtuple('Alias', 'value aliasType')


def filenameRelativeToSelf(filename):
    argv0 = os.path.abspath(sys.argv[0])
    pwd = os.path.dirname(argv0)
    return os.path.join(pwd, filename);

def _processDataFile(filename, lineComponentsHandler):
    for line in open(filename, 'r'):
        line = line.strip()

        if line.startswith('#'): continue
        if len(line) == 0: continue

        lineComponentsHandler(*line.split(';'))

def getAliasesByCodePoint(filename):
    aliasesByCodePoint = defaultdict(list)

    def lineComponentsHandler(codePoint, value, aliasType):
        codePoint = int(codePoint, 16)
        aliasesByCodePoint[codePoint].append(Alias(value, aliasType))

    _processDataFile(filename, lineComponentsHandler)

    return aliasesByCodePoint

def aliasesFilesFromAliases(aliasesByCodePoint, headerTemplateFilename, impTemplateFilename):
    ALIAS_TYPE_NAME_TYPEDEF = 'MR5CodePointAliasType'
    ALIAS_TYPE_NAME_EXTERNS_TOKEN = '<ALIAS TYPE NAME EXTERNS>'
    ALIAS_TYPE_NAME_VALUES_TOKEN = '<ALIAS TYPE NAME VALUES>'
    MAX_PER_CODE_POINT_ALIAS_COUNT_TOKEN = '<MAX PER CODE POINT ALIAS COUNT>'
    CODE_POINT_COUNT_TOKEN = '<CODE POINT COUNT>'
    ALIAS_STRUCTS_TOKEN = '<ALIAS STRUCTS>'

    # { 0x00, 2, {
    #     { "null", "control" },
    #     { "nul", "abbreviation" }
    # } }

    rawAliasTypeNames = set()
    maxPerCodePointAliasCount = 0
    codePointCount = len(aliasesByCodePoint)
    aliasStructStrings = []

    sortedAliasItems = sorted(aliasesByCodePoint.items(), key=lambda item: item[0])
    for codePoint, aliases in sortedAliasItems:
        structString = f'\t{{ 0x{codePoint:04x}, {len(aliases)}, {{'

        maxPerCodePointAliasCount = max(maxPerCodePointAliasCount, len(aliases))
        for alias in aliases:
            rawAliasTypeNames.add(alias.aliasType)

            structString += f'\n\t\t{{ @"{alias.value}", @"{alias.aliasType}" }},'
        
        structString += '\n\t} }'

        aliasStructStrings.append(structString)
    
    aliasStructs = ',\n'.join(aliasStructStrings)

    sortedAliasTypeNames = sorted(rawAliasTypeNames)
    aliasTypeNameExterns = ''
    aliasTypeNameValues = ''
    for aliasType in sortedAliasTypeNames:
        aliasConstantName = f'{ALIAS_TYPE_NAME_TYPEDEF}{aliasType.title()}'
        aliasTypeNameExterns += f'\nextern {ALIAS_TYPE_NAME_TYPEDEF} {aliasConstantName};'
        aliasTypeNameValues += f'\n{ALIAS_TYPE_NAME_TYPEDEF} {aliasConstantName} = @"{aliasType}";'


    def doReplacements(s):
        s = s.replace(ALIAS_TYPE_NAME_EXTERNS_TOKEN, aliasTypeNameExterns)
        s = s.replace(ALIAS_TYPE_NAME_VALUES_TOKEN, aliasTypeNameValues)
        s = s.replace(MAX_PER_CODE_POINT_ALIAS_COUNT_TOKEN, str(maxPerCodePointAliasCount))
        s = s.replace(CODE_POINT_COUNT_TOKEN, str(codePointCount))
        s = s.replace(ALIAS_STRUCTS_TOKEN, aliasStructs)
        return s
        

    with open(headerTemplateFilename) as f:
        header = f.read()
    
    with open(impTemplateFilename) as f:
        imp = f.read()
    
    return doReplacements(header), doReplacements(imp)


TEMPLATE_FILE_SUFFIX = '.template'

def processAliases():
    ALIASES_DATA_FILENAME = 'NameAliases.txt'
    ALIAS_HEADER_FILENAME = 'MR5CodePointAliasData.h'
    ALIAS_IMP_FILENAME = 'MR5CodePointAliasData.m'

    nameAliasesFile = filenameRelativeToSelf(ALIASES_DATA_FILENAME)
    aliasesByCodePoint = getAliasesByCodePoint(nameAliasesFile)

    headerTemplateFilename = filenameRelativeToSelf(ALIAS_HEADER_FILENAME + TEMPLATE_FILE_SUFFIX)
    impTemplateFilename = filenameRelativeToSelf(ALIAS_IMP_FILENAME + TEMPLATE_FILE_SUFFIX)
    hContents, mContents = aliasesFilesFromAliases(aliasesByCodePoint, headerTemplateFilename, impTemplateFilename)

    headerFilename = filenameRelativeToSelf(ALIAS_HEADER_FILENAME)
    impFilename = filenameRelativeToSelf(ALIAS_IMP_FILENAME)

    with open(headerFilename, 'w') as f:
        f.write(hContents)
    
    with open(impFilename, 'w') as f:
        f.write(mContents)


NamedSequence = namedtuple('NamedSequence', 'name codePoints')

def paddedList(l, length, filler):
    neededPadding = length - len(l)
    if neededPadding <= 0: return l
    
    padded = l.copy()
    padding = [filler] * neededPadding
    padded.extend(padding)
    return padded

def namedSequencesFromFile(filename):
    namedSequences = []

    def lineComponentsHandler(name, codePointsString):
        codePoints = [int(s, base=16) for s in codePointsString.strip().split(' ')]
        namedSequences.append(NamedSequence(name, codePoints))
    
    _processDataFile(filename, lineComponentsHandler)

    # If you return an array as the key to sort() or sorted(), python steps
    # down the elements and sorts by one after the other.
    # We do need to pad with zeros up to the maximum codepoint length, though;
    # otherwise it sorts shorter lists first
    maxCodePointLength = max(map(lambda s: len(s.codePoints), namedSequences))
    namedSequences.sort(key=lambda s: paddedList(s.codePoints, maxCodePointLength, 0))

    return namedSequences

def escapedCodePoint(codePoint):
    if codePoint > 0xffff:
        return f'\\x{codePoint:08x}'

    return f'\\x{codePoint:04x}'

def sequenceFilesFromSequences(namedSequences, headerTemplateFilename, impTemplateFilename):
    NAMED_SEQUENCE_ENTRIES_TOKEN = '<NAMED SEQUENCE ENTRIES>'

    namedSequenceEntryStrings = []

    for namedSequence in namedSequences:
        sequenceString = ''
        for codePoint in namedSequence.codePoints:
            if codePoint <= 127:
                # ASCII codepoints aren't representable by the \U syntax for some reason
                sequenceString += chr(codePoint)
            else:
                sequenceString += f'\\U{codePoint:08x}'

        entryString = f'\t\t@"{sequenceString}": @"{namedSequence.name}"'

        namedSequenceEntryStrings.append(entryString)
    
    namedSequenceEntryString = ',\n'.join(namedSequenceEntryStrings)


    def doReplacements(s):
        s = s.replace(NAMED_SEQUENCE_ENTRIES_TOKEN, namedSequenceEntryString)
        return s


    with open(headerTemplateFilename) as f:
        header = f.read()
    
    with open(impTemplateFilename) as f:
        imp = f.read()
    
    return doReplacements(header), doReplacements(imp)
    


def processSequences():
    SEQUENCE_DATA_FILENAME = 'NamedSequences.txt'
    SEQUENCE_HEADER_FILENAME = 'MR5SequenceNameData.h'
    SEQUENCE_IMP_FILENAME = 'MR5SequenceNameData.m'

    sequenceDataFile = filenameRelativeToSelf(SEQUENCE_DATA_FILENAME)
    namedSequences = namedSequencesFromFile(sequenceDataFile)

    headerTemplateFilename = filenameRelativeToSelf(SEQUENCE_HEADER_FILENAME + TEMPLATE_FILE_SUFFIX)
    impTemplateFilename = filenameRelativeToSelf(SEQUENCE_IMP_FILENAME + TEMPLATE_FILE_SUFFIX)
    hContents, mContents = sequenceFilesFromSequences(namedSequences, headerTemplateFilename, impTemplateFilename)

    headerFilename = filenameRelativeToSelf(SEQUENCE_HEADER_FILENAME)
    impFilename = filenameRelativeToSelf(SEQUENCE_IMP_FILENAME)

    with open(headerFilename, 'w') as f:
        f.write(hContents)
    
    with open(impFilename, 'w') as f:
        f.write(mContents)

    

if __name__ == '__main__':
    processAliases()
    processSequences()
