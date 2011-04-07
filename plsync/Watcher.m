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
    UKKQueue *fileWatcher = [UKKQueue sharedFileWatcher];
    [fileWatcher setDelegate:self];
    
    NSString *watchDir = [@"~/.plsync/temp" stringByExpandingTildeInPath];
    NSArray *watchFileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:watchDir    error:NULL];
    
    [fileWatcher addPath:watchDir];
    
    for (NSString *file in watchFileList)
    {
        Log(@"Watching File %@", [watchDir stringByAppendingPathComponent:file]);
        [fileWatcher addPath:[watchDir stringByAppendingPathComponent:file]];
    }
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop run];
}

- (void)watcher: (id<UKFileWatcher>)kq receivedNotification: (NSString*)nm forPath: (NSString*)fpath
{
    Log(@"receivedNotification: %@ forPath: %@", nm, fpath);
}

@end
