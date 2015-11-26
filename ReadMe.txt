### MyMediaPlayer ###

===========================================================================
DESCRIPTION:

Demonstrates how to play a movie fullscreen using QTKit on Mac OS X 10.6. Handles movie load states. Implements play, pause and fullscreen functionality. Provides an overly window with exit and pause buttons during fullscreen playback.

===========================================================================
BUILD REQUIREMENTS:

Mac OS X 10.6

===========================================================================
RUNTIME REQUIREMENTS:

Mac OS X 10.6

===========================================================================
PACKAGING LIST:

MyDocument.mMyDocument.h
- NSDocument subclass that implements a fullscreen movie player. Displays a movie in a document window. Handles movie load states as they change. Implements Play, Pause and Fullscreen buttons.

FullScreenWindow.m
FullScreenWindow.h
- Implements the fullscreen player window functionality. Handles ESC key or Cmd-period keys while in fullscreen mode.

FullScreenOverlayWindowController.m
FullScreenOverlayWindowController.h- Window controller for the fullscreen overlay window, handles the Play/Pause button.

FullScreen.xib
- The nib file containing the fullscreen window

MyDocument.xib
- The nib file that implements the NSDocument subclass

MainMenu.xib
- The nib file containing the main window.



===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 2.0
- Now handles screen resolution changes on the fly while in fullscreen mode. Command-F key toggles fullscreen. Updated to better demonstrate Cocoa coding best practices.

Version 1.0
- First version.

===========================================================================
Copyright (C) 2009 Apple Inc. All rights reserved.
