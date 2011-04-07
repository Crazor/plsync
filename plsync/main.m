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

void usage();

int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    NSArray *arguments = [[NSProcessInfo processInfo] arguments];

    if ([arguments count] == 1)
    {
        usage();
    }
    else
    {
        NSString *command = [arguments objectAtIndex:1];
    
        if ([command isEqualToString:@"extract"])
            [PLSync executeExtractionRuleFiles];
        else if ([command isEqualToString:@"apply"])
            [PLSync applySettingsFiles];
        else
            Log(@"Unknown command \"%@\"", command);
    }
    
    [pool drain];
    return 0;
}

void usage()
{
    Log(@"Usage: plsync [extract|apply]");
}