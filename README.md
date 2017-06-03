# Support for Decimal types

[![Build Status](https://travis-ci.org/MARTIMM/Decimal.svg?branch=master)](https://travis-ci.org/MARTIMM/Decimal) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/Decimal/bson?branch=master&passingText=Windows%20-%20OK&failingText=Windows%20-%20FAIL&pendingText=Windows%20-%20pending&svg=true)](https://ci.appveyor.com/project/MARTIMM/Decimal/branch/master) [![License](http://martimm.github.io/label/License-label.svg)](http://www.perlfoundation.org/artistic_license_2_0)


Implements Densely Packed Decimal (**DPD**) for 128 bit Decimal types. Future may bring shorter types like 32 and 64 bit Decimals. For the moment it tries to be a container from which the number can be set to a byte buffer and retrieved in several number types. All will be coded in perl6. Later, arithmetic procedures are added when native libraries can be installed while installing the module.


## Synopsis


## Documentation

### This project

* [Release notes][changes]
* [Bugs, todo][todo]

### References
* [Decimal128 floating-point format][wiki1]
* [Wiki DPD howto][wiki2]
* [Decimal implementation and libraries at spelotrove][spelotrove1]
* [The "Decimal Floating Point C Library" User's Guide][clib1]

### Markdown

The markdown documents are written with the **Atom** plugin **markdown-preview-enhanced**. The default markdown viewer is disabled. This gives all sorts of possibilities such as showing UML and Gantt charts. When the document doesn't show some graphics, then look for the `pdf` documents in the `doc` directory.


## Installing Decimal

Use zef to install the package like so.
```
$ zef install Decimal
```

## Version PERL 6 and MoarVM

This module is tested using the latest perl6 version on MoarVM


## Author

Marcel Timmerman (MARTIMM on github)



[changes]: https://github.com/MARTIMM/Decimal/blob/master/doc/CHANGES.md
[todo]: https://github.com/MARTIMM/Decimal/blob/master/doc/TODO.md

[wiki1]: https://en.wikipedia.org/wiki/Decimal128_floating-point_format
[wiki2]: https://en.wikipedia.org/wiki/Densely_packed_decimal
[spelotrove1]: http://speleotrove.com/decimal/
[clib1]: https://raw.githubusercontent.com/libdfp/libdfp/master/README.user
