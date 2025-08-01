//
//  SCLSecurityUtils.m
//  SCLAlertView
//
//  Security enhancements for SCLAlertView
//  This implementation provides internal security utilities to protect
//  against reverse engineering, tampering, and debugging attempts.
//
//  Copyright (c) 2024 SCLAlertView Contributors. All rights reserved.
//

#import "SCLSecurityUtils.h"
#import <sys/sysctl.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <CommonCrypto/CommonCrypto.h>

@implementation SCLSecurityUtils

#pragma mark - Private Key Derivation

/**
 * Derives an encryption key at runtime from system information.
 *
 * This function generates a unique key based on system information
 * that is only available at runtime, making it difficult to predict
 * or reproduce the key through static analysis.
 *
 * @return A 16-byte NSData object containing the derived key
 */
static NSData * _Nullable getRuntimeKey(void) {
    static dispatch_once_t onceToken;
    static NSData *key = nil;
    
    dispatch_once(&onceToken, ^{
        // Derive key from system information at runtime
        NSProcessInfo *processInfo = [NSProcessInfo processInfo];
        NSTimeInterval uptime = [processInfo systemUptime];
        NSUInteger processId = [processInfo processIdentifier];
        NSString *hostName = [processInfo hostName];
        
        // Combine system information to create a unique key
        NSString *keySource = [NSString stringWithFormat:@"%@-%f-%lu", hostName, uptime, (unsigned long)processId];
        key = [[keySource dataUsingEncoding:NSUTF8StringEncoding] subdataWithRange:NSMakeRange(0, 16)];
    });
    
    return key;
}

#pragma mark - String Encryption

+ (NSData *)encryptString:(NSString *)string {
    if (!string) {
        return nil;
    }
    
    // Convert string to data for encryption
    NSData *inputData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *key = getRuntimeKey();
    
    if (!key || key.length == 0) {
        return inputData;
    }
    
    // Perform XOR encryption with the runtime-derived key
    NSMutableData *encryptedData = [NSMutableData dataWithLength:inputData.length];
    const uint8_t *inputBytes = inputData.bytes;
    const uint8_t *keyBytes = key.bytes;
    uint8_t *encryptedBytes = encryptedData.mutableBytes;
    
    for (NSUInteger i = 0; i < inputData.length; i++) {
        encryptedBytes[i] = inputBytes[i] ^ keyBytes[i % key.length];
    }
    
    return encryptedData;
}

+ (NSString *)decryptData:(NSData *)data {
    if (!data) {
        return nil;
    }
    
    // XOR encryption is symmetric, so we can use the same method
    // for decryption by applying it again with the same key
    NSData *decryptedData = [self encryptString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
}

#pragma mark - Secure Memory Management

+ (void *)secureAllocate:(size_t)size {
    if (size == 0) {
        return NULL;
    }
    
    // Allocate memory using calloc to ensure it's zero-initialized
    void *ptr = calloc(size, 1);
    if (!ptr) {
        return NULL;
    }
    
    // Lock memory to prevent swapping to disk, which protects sensitive data
    // from being written to persistent storage where it could be recovered
    if (mlock(ptr, size) != 0) {
        free(ptr);
        return NULL;
    }
    
    return ptr;
}

+ (void)secureWipe:(void *)ptr size:(size_t)size {
    if (!ptr || size == 0) {
        return;
    }
    
    // Use volatile to prevent compiler optimizations that might skip the wipe
    volatile uint8_t *p = (volatile uint8_t *)ptr;
    
    // Wipe memory by writing zeros to each byte
    for (size_t i = 0; i < size; i++) {
        p[i] = 0;
    }
    
    // Memory barrier to ensure compiler doesn't optimize away the wipe
    __asm__ __volatile__("" ::: "memory");
}

+ (void)secureFree:(void *)ptr size:(size_t)size {
    if (!ptr || size == 0) {
        return;
    }
    
    // Wipe memory before freeing to ensure sensitive data is not left in memory
    [self secureWipe:ptr size:size];
    
    // Unlock memory to allow the system to reclaim the locked pages
    munlock(ptr, size);
    
    // Free the memory
    free(ptr);
}

#pragma mark - Debugger Detection

+ (BOOL)isDebuggerAttached {
    // Check if debugger is attached using sysctl
    // This method queries the kernel for process information and checks
    // if the P_TRACED flag is set, which indicates that a debugger
    // is attached to the current process
    struct kinfo_proc info;
    size_t size = sizeof(info);
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()};
    
    if (sysctl(mib, 4, &info, &size, NULL, 0) == 0) {
        return (info.kp_proc.p_flag & P_TRACED) != 0;
    }
    
    return NO;
}

#pragma mark - Checksum Verification

+ (uint32_t)calculateChecksum:(const void *)data length:(size_t)length {
    if (!data || length == 0) {
        return 0;
    }
    
    const uint8_t *bytes = (const uint8_t *)data;
    uint32_t checksum = 0;
    
    // Simple checksum algorithm based on the Jenkins hash function
    // This provides a good balance between speed and collision resistance
    for (size_t i = 0; i < length; i++) {
        checksum += bytes[i];
        checksum += (checksum << 10);
        checksum ^= (checksum >> 6);
    }
    
    checksum += (checksum << 3);
    checksum ^= (checksum >> 11);
    checksum += (checksum << 15);
    
    return checksum;
}

+ (BOOL)verifyChecksum:(const void *)data length:(size_t)length expectedChecksum:(uint32_t)expectedChecksum {
    // Calculate the checksum of the provided data and compare it
    // with the expected checksum to verify data integrity
    uint32_t actualChecksum = [self calculateChecksum:data length:length];
    return actualChecksum == expectedChecksum;
}

#pragma mark - Method Name Obfuscation

+ (NSString *)obfuscateMethodName:(NSString *)methodName {
    if (!methodName) {
        return nil;
    }
    
    // Simple obfuscation using XOR with a fixed pattern
    // This makes method names less readable in static analysis
    NSData *methodNameData = [methodName dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *obfuscatedData = [NSMutableData dataWithLength:methodNameData.length];
    
    const uint8_t *inputBytes = methodNameData.bytes;
    uint8_t *obfuscatedBytes = obfuscatedData.mutableBytes;
    
    // Fixed obfuscation pattern - XOR with these bytes to obfuscate
    const uint8_t pattern[] = {0xAA, 0x55, 0xFF, 0x00, 0x33, 0xCC};
    
    for (NSUInteger i = 0; i < methodNameData.length; i++) {
        obfuscatedBytes[i] = inputBytes[i] ^ pattern[i % sizeof(pattern)];
    }
    
    // Return base64 encoded string to make it less readable
    // Base64 encoding makes the obfuscated name appear as random characters
    return [obfuscatedData base64EncodedStringWithOptions:0];
}

+ (NSString *)deobfuscateMethodName:(NSString *)obfuscatedName {
    if (!obfuscatedName) {
        return nil;
    }
    
    // Decode base64 to get the obfuscated data
    NSData *obfuscatedData = [[NSData alloc] initWithBase64EncodedString:obfuscatedName options:0];
    if (!obfuscatedData) {
        return nil;
    }
    
    NSMutableData *methodNameData = [NSMutableData dataWithLength:obfuscatedData.length];
    
    const uint8_t *obfuscatedBytes = obfuscatedData.bytes;
    uint8_t *methodBytes = methodNameData.mutableBytes;
    
    // Same obfuscation pattern - XOR is symmetric, so applying it again
    // with the same pattern will restore the original data
    const uint8_t pattern[] = {0xAA, 0x55, 0xFF, 0x00, 0x33, 0xCC};
    
    for (NSUInteger i = 0; i < obfuscatedData.length; i++) {
        methodBytes[i] = obfuscatedBytes[i] ^ pattern[i % sizeof(pattern)];
    }
    
    return [[NSString alloc] initWithData:methodNameData encoding:NSUTF8StringEncoding];
}

@end
