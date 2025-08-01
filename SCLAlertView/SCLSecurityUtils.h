//
//  SCLSecurityUtils.h
//  SCLAlertView
//
//  Security enhancements for SCLAlertView
//  This class provides internal security utilities to protect against
//  reverse engineering, tampering, and debugging attempts.
//
//  Copyright (c) 2024 SCLAlertView Contributors. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * SCLSecurityUtils provides internal security utilities for SCLAlertView.
 *
 * This class implements various security measures including:
 * - String encryption to prevent static analysis
 * - Secure memory management to prevent sensitive data leakage
 * - Debugger detection to identify debugging attempts
 * - Checksum verification to ensure data integrity
 * - Method name obfuscation to make reverse engineering more difficult
 *
 * All methods in this class are for internal use only and are not part
 * of the public API. They are designed to work transparently without
 * requiring any changes to existing SCLAlertView usage.
 */
@interface SCLSecurityUtils : NSObject

/**
 * Encrypts a string using a simple XOR cipher with a runtime-derived key
 *
 * This method encrypts sensitive strings to prevent static analysis
 * and reverse engineering. The encryption key is derived at runtime
 * from system information to make it difficult to predict.
 *
 * @param string The string to encrypt
 * @return Encrypted data as NSData object
 */
+ (NSData *)encryptString:(NSString *)string;

/**
 * Decrypts data using a simple XOR cipher with a runtime-derived key
 *
 * This method decrypts data that was previously encrypted using
 * the encryptString: method. The same runtime-derived key is used
 * for decryption.
 *
 * @param data The data to decrypt
 * @return Decrypted string
 */
+ (NSString *)decryptData:(NSData *)data;

/**
 * Securely allocates memory for sensitive data
 *
 * This method allocates memory that is locked to prevent swapping
 * to disk, which helps protect sensitive data from being written
 * to persistent storage.
 *
 * @param size The size of memory to allocate
 * @return Pointer to allocated memory, or NULL if allocation fails
 */
+ (void *)secureAllocate:(size_t)size;

/**
 * Securely wipes memory
 *
 * This method securely wipes memory to prevent sensitive data
 * from remaining in memory after use. It uses volatile pointers
 * and memory barriers to prevent compiler optimizations that
 * might skip the wiping operation.
 *
 * @param ptr Pointer to memory to wipe
 * @param size Size of memory to wipe
 */
+ (void)secureWipe:(void *)ptr size:(size_t)size;

/**
 * Securely frees memory
 *
 * This method securely frees memory that was previously allocated
 * using secureAllocate:size:. It first wipes the memory to remove
 * sensitive data, then unlocks and frees the memory.
 *
 * @param ptr Pointer to memory to free
 * @param size Size of memory to free
 */
+ (void)secureFree:(void *)ptr size:(size_t)size;

/**
 * Checks if a debugger is attached
 *
 * This method detects if a debugger is attached to the current process,
 * which can indicate an attempt to debug or reverse engineer the application.
 *
 * @return YES if debugger is detected, NO otherwise
 */
+ (BOOL)isDebuggerAttached;

/**
 * Calculates a simple checksum for data
 *
 * This method calculates a checksum for the given data, which can be
 * used to verify the integrity of the data. The checksum algorithm
 * is designed to be fast while providing reasonable protection against
 * accidental or intentional data modification.
 *
 * @param data The data to calculate checksum for
 * @param length Length of data in bytes
 * @return Checksum value
 */
+ (uint32_t)calculateChecksum:(const void *)data length:(size_t)length;

/**
 * Verifies checksum for data
 *
 * This method verifies that the checksum of the given data matches
 * the expected checksum. This can be used to detect if data has been
 * modified or tampered with.
 *
 * @param data The data to verify
 * @param length Length of data in bytes
 * @param expectedChecksum Expected checksum value
 * @return YES if checksum matches, NO otherwise
 */
+ (BOOL)verifyChecksum:(const void *)data length:(size_t)length expectedChecksum:(uint32_t)expectedChecksum;

/**
 * Obfuscates a method name at runtime
 *
 * This method obfuscates a method name to make it more difficult
 * to understand through static analysis. The obfuscated name is
 * base64 encoded to make it less readable.
 *
 * @param methodName The method name to obfuscate
 * @return Obfuscated method name
 */
+ (NSString *)obfuscateMethodName:(NSString *)methodName;

/**
 * Deobfuscates a method name at runtime
 *
 * This method deobfuscates a method name that was previously
 * obfuscated using obfuscateMethodName:. This is used internally
 * to map obfuscated method names back to their original names
 * at runtime.
 *
 * @param obfuscatedName The obfuscated method name
 * @return Original method name
 */
+ (NSString *)deobfuscateMethodName:(NSString *)obfuscatedName;

@end

NS_ASSUME_NONNULL_END
