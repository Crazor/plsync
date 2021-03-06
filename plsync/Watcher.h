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

#import <Foundation/Foundation.h>
#import "UKKQueue.h"

@interface Watcher : NSObject {
    NSMutableArray *blacklistedFiles;
    NSArray *blacklistedKeys;
    UKKQueue *fileWatcher;
    NSMutableDictionary *watchedFileListWithAttributes;
    NSMutableDictionary *watchedFileContents;
@private
    
}

- (void)watch;
- (void)watcher: (id<UKFileWatcher>)kq receivedNotification: (NSString*)nm forPath: (NSString*)fpath;

- (void)diffDictionary: (NSDictionary *)aDict andDictionary: (NSDictionary *)anotherDict;

@end
