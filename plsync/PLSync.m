/*
 * This file is part of the plsync project.
 *
 * Copyright 2011 Crazor <crazor@gmail.com>
 *
 * Tile is free software: you can redistribute it and/or modify
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

#import "PLSync.h"

@implementation PLSync

+ (void)loadRules
{   
    NSString *rulesDir = [NSHomeDirectory() stringByAppendingPathComponent:@".plsync/rules"];
    NSArray *ruleFileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rulesDir error:NULL];

    ruleFiles = [NSMutableArray arrayWithCapacity:[ruleFileList count]];
    
    for (NSString *file in ruleFileList)
    {
        if (![file hasSuffix:@".plist"])
            continue;
        
        NSLog(@"Loading rules from %@", file);
        NSDictionary *rules = [NSDictionary dictionaryWithContentsOfFile:[rulesDir stringByAppendingPathComponent:file]];
        if (!rules)
        {
            NSLog(@"Error! File %@ is not a valid plist.", file);
            continue;
        }
        [ruleFiles addObject:rules];
    }
}

+ (void)executeRuleFiles
{
    for (NSDictionary *ruleFile in ruleFiles)
    {
        [PLSync executeRuleFile:ruleFile];
    }
}

+ (void)executeRuleFile: (NSDictionary *)ruleFile
{
    for (NSDictionary *rule in [ruleFile objectForKey:@"Rules"])
    {
        NSString *fileName = [rule objectForKey:@"FileName"];
        if (!fileName)
        {
            NSLog(@"Error: No file name specified.");
            continue;
        }
        
        NSArray *whiteList = [rule objectForKey:@"WhiteList"];
        if (!whiteList)
        {
            NSLog(@"Error: No WhiteList specified.");
            continue;
        }
        
        NSLog(@"Processing file %@", fileName);
        NSDictionary *file = [NSDictionary dictionaryWithContentsOfFile:[fileName stringByExpandingTildeInPath]];
        if (!file)
        {
            NSLog(@"Error! File %@ is not a valid plist.", fileName);
            return;
        }
        
        NSMutableDictionary *newFile = [NSMutableDictionary dictionaryWithCapacity:[file count]];
        for (id element in file)
        {
            if ([whiteList containsObject:element])
            {
                [newFile setObject:[file objectForKey:element] forKey:element];
            }
        }
        
        NSString *newFileName = [@"~/.plsync/plists/" stringByAppendingString:[fileName lastPathComponent]];
        if (![newFile writeToFile:[newFileName stringByExpandingTildeInPath] atomically:YES])
            NSLog(@"Error writing file %@", newFileName);
    }
}

@end
