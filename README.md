# unidump

Dump a ton of information about the Unicode codepoints in a string.

For example, let's try it against some of those fun new composed emoji:

```sh
$ unidump 🏃🏾‍♀️👨‍👨‍👧‍👧🇨🇭
'🏃🏾‍♀️'
Composed emoji: 'woman with medium-dark skin tone running'
[
	'🏃'
	RUNNER
	Unicode	U+1f3c3
	UTF-8	f0 9f 8f 83 
	Category	Other_Symbol (So)
	Block	Miscellaneous_Symbols_And_Pictographs (Misc_Pictographs)

	'🏾'
	EMOJI MODIFIER FITZPATRICK TYPE-5
	Unicode	U+1f3fe
	UTF-8	f0 9f 8f be 
	Category	Modifier_Symbol (Sk)
	Block	Miscellaneous_Symbols_And_Pictographs (Misc_Pictographs)

	<unprintable>
	ZERO WIDTH JOINER
	Aliases:
		ZWJ (abbreviation)
	Unicode	U+200d
	UTF-8	e2 80 8d 
	Category	Format (Cf)
	Block	General_Punctuation (Punctuation)

	'♀'
	FEMALE SIGN
	Unicode	U+2640
	UTF-8	e2 99 80 
	Category	Other_Symbol (So)
	Block	Miscellaneous_Symbols (Misc_Symbols)

	'◌️'
	VARIATION SELECTOR-16
	Aliases:
		VS16 (abbreviation)
	Unicode	U+fe0f
	UTF-8	ef b8 8f 
	Category	Nonspacing_Mark (Mn)
	Block	Variation_Selectors (VS)
	Combiner	Single
]

'👨‍👨‍👧‍👧'
Composed emoji: 'family with two fathers and two daughters'
[
	'👨'
	MAN
	Unicode	U+1f468
	UTF-8	f0 9f 91 a8 
	Category	Other_Symbol (So)
	Block	Miscellaneous_Symbols_And_Pictographs (Misc_Pictographs)

	<unprintable>
	ZERO WIDTH JOINER
	Aliases:
		ZWJ (abbreviation)
	Unicode	U+200d
	UTF-8	e2 80 8d 
	Category	Format (Cf)
	Block	General_Punctuation (Punctuation)

	'👨'
	MAN
	Unicode	U+1f468
	UTF-8	f0 9f 91 a8 
	Category	Other_Symbol (So)
	Block	Miscellaneous_Symbols_And_Pictographs (Misc_Pictographs)

	<unprintable>
	ZERO WIDTH JOINER
	Aliases:
		ZWJ (abbreviation)
	Unicode	U+200d
	UTF-8	e2 80 8d 
	Category	Format (Cf)
	Block	General_Punctuation (Punctuation)

	'👧'
	GIRL
	Unicode	U+1f467
	UTF-8	f0 9f 91 a7 
	Category	Other_Symbol (So)
	Block	Miscellaneous_Symbols_And_Pictographs (Misc_Pictographs)

	<unprintable>
	ZERO WIDTH JOINER
	Aliases:
		ZWJ (abbreviation)
	Unicode	U+200d
	UTF-8	e2 80 8d 
	Category	Format (Cf)
	Block	General_Punctuation (Punctuation)

	'👧'
	GIRL
	Unicode	U+1f467
	UTF-8	f0 9f 91 a7 
	Category	Other_Symbol (So)
	Block	Miscellaneous_Symbols_And_Pictographs (Misc_Pictographs)
]

'🇨🇭'
Composed emoji: 'flag of Switzerland'
[
	'🇨'
	REGIONAL INDICATOR SYMBOL LETTER C
	Unicode	U+1f1e8
	UTF-8	f0 9f 87 a8 
	Category	Other_Symbol (So)
	Block	Enclosed_Alphanumeric_Supplement (Enclosed_Alphanum_Sup)

	'🇭'
	REGIONAL INDICATOR SYMBOL LETTER H
	Unicode	U+1f1ed
	UTF-8	f0 9f 87 ad 
	Category	Other_Symbol (So)
	Block	Enclosed_Alphanumeric_Supplement (Enclosed_Alphanum_Sup)
]

```


Or, against a recent [iOS/OSX crashing string](https://manishearth.github.io/blog/2018/02/15/picking-apart-the-crashing-ios-string/):

```sh
$ unidump జ్ఞ‌ా
'జ్ఞ'
[
	'జ'
	TELUGU LETTER JA
	Unicode	U+0c1c
	UTF-8	e0 b0 9c 
	Category	Other_Letter (Lo)
	Block	Telugu
	Script	Telugu

	'◌్'
	TELUGU SIGN VIRAMA
	Unicode	U+0c4d
	UTF-8	e0 b1 8d 
	Category	Nonspacing_Mark (Mn)
	Block	Telugu
	Script	Telugu
	Combiner	Single

	'ఞ'
	TELUGU LETTER NYA
	Unicode	U+0c1e
	UTF-8	e0 b0 9e 
	Category	Other_Letter (Lo)
	Block	Telugu
	Script	Telugu
]

'‌ా'
[
	<unprintable>
	ZERO WIDTH NON-JOINER
	Aliases:
		ZWNJ (abbreviation)
	Unicode	U+200c
	UTF-8	e2 80 8c 
	Category	Format (Cf)
	Block	General_Punctuation (Punctuation)

	'◌ా'
	TELUGU VOWEL SIGN AA
	Unicode	U+0c3e
	UTF-8	e0 b0 be 
	Category	Nonspacing_Mark (Mn)
	Block	Telugu
	Script	Telugu
	Combiner	Single
]
```


## Building

Uses a private OSX framework for emoji data. Tested on 10.13; no promises elsewhere.

Requires `icu4c`. Install with [Homebrew](http://brew.sh): `brew install icu4c`.

To build:

- Clone
- Run `fetch-unicode-data` to download needed data files from [unicode.org](http://unicode.org).
- Run `generateNameMaps.py` to process the Obj-C templates.
- Open the project and build in Xcode.
