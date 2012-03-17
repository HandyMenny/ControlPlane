//
//  SleepEvidenceSource.m
//  ControlPlane
//
//  Created by David Jennes on 21/08/11.
//  Copyright 2011. All rights reserved.
//

#import "DSLogger.h"
#import "SleepEvidenceSource.h"


@implementation SleepEvidenceSource

- (id) init {
	if (!(self = [super init]))
		return nil;
	
	return self;
}

- (void) doRealUpdate {
	[self setDataCollected:YES];
}

- (NSString*) name {
	return @"Sleep/Wake";
}

- (BOOL) doesRuleMatch: (NSDictionary*) rule {
	NSString *param = [rule objectForKey:@"parameter"];
	
	return (([param isEqualToString: @"sleep"] && systemGoingToSleep) ||
			([param isEqualToString: @"wake"] && systemWakingUp));
}

- (NSString*) getSuggestionLeadText: (NSString*) type {
	return NSLocalizedString(@"System going to", @"In rule-adding dialog");
}

- (NSArray*) getSuggestions {
	return [NSArray arrayWithObjects:
			[NSDictionary dictionaryWithObjectsAndKeys:
			 @"Sleep/Wake", @"type", @"sleep", @"parameter",
			 NSLocalizedString(@"Sleep", @""), @"description", nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
			 @"Sleep/Wake", @"type", @"wake", @"parameter",
			 NSLocalizedString(@"Wake", @""), @"description", nil],
			nil];
}

- (void) start {
	if (running)
		return;
	
	[self doRealUpdate];
	
	running = YES;
}

- (void) stop {
	if (!running)
		return;
	
	[self setDataCollected:NO];
	
	running = NO;
}

- (void) goingToSleep: (NSNotification*) note {
#ifdef DEBUG_MODE
	DSLog(@"goingToSleep: %@", [note name]);
#endif
	
	systemGoingToSleep = YES;
	systemWakingUp = NO;
	
	[self doRealUpdate];
}

- (void) wakeFromSleep: (NSNotification*) note {
#ifdef DEBUG_MODE
	DSLog(@"wakeFromSleep: %@", [note name]);
#endif
	
	systemGoingToSleep = NO;
	systemWakingUp = YES;
	
    if (![self screenIsLocked]) 
        [self performSelector: @selector(wakeFinished) withObject: nil afterDelay: 30.0];
    else
        DSLog(@"system is still locked, waiting until unlocked");
	
	[self doRealUpdate];
}

- (void) wakeFinished {
    if (![self screenIsLocked]) {
        systemWakingUp = NO;
    }
    else {
        DSLog(@"screen is still locked, waiting until unlock");
    }
}

- (NSString *) friendlyName {
    return NSLocalizedString(@"Sleep/Wake Event", @"");
}

- (void) screenDidUnlock:(NSNotification *)notification {
    [super screenDidUnlock:nil];
    if (systemWakingUp)
        [self performSelector: @selector(wakeFinished) withObject: nil afterDelay: 30.0];
}

- (void) screenDidLock:(NSNotification *)notification {
    [super screenDidLock:nil];
}

@end
