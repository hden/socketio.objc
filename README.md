socketio.objc
=============

socket.io v1.0.0+ for iOS and OS X

Why?
----

Socket.IO v1.0.0 is a major refactoring of the popular real-time framework.
Unfortunatelly the communication protocal has changed drastically, thus
most of the existing obj-c library won't work with v1.0.0.

This project is aimed for a near 1:1 port of the official framework. Including
engine.io, which is the foundation of socket.io.

Goals / Progress
----------------

* [done] engine.io-parser with official test suite
* [almost done] engine.io-client with official test suite
* [done] socket.io-parser with official test suite
* socket.io-client with official test suite

Design
------

    ------------------------------------------
    |            socket.io client            |
    ------------------------------------------
            ⬆ ⬇                 ⬆ ⬇
    --------------------  --------------------
    | socket.io parser |  | engine.io client |
    --------------------  --------------------
                                 ⬆ ⬇
                          --------------------
                          | engine.io parser |
                          --------------------
                                 ⬆ ⬇
                          --------------------
                          | transport layers |
                          --------------------

FAQ
---

- What's engine.io?
  - http://stackoverflow.com/questions/9610951/how-is-engine-io-different-from-socket-io

- I just want engine.io, can I use this project?
  - Yes, both engine.io client & parser are exposed for your convenience.

Development
-----------

    cd Test
    pod install
    open ../SocketIO.objc.xcworkspace

Licence
-------

MIT
