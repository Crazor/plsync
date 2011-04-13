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

#import "Watcher.h"
#import "UKKQueue.h"

@implementation Watcher

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

- (void)watch
{
    NSDictionary *blacklistFile = [NSDictionary dictionaryWithContentsOfFile:[@"~/.plsync/blacklist.plist" stringByExpandingTildeInPath]];
    
    blacklistedFiles = [NSMutableArray arrayWithCapacity:[[blacklistFile objectForKey:@"BlacklistedFiles"] count]];
    for (NSString *file in [blacklistFile objectForKey:@"BlacklistedFiles"])
    {
        [blacklistedFiles addObject:[file stringByExpandingTildeInPath]];
    }
    
    blacklistedKeys = [blacklistFile objectForKey:@"BlacklistedKeys"];
    
    fileWatcher = [UKKQueue sharedFileWatcher];
    [fileWatcher setDelegate:self];
    
    NSString *watchedDir = [@"~/Library/Preferences" stringByExpandingTildeInPath];
    Log(@"Watching %@", watchedDir);
    
    NSArray *watchedFileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:watchedDir error:NULL];
    watchedFileListWithAttributes = [NSMutableDictionary dictionaryWithCapacity:[watchedFileList count]];
    watchedFileContents = [NSMutableDictionary dictionaryWithCapacity:[watchedFileList count]];
    
    [fileWatcher addPath:watchedDir];
    
    for (NSString *file in watchedFileList)
    {
        NSString *fileWithPath = [watchedDir stringByAppendingPathComponent:file];
        NSDictionary *fileAttribute = [[NSFileManager defaultManager] attributesOfItemAtPath:fileWithPath error:NULL];
        [watchedFileListWithAttributes setObject:fileAttribute forKey:fileWithPath];
        
        if (![file hasSuffix:@".plist"])
            continue;
        
        NSString *fileName = [watchedDir stringByAppendingPathComponent:file];
        NSDictionary *fileContents = [NSDictionary dictionaryWithContentsOfFile:fileName];
        
        if (fileContents)
        {
            [watchedFileContents setObject:fileContents forKey:fileName];
//            [fileWatcher addPath:fileName]; // only needed for events like delete.
        }
    }
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop run];
}

- (void)watcher: (id<UKFileWatcher>)kq receivedNotification: (NSString*)nm forPath: (NSString*)fpath
{
    if ([nm isEqualToString:UKFileWatcherDeleteNotification])
    {
        Log(@"File %@ was deleted.", fpath);
    }
    else if ([nm isEqualToString:UKFileWatcherWriteNotification])
    {
        if ([[[[NSFileManager defaultManager] attributesOfItemAtPath:fpath error:NULL] fileType] isEqualToString:NSFileTypeDirectory])
        {
            NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fpath error:NULL];
            for (NSString *file in fileList)
            {
                NSString *fileWithPath = [fpath stringByAppendingPathComponent:file];
                if ([[[watchedFileListWithAttributes objectForKey:fileWithPath] objectForKey:NSFileModificationDate] compare:[[[NSFileManager defaultManager] attributesOfItemAtPath:fileWithPath error:NULL] objectForKey:NSFileModificationDate]] == NSOrderedAscending)
                {
                    if (![blacklistedFiles containsObject:fileWithPath])
                    {
                        Log(@"File %@ changed!", fileWithPath);
                        NSDictionary *newFile = [NSDictionary dictionaryWithContentsOfFile:fileWithPath];
                        [self diffDictionary:[watchedFileContents objectForKey:fileWithPath] andDictionary:newFile];
                        [watchedFileContents setObject:newFile forKey:fileWithPath];
                    }
                }
            }
        }
        else
        {
            Log(@"File %@ was written.", fpath);
        }
    }
    else
    {
        Log(@"Notification: %@ File: %@", nm, fpath);
    }
}

- (void)diffDictionary: (NSDictionary *)aDict andDictionary: (NSDictionary *)anotherDict
{
    if (![aDict isEqualToDictionary:anotherDict])
    {
        [aDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//            Log(@"Enumerating Key %@ and Value %@",key,obj);
            for (NSString *blacklistedKey in blacklistedKeys)
            {
                if ([key hasPrefix:blacklistedKey])
                    return;
            }
            if (![[anotherDict objectForKey:key] isEqualTo:obj])
            {
                Log(@"Key %@ changed. Was %@, is now %@", key, obj, [anotherDict objectForKey:key]);
            }
        }];
    }
}

@end
