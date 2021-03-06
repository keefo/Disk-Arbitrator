//
//  DiskArbitratorAppController+Toolbar.m
//  DiskArbitrator
//
//  Created by Aaron Burghardt on 2/7/10.
//  Copyright 2010 . All rights reserved.
//

#import "DiskArbitratorAppController+Toolbar.h"
#import "Disk.h"


@implementation AppController (AppControllerToolbar)

- (NSImage *)attachDiskImageIcon
{
	NSImage *dmgIcon = [[NSWorkspace sharedWorkspace] iconForFileType:@"dmg"];
	NSImage *plugImage = [NSImage imageNamed:@"ToolbarItem Attach Disk Plug"];
	
	NSBitmapImageRep *compositedImage = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:32 pixelsHigh:32 bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:0 bitsPerPixel:0];

	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:compositedImage]];
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	
	[dmgIcon drawInRect:NSMakeRect(0, 0, 32, 32) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
	[plugImage drawInRect:NSMakeRect(2, 16, 16, 16) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	
	[NSGraphicsContext restoreGraphicsState];

	return [[[NSImage alloc] initWithData:[compositedImage TIFFRepresentation]] autorelease];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
	NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
	
	if ([itemIdentifier isEqual:ToolbarItemInfoIdentifier]) {				// Info/Inspect
		[item setLabel:NSLocalizedString(@"Info", nil)];
		[item setPaletteLabel:NSLocalizedString(@"Info", nil)];
		[item setImage:[NSImage imageNamed:@"ToolbarItem Info"]]; // NSImageNameInfo]];
		[item setTarget:self];
		[item setAction:@selector(performGetInfo:)];
		[item setToolTip:NSLocalizedString(@"Show detailed disk info", nil)];
	} 
	else if ([itemIdentifier isEqual:ToolbarItemEjectIdentifier]) {		// Eject
		[item setLabel:NSLocalizedString(@"Eject", nil)];
		[item setPaletteLabel:NSLocalizedString(@"Eject", nil)];
		[item setImage:[NSImage imageNamed:@"ToolbarItem Eject"]];
		[item setTarget:self];
		[item setAction:@selector(performEject:)];
		[item setToolTip:NSLocalizedString(@"Eject removable media.", nil)];
	}
	else if ([itemIdentifier isEqual:ToolbarItemMountIdentifier]) {			// Mount
		[item setLabel:NSLocalizedString(@"Mount", nil)];
		[item setPaletteLabel:NSLocalizedString(@"Mount/Unmount", nil)];
		[item setImage:[NSImage imageNamed:@"ToolbarItem Mount"]];
		[item setTarget:self];
		[item setAction:@selector(performMountOrUnmount:)];
		[item setToolTip:NSLocalizedString(@"Select a volume, then click to mount or unmount.", nil)];
	}
	else if ([itemIdentifier isEqual:ToolbarItemAttachDiskImageIdentifier]) {			// Attach Disk Image
		[item setLabel:NSLocalizedString(@"Attach", nil)];
		[item setPaletteLabel:NSLocalizedString(@"Attach Disk Image", nil)];
//		[item setImage:[NSImage imageNamed:@"ToolbarItem Attach Disk Image"]];
		[item setImage:[self attachDiskImageIcon]];
		[item setTarget:self];
		[item setAction:@selector(performAttachDiskImage:)];
		[item setToolTip:NSLocalizedString(@"Attach Disk Image", nil)];
	}
	return [item autorelease];
}


//---------------------------------------------------------- 
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
	return [NSArray arrayWithObjects: 
			NSToolbarSeparatorItemIdentifier,
			NSToolbarSpaceItemIdentifier,
			NSToolbarFlexibleSpaceItemIdentifier,
			NSToolbarCustomizeToolbarItemIdentifier,
			ToolbarItemInfoIdentifier,
			ToolbarItemMountIdentifier,
			ToolbarItemEjectIdentifier,
			ToolbarItemAttachDiskImageIdentifier,
			nil];
}


//---------------------------------------------------------- 
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
	return [NSArray arrayWithObjects:   
			ToolbarItemInfoIdentifier,
			ToolbarItemEjectIdentifier,
			ToolbarItemMountIdentifier,
			NSToolbarSpaceItemIdentifier,
			ToolbarItemAttachDiskImageIdentifier,
			NSToolbarFlexibleSpaceItemIdentifier,
			NSToolbarCustomizeToolbarItemIdentifier, 
			nil];
}


//---------------------------------------------------------- 
-(BOOL)validateToolbarItem:(NSToolbarItem*)toolbarItem {
	BOOL enabled = YES;
	
    if ([[toolbarItem itemIdentifier] isEqual:ToolbarItemInfoIdentifier])
		enabled = YES;
	
	else if ([[toolbarItem itemIdentifier] isEqual:ToolbarItemMountIdentifier]) {

		// Enable the item if the disk is mountable
		// Set the label "Unmount" if mounted, otherwise to "Mount"
		
		if ([self canUnmountSelectedDisk]) {
			[toolbarItem setLabel:NSLocalizedString(@"Unmount", nil)];
			enabled	= YES;
		}
		else {
			[toolbarItem setLabel:NSLocalizedString(@"Mount", nil)];

			if (![self canMountSelectedDisk])
				enabled = NO;
		}
	}
	
	else if ([[toolbarItem itemIdentifier] isEqual:ToolbarItemEjectIdentifier]) {
		
		enabled = [self canEjectSelectedDisk];
	}
	
	return enabled;
}

@end


void SetupToolbar(NSWindow *window, id delegate)
{
	NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:ToolbarItemMainIdentifier];
	[toolbar setDelegate:delegate];
	[toolbar setAllowsUserCustomization:YES];
	[toolbar setAutosavesConfiguration:YES];
	[window setToolbar:[toolbar autorelease]];
}



// Toolbar Item Identifier constants
NSString * const ToolbarItemMainIdentifier = @"ToolbarItemMainIdentifier";
NSString * const ToolbarItemInfoIdentifier = @"ToolbarItemInfoIdentifier"; 
NSString * const ToolbarItemMountIdentifier = @"ToolbarItemMountIdentifier";
NSString * const ToolbarItemEjectIdentifier = @"ToolbarItemEjectIdentifier"; 
NSString * const ToolbarItemAttachDiskImageIdentifier = @"ToolbarItemAttachDiskImageIdentifier"; 

