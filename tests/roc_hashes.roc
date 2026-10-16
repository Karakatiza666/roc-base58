app [main!] { pkg: "../package/main.roc" }

import pkg.Base58

main! = |_args| Ok({})

# Source: Talon DESIGN.md 2 (the hash form of roc). The name of a roc package
# release asset is `<hash>.tar.zst`, where `<hash>` is the base58 text of the
# 32-byte BLAKE3 digest of the `.tar.zst` bytes. Rule: R-PK3 (DESIGN.md 6.1).
#
# The hex digests come from scripts/blake3-vectors.sh: it downloads each asset
# and prints Crypto.BLAKE3 of the file (tests/tools/blake3_hex.roc), with the
# pinned roc nightly-2026-10-09-258ab27, on 2026-10-16. The names are the
# asset names of the releases. roc itself checks that the name and the digest
# agree when it downloads the package (`roc check` of a header with the URL).

# Test helper: the bytes of hex text (lower case, even length).
hex : Str -> List(U8)
hex = |text| {
	nibble = |c| if c >= 'a' c - 'a' + 10 else c - '0'
	text.to_utf8().chunks_of(2).map(|pair| nibble(pair.get(0) ?? '0') * 16 + nibble(pair.get(1) ?? '0'))
}

# https://github.com/lukewilliamboswell/roc-parser/releases/download/2.0.0/7CLzCK6qUz7zmj6nvBxMEFu11HPwQTnCovKiyWzDSLTW.tar.zst
roc_parser_digest = "5c0e1bdcc3af4d9454007c72e6b1c9d8e1ad80d0f75ba5b467f6560784696d35"

roc_parser_name = "7CLzCK6qUz7zmj6nvBxMEFu11HPwQTnCovKiyWzDSLTW"

# https://github.com/roc-lang/unicode/releases/download/4.2.0/4W8SHzvwet9hH9qZewJ1J1CVQoH7YKA6zyijWFTB3y1w.tar.zst
unicode_digest = "34094fefd57640a5f6b6586ef5aa637c857cf8814b262b234c184e4c8d401d46"

unicode_name = "4W8SHzvwet9hH9qZewJ1J1CVQoH7YKA6zyijWFTB3y1w"

# R-PK3, Design 2: the BLAKE3 digest of the roc-parser 2.0.0 asset encodes to its asset name
expect Base58.encode(hex(roc_parser_digest)) == roc_parser_name

# R-PK3, Design 2: the roc-parser 2.0.0 asset name decodes to the 32 bytes of its digest
expect Base58.decode(roc_parser_name) == Ok(hex(roc_parser_digest))

# R-PK3, Design 2: the BLAKE3 digest of the unicode 4.2.0 asset encodes to its asset name
expect Base58.encode(hex(unicode_digest)) == unicode_name

# R-PK3, Design 2: the unicode 4.2.0 asset name decodes to the 32 bytes of its digest
expect Base58.decode(unicode_name) == Ok(hex(unicode_digest))

# R-PK3, Design 2, BTC: a 32-byte digest with 2 leading zero bytes keeps them
# (the bytes of the roc-parser digest after 2 zero bytes, cut to 32)
expect {
	digest = [0, 0].concat(hex(roc_parser_digest).take_first(30))
	text = Base58.encode(digest)
	text.starts_with("11") and !text.starts_with("111") and Base58.decode(text) == Ok(digest)
}
