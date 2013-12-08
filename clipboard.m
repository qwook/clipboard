// clipboard

// The MIT License (MIT)

// Copyright (c) 2013 Henry Tran

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#define LUA_LIB
#include "lua.h"
#include "lauxlib.h"

#import <Foundation/Foundation.h>
#import <Appkit/Appkit.h>

SInt32 MacVersion;

static int lclipboard_get(lua_State *L) {
    NSAutoreleasePool *pool;
    NSPasteboard *pasteboard;
    NSString *format;

    if (MacVersion > 0x1060) {
        format = NSPasteboardTypeString;
    } else {
        format = NSStringPboardType;
    }

    NSString *available;

    pool = [[NSAutoreleasePool alloc] init];

    pasteboard = [NSPasteboard generalPasteboard];
    available = [pasteboard availableTypeFromArray: [NSArray arrayWithObject:format]];
    if ([available isEqualToString:format]) {
        NSString* string;
        const char *utf8;

        string = [pasteboard stringForType:format];
        if (string == nil) {
            utf8 = "";
        } else {
            utf8 = [string UTF8String];
        }
        lua_pushstring(L, utf8);
    } else {
        lua_pushstring(L, "");
    }

    [pool release];

    return 1;
}

static int lclipboard_set(lua_State *L) {
    const char *text = luaL_checklstring(L, 1, NULL);

    NSAutoreleasePool *pool;
    NSPasteboard *pasteboard;
    NSString *format;

    if (MacVersion < 0x1060) {
        format = NSPasteboardTypeString;
    } else {
        format = NSStringPboardType;
    }

    pool = [[NSAutoreleasePool alloc] init];
    pasteboard = [NSPasteboard generalPasteboard];

    [pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [pasteboard setString:[NSString stringWithUTF8String:text] forType:NSStringPboardType];

    [pool release];
    return 0;
}

static int lclipboard_newindex(lua_State *L) {
    lua_pushliteral(L, "attempt to change readonly table");
    lua_error(L);
    return 0;
}

static const luaL_Reg clipboardlib[] = {
    {"get",         lclipboard_get},
    {"set",         lclipboard_set},

    {"__newindex",      lclipboard_newindex},
    {NULL, NULL}
};


LUALIB_API int luaopen_clipboard(lua_State *L) {
    Gestalt(gestaltSystemVersion, &MacVersion);

    luaL_register(L, "clipboard", clipboardlib);
    return 1;
}
