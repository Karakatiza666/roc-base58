app [main!] { pkg: "../package/main.roc" }

import pkg.Base58

main! = |_args| Ok({})

# Source of the vectors: Bitcoin Core, src/test/data/base58_encode_decode.json
# at commit 5dd3a0d8a899e4c7263d5b999135f4d7584e1244 (the last commit that
# changed the file), all 21 pairs, in the order of the file:
# https://raw.githubusercontent.com/bitcoin/bitcoin/5dd3a0d8a899e4c7263d5b999135f4d7584e1244/src/test/data/base58_encode_decode.json
# sha256 of that file: 20d51011f49339714c28b9244cc5238f4c78bb9206dc8fc61500aed6fc2682ca
# Each pair is [hex of the bytes, base58 text]. Each pair gives one encode
# test and one decode test. Rule: R-PK3 (Talon DESIGN.md 6.1), BTC (the
# Bitcoin base58 rules).
#
# License of the copied vectors (Bitcoin Core COPYING at the same commit):
#
# The MIT License (MIT)
#
# Copyright (c) 2009-2024 The Bitcoin Core developers
# Copyright (c) 2009-2024 Bitcoin Developers
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Test helper: the bytes of hex text (upper or lower case, even length).
hex : Str -> List(U8)
hex = |text| {
	nibble = |c| if c >= 'a' c - 'a' + 10 else if c >= 'A' c - 'A' + 10 else c - '0'
	text.to_utf8().chunks_of(2).map(|pair| nibble(pair.get(0) ?? '0') * 16 + nibble(pair.get(1) ?? '0'))
}

# R-PK3, BTC: Bitcoin Core vector 1 of 21
expect Base58.encode(hex("")) == ""
expect Base58.decode("") == Ok(hex(""))

# R-PK3, BTC: Bitcoin Core vector 2 of 21
expect Base58.encode(hex("61")) == "2g"
expect Base58.decode("2g") == Ok(hex("61"))

# R-PK3, BTC: Bitcoin Core vector 3 of 21
expect Base58.encode(hex("626262")) == "a3gV"
expect Base58.decode("a3gV") == Ok(hex("626262"))

# R-PK3, BTC: Bitcoin Core vector 4 of 21
expect Base58.encode(hex("636363")) == "aPEr"
expect Base58.decode("aPEr") == Ok(hex("636363"))

# R-PK3, BTC: Bitcoin Core vector 5 of 21
expect Base58.encode(hex("73696d706c792061206c6f6e6720737472696e67")) == "2cFupjhnEsSn59qHXstmK2ffpLv2"
expect Base58.decode("2cFupjhnEsSn59qHXstmK2ffpLv2") == Ok(hex("73696d706c792061206c6f6e6720737472696e67"))

# R-PK3, BTC: Bitcoin Core vector 6 of 21
expect Base58.encode(hex("00eb15231dfceb60925886b67d065299925915aeb172c06647")) == "1NS17iag9jJgTHD1VXjvLCEnZuQ3rJDE9L"
expect Base58.decode("1NS17iag9jJgTHD1VXjvLCEnZuQ3rJDE9L") == Ok(hex("00eb15231dfceb60925886b67d065299925915aeb172c06647"))

# R-PK3, BTC: Bitcoin Core vector 7 of 21
expect Base58.encode(hex("516b6fcd0f")) == "ABnLTmg"
expect Base58.decode("ABnLTmg") == Ok(hex("516b6fcd0f"))

# R-PK3, BTC: Bitcoin Core vector 8 of 21
expect Base58.encode(hex("bf4f89001e670274dd")) == "3SEo3LWLoPntC"
expect Base58.decode("3SEo3LWLoPntC") == Ok(hex("bf4f89001e670274dd"))

# R-PK3, BTC: Bitcoin Core vector 9 of 21
expect Base58.encode(hex("572e4794")) == "3EFU7m"
expect Base58.decode("3EFU7m") == Ok(hex("572e4794"))

# R-PK3, BTC: Bitcoin Core vector 10 of 21
expect Base58.encode(hex("ecac89cad93923c02321")) == "EJDM8drfXA6uyA"
expect Base58.decode("EJDM8drfXA6uyA") == Ok(hex("ecac89cad93923c02321"))

# R-PK3, BTC: Bitcoin Core vector 11 of 21
expect Base58.encode(hex("10c8511e")) == "Rt5zm"
expect Base58.decode("Rt5zm") == Ok(hex("10c8511e"))

# R-PK3, BTC: Bitcoin Core vector 12 of 21
expect Base58.encode(hex("00000000000000000000")) == "1111111111"
expect Base58.decode("1111111111") == Ok(hex("00000000000000000000"))

# R-PK3, BTC: Bitcoin Core vector 13 of 21
expect Base58.encode(hex("00000000000000000000000000000000000000000000000000000000000000000000000000000000")) == "1111111111111111111111111111111111111111"
expect Base58.decode("1111111111111111111111111111111111111111") == Ok(hex("00000000000000000000000000000000000000000000000000000000000000000000000000000000"))

# R-PK3, BTC: Bitcoin Core vector 14 of 21
expect Base58.encode(hex("00000000000000000000000000000000000000000000000000000000000000000000000000000001")) == "1111111111111111111111111111111111111112"
expect Base58.decode("1111111111111111111111111111111111111112") == Ok(hex("00000000000000000000000000000000000000000000000000000000000000000000000000000001"))

# R-PK3, BTC: Bitcoin Core vector 15 of 21
expect Base58.encode(hex("0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ec39d04c37e71e5d591881f6")) == "111111111111111111111111111111111111111111111111111111111111111111111111111111111111115TYzLYH1udmLdzCLM"
expect Base58.decode("111111111111111111111111111111111111111111111111111111111111111111111111111111111111115TYzLYH1udmLdzCLM") == Ok(hex("0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ec39d04c37e71e5d591881f6"))

# R-PK3, BTC: Bitcoin Core vector 16 of 21
expect Base58.encode(hex("000111d38e5fc9071ffcd20b4a763cc9ae4f252bb4e48fd66a835e252ada93ff480d6dd43dc62a641155a5")) == "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
expect Base58.decode("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz") == Ok(hex("000111d38e5fc9071ffcd20b4a763cc9ae4f252bb4e48fd66a835e252ada93ff480d6dd43dc62a641155a5"))

# R-PK3, BTC: Bitcoin Core vector 17 of 21
expect Base58.encode(hex("000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff")) == "1cWB5HCBdLjAuqGGReWE3R3CguuwSjw6RHn39s2yuDRTS5NsBgNiFpWgAnEx6VQi8csexkgYw3mdYrMHr8x9i7aEwP8kZ7vccXWqKDvGv3u1GxFKPuAkn8JCPPGDMf3vMMnbzm6Nh9zh1gcNsMvH3ZNLmP5fSG6DGbbi2tuwMWPthr4boWwCxf7ewSgNQeacyozhKDDQQ1qL5fQFUW52QKUZDZ5fw3KXNQJMcNTcaB723LchjeKun7MuGW5qyCBZYzA1KjofN1gYBV3NqyhQJ3Ns746GNuf9N2pQPmHz4xpnSrrfCvy6TVVz5d4PdrjeshsWQwpZsZGzvbdAdN8MKV5QsBDY"
expect Base58.decode("1cWB5HCBdLjAuqGGReWE3R3CguuwSjw6RHn39s2yuDRTS5NsBgNiFpWgAnEx6VQi8csexkgYw3mdYrMHr8x9i7aEwP8kZ7vccXWqKDvGv3u1GxFKPuAkn8JCPPGDMf3vMMnbzm6Nh9zh1gcNsMvH3ZNLmP5fSG6DGbbi2tuwMWPthr4boWwCxf7ewSgNQeacyozhKDDQQ1qL5fQFUW52QKUZDZ5fw3KXNQJMcNTcaB723LchjeKun7MuGW5qyCBZYzA1KjofN1gYBV3NqyhQJ3Ns746GNuf9N2pQPmHz4xpnSrrfCvy6TVVz5d4PdrjeshsWQwpZsZGzvbdAdN8MKV5QsBDY") == Ok(hex("000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff"))

# R-PK3, BTC: Bitcoin Core vector 18 of 21
expect Base58.encode(hex("271F359E")) == "zzzzy"
expect Base58.decode("zzzzy") == Ok(hex("271F359E"))

# R-PK3, BTC: Bitcoin Core vector 19 of 21
expect Base58.encode(hex("271F359F")) == "zzzzz"
expect Base58.decode("zzzzz") == Ok(hex("271F359F"))

# R-PK3, BTC: Bitcoin Core vector 20 of 21
expect Base58.encode(hex("271F35A0")) == "211111"
expect Base58.decode("211111") == Ok(hex("271F35A0"))

# R-PK3, BTC: Bitcoin Core vector 21 of 21
expect Base58.encode(hex("271F35A1")) == "211112"
expect Base58.decode("211112") == Ok(hex("271F35A1"))
