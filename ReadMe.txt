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
ButtonOverlayView.mButtonOverlayView.h
- Implements a button overly window containing Exit and Pause buttons that resides on top of the fullscreen movie window.

FullScreen.xib
- The nib file containing the fullscreen window

MyDocument.xib
- The nib file that implements the NSDocument subclass

MainMenu.xib
- The nib file containing the main window.



===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.0
- First version.

===========================================================================
Copyright (C) 2009 Apple Inc. All rights reserved.
