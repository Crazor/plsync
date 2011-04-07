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

#import "Log.h"

// Taken from bbum at http://stackoverflow.com/questions/2216266/printing-an-nsstring/2217515#2217515
void Log(NSString *format, ...)
{
    va_list args;
    va_start(args, format);
    NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [(NSFileHandle *)[NSFileHandle fileHandleWithStandardOutput] writeData:[[formattedString stringByAppendingString:@"\n"] dataUsingEncoding:NSNEXTSTEPStringEncoding]];
    [formattedString release];
}
