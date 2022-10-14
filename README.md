# modular-arithmetic
An attempt to implement basic modular arithmetic library (and some stuff from number theory) in educational purposes.
## Features:
- supporting every numeric type with generics
- solving linear congruences when there are one solution
- finding inverse
- raising to exponent
- gcd, euler function, fermat test and prime number generation
- tests

## Non-features, bugs and TODO:
- ~~negative exponentiation~~ fixed
- solving congruences with more than one solution
- fix all that mess with initNegative and initPositive
- ~~maybe add some Miller–Rabin primality test to get prime numbers?~~
  - added Fermat test, going to add more modern

## How to get anything?
Just clone it with git and type ```zig build test```