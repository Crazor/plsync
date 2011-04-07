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

#import "Extractor.h"


@implementation Extractor

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

- (void)executeExtractionRuleFiles
{   
    NSString *rulesDir = [NSHomeDirectory() stringByAppendingPathComponent:@".plsync/rules"];
    NSArray *ruleFileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rulesDir error:NULL];
    
    for (NSString *file in ruleFileList)
    {
        if (![file hasSuffix:@".plist"])
            continue;
        
        Log(@"Loading rules from %@", file);
        NSDictionary *rules = [NSDictionary dictionaryWithContentsOfFile:[rulesDir stringByAppendingPathComponent:file]];
        if (!rules)
        {
            Log(@"    Error! File %@ is not a valid plist.", file);
            continue;
        }
        [self executeExtractionRuleFile:rules];
    }
}

- (void)executeExtractionRuleFile: (NSDictionary *)ruleFile
{
    for (NSDictionary *rule in [ruleFile objectForKey:@"Rules"])
    {
        NSString *fileName = [rule objectForKey:@"FileName"];
        if (!fileName)
        {
            Log(@"    Error: No file name specified.");
            continue;
        }
        
        NSArray *whiteList = [rule objectForKey:@"WhiteList"];
        if (!whiteList)
        {
            Log(@"    Error: No WhiteList specified.");
            continue;
        }
        
        Log(@"Processing file %@", fileName);
        NSDictionary *file = [NSDictionary dictionaryWithContentsOfFile:[fileName stringByExpandingTildeInPath]];
        if (!file)
        {
            Log(@"    Error! File is not a valid plist.");
            return;
        }
        
        NSMutableDictionary *newFile = [NSMutableDictionary dictionaryWithCapacity:[file count]];
        [newFile setObject:fileName forKey:@"FileName"];
        
        NSMutableDictionary *newSettings = [NSMutableDictionary dictionaryWithCapacity:[file count]];
        
        for (id element in file)
        {
            if ([whiteList containsObject:element])
            {
                [newSettings setObject:[file objectForKey:element] forKey:element];
            }
        }
        
        [newFile setObject:newSettings forKey:@"Settings"];
        
        NSString *newFileName = [@"~/.plsync/plists/" stringByAppendingString:[fileName lastPathComponent]];
        if (![newFile writeToFile:[newFileName stringByExpandingTildeInPath] atomically:YES])
            Log(@"Error writing file %@", newFileName);
    }
}

@end
