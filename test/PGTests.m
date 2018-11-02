/******************************************************************************************************************************//**
 *     PROJECT: LockSpeedTest
 *    FILENAME: PGTests.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 2/5/18 11:21 AM
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

#import "PGTests.h"
#import <objc/objc-runtime.h>

#define PG_TYPE_BUFSZ      (100)
#define PG_VOID_TYPE       ("v")
#define PG_TEST_PREFIX     ("test")
#define PG_TEST_PREFIX_LEN (strlen(PG_TEST_PREFIX))

@implementation PGTests {
        NSNumberFormatter *f;
    }

    @synthesize startTime = _startTime;
    @synthesize stopTime = _stopTime;
    @synthesize totalTime = _totalTime;

    -(instancetype)init {
        self = [super init];

        if(self) {
            f = [NSNumberFormatter new];
            f.thousandSeparator     = @",";
            f.groupingSeparator     = @",";
            f.groupingSize          = 3;
            f.usesGroupingSeparator = YES;
            f.hasThousandSeparators = YES;
        }

        return self;
    }

    -(NSInteger)runTests {
        unsigned int mc      = 0;
        Method       *mlist  = class_copyMethodList([self class], &mc);
        char         *buffer = (char *)malloc(PG_TYPE_BUFSZ);

        for(int i = 0; i < mc; ++i) {
            Method m   = mlist[i];
            SEL    sel = method_getName(m);
            if([self isTestCase:m sel:sel]) [self executeTestCase:sel];
        }

        free(buffer);
        free(mlist);
        return 0;
    }

    -(BOOL)isTestCase:(Method)m sel:(SEL)sel {
        const char *nam       = sel_getName(sel);
        char       *typ       = method_copyReturnType(m);
        BOOL       isTestCase = ((method_getNumberOfArguments(m) == 2) &&
                                 (strcmp(typ, @encode(unsigned long long)) == 0) &&
                                 (strlen(nam) > PG_TEST_PREFIX_LEN) &&
                                 (strncmp(nam, PG_TEST_PREFIX, PG_TEST_PREFIX_LEN) == 0));
        free(typ);
        return isTestCase;
    }

    -(void)executeTestCase:(SEL)sel {
        const char         *tcName      = sel_getName(sel);
        unsigned long long tcIterations = 1;
        double             tcStartTime  = 0;
        double             tcStopTime   = 0;

        NSLog(@"Starting test case \"%s\".", tcName);

        @try {
            tcStartTime = CFAbsoluteTimeGetCurrent();
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:sel]];
            [inv setSelector:sel];
            [inv invokeWithTarget:self];
            [inv getReturnValue:&tcIterations];
            tcStopTime = CFAbsoluteTimeGetCurrent();
        }
        @catch(NSException *exception) {
            tcStopTime = CFAbsoluteTimeGetCurrent();
            NSLog(@"Exception in test case \"%s\": %@, %@", tcName, exception, [exception userInfo]);
        }
        @finally {
            double   tcTotalTime = (tcStopTime - tcStartTime);
            NSString *siter      = [f stringFromNumber:@(tcIterations)];
            NSString *periter    = ((tcIterations > 1) ? [NSString stringWithFormat:@"; %0.4lf nanoseconds/iteration", ((tcTotalTime / (double)tcIterations) * _NANO_)] : @"");
            NSLog(@"Finished test case \"%s\": %0.4lf seconds; %@ iterations%@", tcName, tcTotalTime, siter, periter);
        }
    }

@end

#ifndef __APPLE__

double CFAbsoluteTimeGetCurrent(void) {
    struct timespec ts;
    int res = clock_gettime(CLOCK_MONOTONIC, &ts);
    return (((double)ts.tv_sec) + (((double)ts.tv_nsec) / _NANO_));
}

#endif

