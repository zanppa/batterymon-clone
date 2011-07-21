# batterymon-clone

## Summary

**batterymon-clone** is a simple battery monitor tray icon.

* Written in `Python`
* Should work on any desktop environment
* Very little dependencies: just `Python` and `PyGTK`
* Optional support for `notify-python`, for notifications using `libnotify`

The current implementation reads battery information from `/proc/acpi/`, and updates the state by polling every few seconds. Previous versions used DBus and HAL, but HAL has been deprecated and is not available anymore on some distros.

## History

**batterymon-clone** is a fork of **batterymon**

[**batterymon**][1] was originally written in mid-2009 by _Matthew Horsell_ and _Tomas Kramar_, and was available at Google Code.

It was later forked in 2010 as [**batterymon-clone**][2] by _sayamindu_ on GitHub.

After a long time without commits, _denilsonsa_ [forked][3] and updated it in mid-2011.

Each one of the authors contributed a little in order to make _batterymon_ a better software for their own needs. You can also contribute! Feel free to fork this code and improve it!

[1]: http://code.google.com/p/batterymon/
[2]: https://github.com/sayamindu/batterymon-clone
[3]: https://github.com/denilsonsa/batterymon-clone

## Future improvements

* Some code cleanup
* Add back support to DBus, but using newer interfaces. See [battery-status][batterystatus] project for inspiration.
  * But polling support should still be kept as fall-back.

[batterystatus] https://github.com/ia/battery-status/blob/master/battery-status

