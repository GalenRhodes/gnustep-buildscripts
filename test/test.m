//
//  main.m
//  LockSpeedTest
//
//  Created by Galen Rhodes on 2/2/18.
//  Copyright © 2018 Project Galen. All rights reserved.
//

#import <Foundation/Foundation.h>

#define _ITERATIONS_ ((uint64_t)(1024 * 1024 * 200))
#define _NANO_ ((double)(1000000000.0))

#ifndef __APPLE__

double CFAbsoluteTimeGetCurrent(void) {
    struct timespec ts;
    int res = clock_gettime(CLOCK_MONOTONIC, &ts);
    return (((double)ts.tv_sec) + (((double)ts.tv_nsec) / _NANO_));
}

#endif

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSRecursiveLock *rlock  = [NSRecursiveLock new];
        NSLock          *lock   = [NSLock new];
        double          timeStart;
        double          timeStop;
        double          timeTotal;
        double          timePerIter;
        NSString        *lockMe = @"lockMe";

        /*
         * NSRecursiveLock =================================================
         */
        NSString          *testName = @"NSRecursiveLock";
        NSNumberFormatter *f        = [NSNumberFormatter new];
        NSNumberFormatter *g        = [NSNumberFormatter new];

        f.positiveFormat        = @"#,##0";
        g.positiveFormat        = @"#,##0.0000";
        f.thousandSeparator     = @",";
        f.hasThousandSeparators = YES;
        f.groupingSeparator     = @",";
        f.groupingSize          = 3;
        f.usesGroupingSeparator = YES;
        g.thousandSeparator     = @",";
        g.hasThousandSeparators = YES;
        g.groupingSeparator     = @",";
        g.groupingSize          = 3;
        g.usesGroupingSeparator = YES;
		g.minimumFractionDigits = 4;
		g.maximumFractionDigits = 4;

        NSLog(@" ");
        NSLog(@"Starting test for %@: %@ iterations", testName, [f stringForObjectValue:@((_ITERATIONS_))]);
        timeStart = CFAbsoluteTimeGetCurrent();
        for(uint64_t i = 0; i < _ITERATIONS_;) {
            [rlock lock];
            ++i;
            [rlock unlock];
        }
        timeStop    = CFAbsoluteTimeGetCurrent();
        timeTotal   = (timeStop - timeStart);
        timePerIter = ((timeTotal / (double)_ITERATIONS_) * _NANO_);
        NSLog(@"================================================================================");
        NSLog(@"Total time for %@: %lf sec; Average: %@ nsec", testName, timeTotal, [g stringForObjectValue:@(timePerIter)]);
        NSLog(@"================================================================================");
        NSLog(@" ");

        /*
         * NSRecursiveLock reenter =========================================
         */
        testName = @"NSRecursiveLock reenter";
        NSLog(@"Starting test for %@: %@ iterations", testName, [f stringForObjectValue:@((_ITERATIONS_))]);
        timeStart = CFAbsoluteTimeGetCurrent();
        for(uint64_t i = 0; i < _ITERATIONS_;) {
            [rlock lock];
            [rlock lock];
            ++i;
            [rlock unlock];
            [rlock unlock];
        }
        timeStop    = CFAbsoluteTimeGetCurrent();
        timeTotal   = (timeStop - timeStart);
        timePerIter = ((timeTotal / (double)_ITERATIONS_) * _NANO_);
        NSLog(@"================================================================================");
        NSLog(@"Total time for %@: %lf sec; Average: %@ nsec", testName, timeTotal, [g stringForObjectValue:@(timePerIter)]);
        NSLog(@"================================================================================");
        NSLog(@" ");

        /*
         * NSLock ==========================================================
         */
        testName = @"NSLock";
        NSLog(@"Starting test for %@: %@ iterations", testName, [f stringForObjectValue:@((_ITERATIONS_))]);
        timeStart = CFAbsoluteTimeGetCurrent();
        for(uint64_t i = 0; i < _ITERATIONS_;) {
            [lock lock];
            ++i;
            [lock unlock];
        }
        timeStop    = CFAbsoluteTimeGetCurrent();
        timeTotal   = (timeStop - timeStart);
        timePerIter = ((timeTotal / (double)_ITERATIONS_) * _NANO_);
        NSLog(@"================================================================================");
        NSLog(@"Total time for %@: %lf sec; Average: %@ nsec", testName, timeTotal, [g stringForObjectValue:@(timePerIter)]);
        NSLog(@"================================================================================");
        NSLog(@" ");

        /*
         * exception safe NSRecursiveLock ==================================
         */
        testName = @"exception safe NSRecursiveLock";
        NSLog(@"Starting test for %@: %@ iterations", testName, [f stringForObjectValue:@((_ITERATIONS_))]);
        timeStart = CFAbsoluteTimeGetCurrent();
        for(uint64_t i = 0; i < _ITERATIONS_;) {
            [rlock lock];
            @try {
                ++i;
            }
            @finally {
                [rlock unlock];
            }
        }
        timeStop    = CFAbsoluteTimeGetCurrent();
        timeTotal   = (timeStop - timeStart);
        timePerIter = ((timeTotal / (double)_ITERATIONS_) * _NANO_);
        NSLog(@"================================================================================");
        NSLog(@"Total time for %@: %lf sec; Average: %@ nsec", testName, timeTotal, [g stringForObjectValue:@(timePerIter)]);
        NSLog(@"================================================================================");
        NSLog(@" ");

        /*
         * exception safe NSRecursiveLock reenter ==========================
         */
        testName = @"exception safe NSRecursiveLock reenter";
        NSLog(@"Starting test for %@: %@ iterations", testName, [f stringForObjectValue:@((_ITERATIONS_))]);
        timeStart = CFAbsoluteTimeGetCurrent();
        for(uint64_t i = 0; i < _ITERATIONS_;) {
            [rlock lock];
            @try {
                [rlock lock];
                @try {
                    ++i;
                }
                @finally {
                    [rlock unlock];
                }
            }
            @finally {
                [rlock unlock];
            }
        }
        timeStop    = CFAbsoluteTimeGetCurrent();
        timeTotal   = (timeStop - timeStart);
        timePerIter = ((timeTotal / (double)_ITERATIONS_) * _NANO_);
        NSLog(@"================================================================================");
        NSLog(@"Total time for %@: %lf sec; Average: %@ nsec", testName, timeTotal, [g stringForObjectValue:@(timePerIter)]);
        NSLog(@"================================================================================");
        NSLog(@" ");

        /*
         * exception safe NSLock ===========================================
         */
        testName = @"exception safe NSLock";
        NSLog(@"Starting test for %@: %@ iterations", testName, [f stringForObjectValue:@((_ITERATIONS_))]);
        timeStart = CFAbsoluteTimeGetCurrent();
        for(uint64_t i = 0; i < _ITERATIONS_;) {
            [lock lock];
            @try {
                ++i;
            }
            @finally {
                [lock unlock];
            }
        }
        timeStop    = CFAbsoluteTimeGetCurrent();
        timeTotal   = (timeStop - timeStart);
        timePerIter = ((timeTotal / (double)_ITERATIONS_) * _NANO_);
        NSLog(@"================================================================================");
        NSLog(@"Total time for %@: %lf sec; Average: %@ nsec", testName, timeTotal, [g stringForObjectValue:@(timePerIter)]);
        NSLog(@"================================================================================");
        NSLog(@" ");

        /*
         * @synchronized ===================================================
         */
        testName = @"@synchronized";
        NSLog(@"Starting test for %@: %@ iterations", testName, [f stringForObjectValue:@((_ITERATIONS_))]);
        timeStart = CFAbsoluteTimeGetCurrent();
        for(uint64_t i = 0; i < _ITERATIONS_;) {
            @synchronized(lockMe) {
                ++i;
            }
        }
        timeStop    = CFAbsoluteTimeGetCurrent();
        timeTotal   = (timeStop - timeStart);
        timePerIter = ((timeTotal / (double)_ITERATIONS_) * _NANO_);
        NSLog(@"================================================================================");
        NSLog(@"Total time for %@: %lf sec; Average: %@ nsec", testName, timeTotal, [g stringForObjectValue:@(timePerIter)]);
        NSLog(@"================================================================================");
        NSLog(@" ");
    }

    return 0;
}
