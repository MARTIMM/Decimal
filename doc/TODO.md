# Bugs and Todo notes

## Todo

This project is started within the BSON project to have a specific type, namely Decimal128, available. Other types are not needed as well as arithmetic operations, as long that the number could be retrieved in the native language such as FatRat, Rat and Num. Str type can be added and for tests a Bool type to see if the object is defined and non zero.

The reason to refactor is that this could be added later which do not concern the BSON project such as the afore mentioned arithmetic operations. Furthermore, there are C-libraries which could be installed and then use the nativeCall interface to use the library's API.


### class model

```plantuml

package "Decimal" #d0d0d0{
  class "Decimal::Dxxx" as Dxxx << (R,#ff8f11) Role >>
  class "Decimal::D128" as D128
  class "Decimal::Grammar" as G << (G,#ffff11) Grammar >>
  class "Decimal::Actions" as A

  Dxxx <|-- D128
  Dxxx *-> G
  Dxxx *--> A
}

```
All constants and subs are going into the package **Decimal**. The common routines are defined in the role **Decimal::Dxx**. The specific methods for some type are set in e.g. class **Decimal::D128**. The **Decimal::Grammar** and **Decimal::Actions** are used to parse strings representations of the number.


### Todo priority list

* [x] reading from FatRat, Rat and Num type numbers
* [x] reading from string with parsing
* [x] output to FatRat, Rat and Num type numbers
* [x] output to string
* [x] test for definedness and 0 with Bool
* [x] encode from decmal string to BCD in a nibble or byte
* [ ] decode from BCD in a nibble or byte to decimal string
* [x] encode BCD (one digit per byte) into densely packed decimal (DPD).
* [ ] decode DPD to BCD
* [ ] encoding 128 bit decimal type into Buf.
* [ ] decoding Buf into 128 bit decimal type.

### Todo list for later additions

* [ ] support for Decimal 32 bit type.
* [ ] support for Decimal 64 bit type.
* [ ] make use of c-library from spelotrove. Now it is used to check the resulting formats.
* [ ] add arithmetic operations.


## Bugs
