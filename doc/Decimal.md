# Decimal type

It is difficult to find any test layouts to see if the encoding is done right. First a try is made using the _Decimal128 type in C supported by gcc. This type however is a Binary Integer Decimal (BID) which is not the proper one to compare with because the BSON type must be a Densely Packed Decimal(DPD). This, however, might come in handy later when the BID type will be supported too.

Much information is found about how to procede;
* [From MongoDB][mdb]
* [Decimal implementation and libraries][spelotrove]
* [Wiki Densely Packed Decimal][wiki]
* [The "Decimal Floating Point C Library" User's Guide][libdpd]
* [Extension for the programming language C to support decimal floating-point arithmetic][open-std]

### Densely packed decimal encoding rules

The table from wiki pages a bit reformed to suit the tests
```
                                sign
bytes d2,d1,d0   bits           d*
1098 7654 3210   98 7654 3210   210 Values encoded     Description

0abc 0def 0ghi   ab cdef 0ghi   000 (0-7) (0-7) (0-7)  Three small digits

0abc 0def 100i   ab cdef 100i   001 (0-7) (0-7) (8-9)  Two small
0abc 100f 0ghi   ab cghf 101i   010 (0-7) (8-9) (0-7)  digits, one
100c 0def 0ghi   gh cdef 110i   100 (8-9) (0-7) (0-7)  large

100c 100f 0ghi   gh c00f 111i   110 (8-9) (8-9) (0-7)  One small
100c 0def 100i   de c01f 111i   101 (8-9) (0-7) (8-9)  digit, two
0abc 100f 100i   ab c10f 111i   011 (0-7) (8-9) (8-9)  large

100c 100f 100i   .. c11f 111i   111 (8-9) (8-9) (8-9)  Three large digits
```


### Test examples
```
       d2   d1   d0      210    9          0    b1 b2
  n    0abc 0def 0ghi    enc    ab cdef 0ghi
001 -> 0000 0000 0001 -> 000 -> 00 0000 0001 -> 01 00   
245 -> 0010 0100 0101 -> 000 -> 01 0100 0101 -> 45 01

       0abc 0def 100i           ab cdef 100i
248 -> 0010 0100 1000 -> 001 -> 01 0100 1000 -> 48 01

       0abc 100f 0ghi           ab cghf 101i
295 -> 0010 1001 0101 -> 010 -> 01 0101 1011 -> 5b 01

       0abc 100f 100i           ab c10f 111i
298 -> 0010 1001 1000 -> 011 -> 01 0101 1110 -> 5e 01

       100c 0def 0ghi           gh cdef 110i
945 -> 1001 0100 0101 -> 100 -> 10 1100 1101 -> cd 02

       100c 0def 100i           de c01f 111i
948 -> 1001 0100 1000 -> 101 -> 10 1010 1110 -> ae 02

       100c 100f 0ghi           gh c00f 111i
895 -> 1000 1001 0101 -> 110 -> 10 0001 1111 -> 1f 02

       100c 100f 100i           .. c11f 111i
898 -> 1000 1001 1000 -> 111 -> 00 0111 1110 -> 7e 00


          19                        0                                b1 b2 b3
945 898 -> 10 1100 1101  00 0111 1110 -> 1011 0011 0100 0111 1110 -> 7e 34 0b

```

### Libraries
* download zipfile DFPALL unzip and go into directory dfpal
* (on linux) open Makefile.Linux and add option **-fPIC** to the **OPT_CFLAGS**
* run `make -f Makefile.Linux`
* set environment variable **LD_LIBRARY_PATH** to **dfpal** directory.
* make your own program using the lib (example in xt/d128-v1.c)

From this a program `d128-v1` is made to check the layout of a decimal 128 bit
Some examples;
```
$ xt/d128-v1 .001
N = .001
   0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x07, 0x22,

$ xt/d128-v1 10
N = 10
   0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x22,

$ xt/d128-v1 1e1
N = 1e1
   0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x08, 0x22,

$ xt/d128-v1 10e-1
N = 10e-1
   0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0xc0, 0x07, 0x22,
```

### Precision of digits
The following numbers have the same precision `1`, `0.1`, `0.001`, `1e1` etc.
as well as `101`, `1.01` or `0.000101e-10`
Different are `1` and `10` or `1e1` and `10`.

| n    | char | adj char | mantissa | precision | exponent | adj exp |
|------|------|----------|----------|-----------|----------|---------|
| 1001 | 1001 | | | 4 | 0 | 0 |
| 0.0012 | | 12 | 0012 | 2 | 0 | -4 |
| 11.02 | 11 | 1102 | 02 | 4 | 0 | -2 |
| 100 | 100 | 100 | | 3 | 0 | 0 |
| 1.02e2 | 1 | 102 | 02 | 3 | 2 | 0 |
| -23.03e-2 | 23 | 2303 | 03 | 4 | -2 | -4 |


[mdb]: https://github.com/mongodb/specifications/blob/master/source/bson-decimal128/decimal128.rst
[open-std]: http://www.open-std.org/JTC1/SC22/wg14/www/docs/n1312.pdf
[spelotrove]: http://speleotrove.com/decimal/
[wiki]: https://en.wikipedia.org/wiki/Densely_packed_decimal
[libdpd]: https://raw.githubusercontent.com/libdfp/libdfp/master/README.user
