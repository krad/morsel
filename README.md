# morsel

[![Build Status](https://travis-ci.org/krad/morsel.svg?branch=master)](https://travis-ci.org/krad/morsel)

[Read the Docs](http://www.krad.io/morsel)

morsel is a library for creating streaming audio/video assets.

It can produce a series of fragmented mp4 files with HLS playlists.

It is compatible with Linux, macOS, iOS, and tvOS.

Supported playlist types:
   * VOD (Video On Demand) Basic
   * Event Basic
   * Live (Sliding Window)


Uses
====

morsel can be used to produce audio and video assets suitable for streaming over the web using [HLS (HTTP Live Streaming)] (https://developer.apple.com/streaming/)

morsel can be used on a Linux server in the cloud using [pupil](https://github.com/krad/pupil) to capture the audio/video over TCP.

It can also be used in an iOS / iPad app and capture data directly from the device's camera / microphone.

It can also be used on your macOS Desktop.
