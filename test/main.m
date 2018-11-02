//
//  main.m
//  LockSpeedTest
//
//  Created by Galen Rhodes on 2/2/18.
//  Copyright © 2018 Project Galen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGTests.h"
#import "PGARCException.h"

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        PGARCException *test = [PGARCException new];
        [test runTests];
    }

    return 0;
}
