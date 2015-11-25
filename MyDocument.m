/*

File: MyDocument.m

Abstract: A NSDocument subclass that implements a fullscreen movie player.

Version: 1.0

Disclaimer: IMPORTANT:  This Apple software is supplied to you by 
Apple Inc. ("Apple") in consideration of your agreement to the
following terms, and your use, installation, modification or
redistribution of this Apple software constitutes acceptance of these
terms.  If you do not agree with these terms, please do not use,
install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software. 
Neither the name, trademarks, service marks or logos of Apple Inc. 
may be used to endorse or promote products derived from the Apple
Software without specific prior written permission from Apple.  Except
as expressly stated in this notice, no other rights or licenses, express
or implied, are granted by Apple herein, including but not limited to
any patent rights that may be infringed by your derivative works or by
other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2009 Apple Inc. All Rights Reserved.

*/

#import "MyDocument.h"

@implementation MyDocument

-(NSString *)windowNibName 
{
    return @"MyDocument";
}

-(void)dealloc 
{
    /* unregister with notification center */
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

-(void)handleLoadStateChanged:(QTMovie *)movie 
{
	NSInteger loadState = [[movie attributeForKey:QTMovieLoadStateAttribute] longValue];

	/*
	 The QuickTime movie load states are defined as follows (see QTMovie.h):
	 
	 QTMovieLoadStateError				= -1L,			// an error occurred while loading the movie
	 QTMovieLoadStateLoading			= 1000,			// the movie is loading
	 QTMovieLoadStateLoaded				= 2000,			// the movie atom has loaded; it's safe to query movie properties
	 QTMovieLoadStatePlayable			= 10000,		// the movie has loaded enough media data to begin playing
	 QTMovieLoadStatePlaythroughOK		= 20000,		// the movie has loaded enough media data to play through to the end
	 QTMovieLoadStateComplete			= 100000L		// the movie has loaded completely
	 
	 */
	
	if (loadState == QTMovieLoadStateError) {
		/* what goes here is app-specific */
		/* you can query QTMovieLoadStateErrorAttribute to get the error code, if it matters */
		/* for example:
		/* NSError *err = [movie attributeForKey:QTMovieLoadStateErrorAttribute]; */
		/* you might also need to undo some operations done in the other state handlers */
	}
	
	if ((loadState >= QTMovieLoadStateLoaded) && ([mMovieView movie] == nil)) {
		/* can query properties here */
		/* for instance, if you need to size a QTMovieView based on the movie's natural size, you can do so now */
		/* you can also put the movie into a view now, even though no media data might yet be available and hence
		   nothing will be drawn into the view */
		
		[mMovieView setMovie:movie];
	}
	
	if ((loadState >= QTMovieLoadStatePlayable) && ([movie rate] == 0.0f)) {
		/* can start movie playing here */
	}
}

/* This method called when the load state of a movie has changed */
-(void)movieLoadStateChanged:(NSNotification *)notification 
{
	QTMovie *movie = (QTMovie *)[notification object];
	
	if (movie) {
		[self handleLoadStateChanged:movie];
	}
}

-(void)displayAlertForError:(NSError *)error 
{
	NSAlert *theAlert = [NSAlert alertWithError:error];
	/* display the error */
	[theAlert runModal];
}

-(BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError 
{
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys: 
												absoluteURL, QTMovieURLAttribute, 
	/* Set the QTMovieOpenForPlaybackAttribute attribute to indicate that you intend to use movie playback methods (such as -play or -stop, 
	or corresponding movie view methods such as -play: or -pause:) to control the movie, but do not intend to use other methods that edit,
	export, or in any way modify the movie. Knowing that you need playback services only may allow QTMovie to use more efficient code paths
	for some media files. */
						[NSNumber numberWithBool:YES], QTMovieOpenForPlaybackAttribute ,
	/* Set the QTMovieOpenAsyncRequiredAttribute attribute to indicate that all operations necessary to open the movie file (or other container)
	and create a valid QTMovie object must occur asynchronously. That is to say, the methods +movieWithAttributes:error: and -initWithAttributes:error: 
	must return almost immediately, performing any lengthy operations on another thread. Your application can monitor the movie load state to 
	determine the progress of those operations.*/
						[NSNumber numberWithBool:YES], QTMovieOpenAsyncRequiredAttribute,
						nil]; 
						
	NSError *error = nil;
	QTMovie *movie = [QTMovie movieWithAttributes:attrs error:&error];
	if (movie && !error) {
		
		/* Check movie load state immediately in case a change occurred */
		[self handleLoadStateChanged:movie];
		
		/* Register to receive movie load state change notifications */
		[[NSNotificationCenter defaultCenter] addObserver:self
												selector:@selector(movieLoadStateChanged:) 
													name:QTMovieLoadStateDidChangeNotification 
												   object:nil];
		return YES;
	} else {
		[self displayAlertForError:error];
        
		return NO;
	}
}

-(IBAction)play:(id)sender 
{
	/* play the movie in the QTMovieView */
	[mMovieView play:sender];
}

-(IBAction)pause:(id)sender 
{
	/* pause the movie in the QTMovieView */
	[[mMovieView movie] stop];
}

-(IBAction)playPauseFullscreenMovie:(id)sender 
{
	QTMovie *movie;
	movie = [mFullscreenMovieView movie];
	
	/* toggle the movie play state in the fullscreen view and
	   set the Play/Pause button title to reflect the current 
	   play state */
	   
	if ([movie rate] != 0.0) {
		[mPlayPauseFullscreenButton setTitle:@"Play"];
		[movie stop];
	} else {
		[mPlayPauseFullscreenButton setTitle:@"Pause"];
		[movie play];
	}
}

-(void)createButtonOverlayWindow 
{
	/* create an overlay window with "Exit" and "Play" buttons that
		will reside on top of the fullscreen movie window */
		
    NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
    ButtonOverlayWindow *overlayWindow = 
		[[ButtonOverlayWindow alloc] initWithContentRect:NSMakeRect((NSWidth([screen frame])/2)-150,60,265,70)
																	styleMask:NSBorderlessWindowMask 
																	backing:NSBackingStoreBuffered 
																	defer:YES];
    [overlayWindow setOpaque:NO];
    [overlayWindow setHasShadow:YES];
    [overlayWindow setBackgroundColor:[NSColor grayColor]];
    [overlayWindow setAlphaValue:0.4];
	[overlayWindow setMovableByWindowBackground:YES];
	[overlayWindow setDelegate:self];
	[overlayWindow makeKeyAndOrderFront:nil];

	/* create the Exit button and add it to the overlay window */
	NSRect buttonRect = NSMakeRect(25, 20, 100, 25);
	NSButton *doneButton = [[NSButton alloc] initWithFrame:buttonRect];
	[doneButton setTitle:@"Exit"];
	[doneButton setAction:@selector(exitFullScreen:)];
	[[overlayWindow contentView] addSubview:doneButton];
	[doneButton release];

	/* create the Play/Pause button and add it to the overlay window */
	NSRect playbuttonRect = NSMakeRect(140, 20, 100, 25);
	mPlayPauseFullscreenButton = [[NSButton alloc] initWithFrame:playbuttonRect];
	if ([[mFullscreenMovieView movie] rate] != 0.0) {
		[mPlayPauseFullscreenButton setTitle:@"Pause"];
	} else {
		[mPlayPauseFullscreenButton setTitle:@"Play"];
	}
	[mPlayPauseFullscreenButton setAction:@selector(playPauseFullscreenMovie:)];
	[[overlayWindow contentView] addSubview:mPlayPauseFullscreenButton];

    /* add the overlay window as a child window of the main window */
    [mFullscreenWindow addChildWindow:overlayWindow ordered:NSWindowAbove];

	[overlayWindow release];
}

-(IBAction)goFullScreen:(id)sender 
{
	if (!mFullscreenView) {
		[NSBundle loadNibNamed:@"FullScreen" owner:self];
		[mFullscreenWindow retain];
	}

/*
	Cocoa provides the enterFullScreenMode: method which
    sets the receiver to full screen mode: 

	@try {
		NSDisableScreenUpdates();

		[mMovieView setMovie:nil];
		[mFullscreenMovieView setMovie:[mMovieView movie];
		
		[mFullscreenView enterFullScreenMode:[[NSScreen screens] objectAtIndex:0] withOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:NSNormalWindowLevel] forKey:NSFullScreenModeWindowLevel]];
	}
	@finally {
		NSEnableScreenUpdates();
	}
 
   However, there is currently a bug (r.6862814) which prevents 
   this method from working with QTMovieView. Until the bug is 
   fixed, use the code shown below to go full screen:
 
*/

	/* Capture all attached displays to prevent other applications
	 from trying to adjust to display changes. */
	 
    if (CGCaptureAllDisplays() != kCGErrorSuccess) {
        return;
    }

    NSRect screenRect;
	NSScreen *screen;
	
    screen = [[NSScreen screens] objectAtIndex:0];
	screenRect = [screen frame];

    mFullscreenWindow = [[NSWindow alloc] initWithContentRect:screenRect
													styleMask:NSBorderlessWindowMask
													  backing:NSBackingStoreBuffered
														defer:NO screen:screen];
    
	QTMovie *movie = [[mMovieView movie] retain];
	[mMovieView setMovie:nil];
	[mFullscreenMovieView setMovie:movie];
	[movie release];

	/* Get the window level of the shield window for a captured display */
	int windowLevel;
	windowLevel = CGShieldingWindowLevel();
	
	[mFullscreenWindow setLevel:windowLevel];
	[mFullscreenWindow setBackgroundColor:[NSColor blackColor]];
	[mFullscreenWindow setReleasedWhenClosed:YES];

	/* move the capture view into fullscreen */
	[mFullscreenView retain];

	[mFullscreenView removeFromSuperviewWithoutNeedingDisplay];
	[[mFullscreenWindow contentView] addSubview:mFullscreenView];
	[mFullscreenView release];
	mSaveViewRect = [mFullscreenView frame]; /* remember the current rect/size */
	[mFullscreenView setFrame:[[mFullscreenWindow contentView] bounds]];
    [mFullscreenWindow setDelegate:self];
    [mFullscreenWindow makeKeyAndOrderFront:nil];
	
	[self createButtonOverlayWindow];
}

-(IBAction)exitFullScreen:(id)sender 
{

/*
 Cocoa provides the exitFullScreenModeWithOptions: method which
 instructs the receiver to exit full screen mode:

	@try {
		NSDisableScreenUpdates();
		[mFullscreenMovieView setMovie:nil];
		[mMovieView setMovie:[mMovieView movie]];
		[mFullscreenView exitFullScreenModeWithOptions:nil];
	}
	@finally {
		NSEnableScreenUpdates();
	}
 
 However, there is currently a bug (r.6862814) which prevents 
 this method from working with QTMovieView. Until the bug is 
 fixed, use the code shown below to exit full screen mode:
 
*/
	
	CGReleaseAllDisplays();
	
	QTMovie *movie = [[mFullscreenMovieView movie] retain];
	[mFullscreenMovieView setMovie:nil];
	[mMovieView setMovie:movie];
	[movie release];
	
	// move captureview back
	[mFullscreenView retain];
	[mFullscreenView removeFromSuperviewWithoutNeedingDisplay];
	[[mFullscreenWindow contentView] addSubview:mFullscreenView];
	[mFullscreenView release];
	
	[mPlayPauseFullscreenButton release];
	mPlayPauseFullscreenButton = nil;
	
	[mFullscreenView setFrame:mSaveViewRect];
	[mFullscreenWindow close];
	mFullscreenWindow = nil;
	mFullscreenView = nil;
	
	[mMovieWindow makeKeyAndOrderFront:self];	
}

@end

@implementation ButtonOverlayWindow

-(BOOL)canBecomeKeyWindow 
{
	return YES;
}

-(void)keyDown:(NSEvent *)theEvent 
{
    /* check if the Escape key is pressed */
	if ([[theEvent characters] characterAtIndex:0] == 0x1B ) { //unicode 'esc'
        /* exit fullscreen */
        [(MyDocument *)[self delegate] exitFullScreen:self];
	} else {
		[super keyDown:theEvent];
	}
}

@end
