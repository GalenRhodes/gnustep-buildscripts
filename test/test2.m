//
// main.m
// Just a little test case for Objective-C 2.0 on Ubuntu
//
// Created by Tobias Lensing on 2/22/13.
// More cool stuff available at blog.tlensing.org.
//
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <dispatch/dispatch.h>

@interface PGMyObject : NSObject
	@property(nonatomic, copy) NSString *title;

	-(instancetype)initWithTitle:(NSString *)title;

	-(NSString *)description;

@end

@implementation PGMyObject {
	}

	@synthesize title = _title;

    -(instancetype)initWithTitle:(NSString *)title {
        self = [super init];
        if(self) self.title = title;
        return self;
    }

    -(NSString *)description {
        return [self.title copy];
    }

	-(void)dealloc {
		NSLog(@"%@:%@", @"I'm being deallocated", self.title);
	}

@end

void myFunction(BOOL th) {
	NSLog(@"%@", @"Alpha:One...");
	NSException *ex = [NSException exceptionWithName:@"My Exception" reason:@"I just wanted to." userInfo:@{ NSLocalizedDescriptionKey:@"Foo Bar" }];
	NSLog(@"%@", @"Alpha:Two...");
	PGMyObject *o = [[PGMyObject alloc] initWithTitle:@"Batman"];
	if(th) {
		NSLog(@"\n\n%@\n\n", @"ACK!  BARF!!!!");
		@throw ex;
	}
	NSLog(@"%@: %@", @"Alpha:Three", o);
}

int main(int argc, const char * argv[]) {
	NSLog(@"%@", @"One...");

    @autoreleasepool {
		NSLog(@"%@", @"Two...");

		@try {
			NSLog(@"%@", @"Three...");
			PGMyObject *obj = [[PGMyObject alloc] initWithTitle:@"I am superman!"];
			NSLog(@"%@: %@", @"Four", obj);
        	NSApplication *app = [NSApplication sharedApplication];
			NSLog(@"%@", @"Five...");

	        int multiplier = 7;
    	    int (^myBlock)(int) = ^(int num) {
	            return num * multiplier;
    	    };
			NSLog(@"%@", @"Six...");
			myFunction(NO);
        	NSLog(@"%d", myBlock(3));
			NSLog(@"%@", @"Seven...");

	        dispatch_queue_t queue = dispatch_queue_create(NULL, NULL);
			NSLog(@"%@", @"Eight...");
    	    dispatch_sync(queue, ^{
        	    printf("Hello, world from a dispatch queue!\n");
	        });

			NSLog(@"%@", @"Nine...");
			myFunction(YES);
			// myFunction(NO);

	        NSRunAlertPanel(@"Test", obj.description, @"OK", nil, nil);
		}
		@catch(NSException *e) {
			NSLog(@"Caught Exception: %@", e);
		}
		@finally {
			NSLog(@"%@", @"Finally section executed.");
		}
    }

	NSLog(@"%@", @"Ten...");
    return 0;
}

