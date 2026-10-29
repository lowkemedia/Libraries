//
//  LanguagePreference - Lowke Media General utilities
//  Copyright (c) 2026 Lowke Media
//  https://github.com/lowkemedia/Libraries
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#include <stdlib.h>
#include <string.h>

// Shared by iOS and tvOS. Read the preferences visible to this process rather
// than the bundle's supported localizations or the user's region/formatting locale.
// Ownership crosses the ABI explicitly: every non-null result must be freed below.
extern "C" char* LowkeLanguagePreference_CopyLanguages()
{
    @autoreleasepool {
        NSString* languages = [[NSLocale preferredLanguages] componentsJoinedByString:@"\n"];
        const char* utf8 = [languages UTF8String];
        return utf8 == nullptr ? nullptr : strdup(utf8);
    }
}

extern "C" void LowkeLanguagePreference_FreeLanguages(char* languages)
{
    free(languages);
}
