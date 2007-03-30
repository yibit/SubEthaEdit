//
//  NSStringTCMAdditions.m
//  
//
//  Created by Martin Ott on Tue Feb 17 2004.
//  Copyright (c) 2004 TheCodingMonkeys. All rights reserved.
//

#import "NSStringTCMAdditions.h"

#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <sys/socket.h>


@implementation NSString (NSStringTCMAdditions) 

+ (NSString *)stringWithUUIDData:(NSData *)aData {
    if (aData!=nil && [aData length]>= sizeof(CFUUIDBytes)) {
        CFUUIDRef uuid=CFUUIDCreateFromUUIDBytes(NULL,*(CFUUIDBytes *)[aData bytes]);
        NSString *uuidString=(NSString *)CFUUIDCreateString(NULL,uuid);
        CFRelease(uuid);
        return [uuidString autorelease];
    } else {
        return nil;
    }
}

+ (NSString *)stringWithData:(NSData *)aData encoding:(NSStringEncoding)aEncoding
{
    return [[[NSString alloc] initWithData:aData encoding:aEncoding] autorelease];
}

+ (NSString *)UUIDString
{
    CFUUIDRef myUUID = CFUUIDCreate(NULL);
    CFStringRef myUUIDString = CFUUIDCreateString(NULL, myUUID);
    [(NSString *)myUUIDString retain];
    CFRelease(myUUIDString);
    CFRelease(myUUID);
    
    return [(NSString *)myUUIDString autorelease];
}



+ (NSString *)stringWithAddressData:(NSData *)aData
{
    struct sockaddr *socketAddress = (struct sockaddr *)[aData bytes];
    
    // IPv6 Addresses are "FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF" at max, which is 40 bytes (0-terminated)
    // IPv4 Addresses are "255.255.255.255" at max which is smaller
    
    char stringBuffer[MAX(INET6_ADDRSTRLEN,INET_ADDRSTRLEN)];
    NSString *addressAsString = nil;
    if (socketAddress->sa_family == AF_INET) {
        if (inet_ntop(AF_INET, &(((struct sockaddr_in *)socketAddress)->sin_addr), stringBuffer, INET_ADDRSTRLEN)) {
            addressAsString = [NSString stringWithUTF8String:stringBuffer];
        } else {
            addressAsString = @"IPv4 un-ntopable";
        }
        int port = ((struct sockaddr_in *)socketAddress)->sin_port;
        addressAsString = [addressAsString stringByAppendingFormat:@":%d", port];
    } else if (socketAddress->sa_family == AF_INET6) {
         if (inet_ntop(AF_INET6, &(((struct sockaddr_in6 *)socketAddress)->sin6_addr), stringBuffer, INET6_ADDRSTRLEN)) {
            addressAsString = [NSString stringWithUTF8String:stringBuffer];
        } else {
            addressAsString = @"IPv6 un-ntopable";
        }
        int port = ((struct sockaddr_in6 *)socketAddress)->sin6_port;
        
        // Suggested IPv6 format (see http://www.faqs.org/rfcs/rfc2732.html)
        addressAsString = [NSString stringWithFormat:@"[%@]:%d", addressAsString, port]; 
    } else {
        addressAsString = @"neither IPv6 nor IPv4";
    }
    
    return [[addressAsString copy] autorelease];
}

- (NSData *)UTF8DataWithMaximumLength:(unsigned)aLength {
    NSData *result=[self dataUsingEncoding:NSUTF8StringEncoding];
    if ([result length]>aLength) {
        // truncate at a valid UTF8 boundary
        // see RFC http://www.ietf.org/rfc/rfc3629.txt
        unsigned char *bytes=(unsigned char *)[result bytes];
        unsigned char *end=bytes+aLength;
        // 0x80 = 1000 0000
        // 0x40 = 0100 0000
        // all characters not matching 10xx xxxx are non boundaries
        while ((*end & 0x80) && !(*end & 0x40) && end > bytes) {
            end--;
        }
        result = [result subdataWithRange:NSMakeRange(0,end - bytes)];
    }
    return result;
}

@end


@implementation NSMutableAttributedString (NSMutableAttributedStringTCMAdditions) 

- (void)appendString:(NSString *)aString {
    [self replaceCharactersInRange:NSMakeRange([self length],0) withString:aString];
}

@end