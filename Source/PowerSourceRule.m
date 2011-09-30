//
//	PowerSourceRule.m
//	ControlPlane
//
//	Created by David Jennes on 24/09/11.
//	Copyright 2011. All rights reserved.
//

#import "PowerSourceRule.h"
#import "PowerSource.h"

@implementation PowerSourceRule

registerRuleType(PowerSourceRule)

#pragma mark - Source observe functions

- (void) powerSourceChangedWithOld: (ePowerSource) oldSource andNew: (ePowerSource) newSource {
	NSNumber *parameter = [self.data objectForKey: @"parameter"];
	
	if (newSource != kPowerError)
		self.match = (parameter.intValue == newSource);
}

#pragma mark - Required implementation of 'Rule' class

- (NSString *) name {
	return NSLocalizedString(@"Source", @"Rule type");
}

- (NSString *) category {
	return NSLocalizedString(@"Power", @"Rule category");
}

- (void) beingEnabled {
	Source *source = [SourcesManager.sharedSourcesManager registerRule: self toSource: @"PowerSource"];
	
	// currently a match?
	[self powerSourceChangedWithOld: kPowerError andNew: ((PowerSource *) source).powerSource];
}

- (void) beingDisabled {
	[SourcesManager.sharedSourcesManager unRegisterRule: self fromSource: @"PowerSource"];
}

- (NSArray *) suggestedValues {
	return [NSArray arrayWithObjects:
			[NSDictionary dictionaryWithObjectsAndKeys:
			 [NSNumber numberWithInt: kPowerBattery], @"parameter",
			 NSLocalizedString(@"Battery", @"PowerSourceRule suggestion description"), @"description",
			 nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
			 [NSNumber numberWithInt: kPowerAC], @"parameter",
			 NSLocalizedString(@"Power Adapter", @"PowerSourceRule suggestion description"), @"description",
			 nil],
			nil];
}

@end