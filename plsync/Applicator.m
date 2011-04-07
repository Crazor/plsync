/*
 * This file is part of the plsync project.
 *
 * Copyright 2011 Crazor <crazor@gmail.com>
 *
 * plsync is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * plsync is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with plsync.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "Applicator.h"


@implementation Applicator

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)applySettingsFiles
{
    NSString *settingsDir = [@"~/.plsync/plists" stringByExpandingTildeInPath];
    NSArray *settingsFileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:settingsDir error:NULL];
    
    for (NSString *file in settingsFileList)
    {
        if (![file hasSuffix:@".plist"])
            continue;
        
        Log(@"Loading settings from %@", file);
        NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsDir stringByAppendingPathComponent:file]];
        if (!settings)
        {
            Log(@"    Error! File %@ is not a valid plist.", file);
            continue;
        }
        [self applySettingsFile:settings];
    }
}

- (void)applySettingsFile: (NSDictionary *)settingsFile
{
    NSString *fileName = [settingsFile objectForKey:@"FileName"];
    if (!fileName)
    {
        Log(@"    Error: No file name specified.");
        //continue;
        return;
    }
    
    NSDictionary *settings = [settingsFile objectForKey:@"Settings"];
    if (!settings)
    {
        Log(@"    Error: No settings specified.");
        //continue;
        return;
    }
    
    Log(@"Processing file %@", fileName);
    NSMutableDictionary *file = [NSMutableDictionary dictionaryWithContentsOfFile:[fileName stringByExpandingTildeInPath]];
    if (!file)
    {
        Log(@"    Error! File is not a valid plist.");
        return;
    }
    
    for (id element in settings)
    {
        [file setObject:[settings objectForKey:element] forKey:element];
    }
    
    if (![file writeToFile:[fileName stringByExpandingTildeInPath] atomically:YES])
        Log(@"Error writing file %@", fileName);
}

@end
