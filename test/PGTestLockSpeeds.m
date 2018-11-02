/******************************************************************************************************************************//**
 *     PROJECT: LockSpeedTest
 *    FILENAME: PGTestLockSpeeds.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 2/5/18 11:51 AM
 * DESCRIPTION:
 *
 * Copyright © 2018 Project Galen. All rights reserved.
 *
 * "It can hardly be a coincidence that no language on Earth has ever produced the expression 'As pretty as an airport.' Airports
 * are ugly. Some are very ugly. Some attain a degree of ugliness that can only be the result of special effort."
 * - Douglas Adams from "The Long Dark Tea-Time of the Soul"
 *
 * Permission to use, copy, modify, and distribute this software for any purpose with or without fee is hereby granted, provided
 * that the above copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
 * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
 * NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *********************************************************************************************************************************/

#import "PGTestLockSpeeds.h"

@implementation PGTestLockSpeeds {
        NSRecursiveLock *rlock;
        NSLock          *lock;
        NSString        *lockMe;
    }

    -(instancetype)init {
        self = [super init];

        if(self) {
            rlock  = [NSRecursiveLock new];
            lock   = [NSLock new];
            lockMe = @"lockMe";
        }

        return self;
    }

    -(unsigned long long)testNSRecursiveLock {
        for(uint64_t i = 0; i < _ITERATIONS_;) {
            [rlock lock];
            ++i;
            [rlock unlock];
        }

        return _ITERATIONS_;
    }

    -(unsigned long long)testNSLock {
        for(uint64_t i = 0; i < _ITERATIONS_;) {
            [lock lock];
            ++i;
            [lock unlock];
        }
        return _ITERATIONS_;
    }

    -(unsigned long long)testExceptionSafeNSRecursiveLock {
        for(uint64_t i = 0; i < _ITERATIONS_;) {
            [rlock lock];
            @try {
                ++i;
            }
            @finally {
                [rlock unlock];
            }
        }
        return _ITERATIONS_;
    }

    -(unsigned long long)testExceptionSafeNSLock {
        for(uint64_t i = 0; i < _ITERATIONS_;) {
            [lock lock];
            @try {
                ++i;
            }
            @finally {
                [lock unlock];
            }
        }
        return _ITERATIONS_;
    }

    -(unsigned long long)testSynchronized {
        for(uint64_t i = 0; i < _ITERATIONS_;) {
            @synchronized(lockMe) {
                ++i;
            }
        }
        return _ITERATIONS_;
    }

@end
