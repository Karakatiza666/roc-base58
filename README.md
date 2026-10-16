# roc-base58

Base58 encode and decode for Roc, with the Bitcoin alphabet:

```text
123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz
```

| Function | Type | Result |
| --- | --- | --- |
| `Base58.encode` | `List(U8) -> Str` | The bytes as one big-endian number in base 58. Each leading zero byte is one leading `1`. |
| `Base58.decode` | `Str -> Try(List(U8), [InvalidChar(U64), TooLong(U64)])` | The bytes of the text. Each leading `1` is one leading zero byte. A text of more than 1024 UTF-8 bytes gives `TooLong(length)` (each list of at most 749 bytes encodes to at most 1024 bytes). A byte that is not in the alphabet (also whitespace) gives `InvalidChar(index)`, the index of the first such byte in the UTF-8 bytes of the text. |

## Usage

Add the release to the header of your app, package or platform:

```roc
b58: "https://github.com/Karakatiza666/roc-base58/releases/download/0.1.0/BgUuQGqWY94NikfEx4rBkWkgxYhngMim3ZEnD8wpM4NS.tar.zst",
```

Then:

```roc
import b58.Base58

expect Base58.encode([0, 0, 1]) == "112"
expect Base58.decode("2g") == Ok([0x61])
expect Base58.decode("2l") == Err(InvalidChar(1))
```

## Tests

| Layer | Files | Tool |
| --- | --- | --- |
| L0 | `tests/*.roc` | `roc test` |
| L1 | `fuzz/*.roc` (properties: round trip, leading `1`s, canonical text, decode never crashes) | [roc-fuzz](https://github.com/lukewilliamboswell/roc-fuzz) 0.4.3 |

`scripts/test.sh [ROC [FUZZ_ROC]]` runs `roc check`, `roc fmt --check`, the L0 tests and the L1 targets. Use the nightly in `.roc-version`. CI (`.github/workflows/ci.yml`) runs the same checks on that nightly.

`tests/bitcoin_vectors.roc` has the test vectors of Bitcoin Core (MIT license, see the file). `tests/roc_hashes.roc` has the BLAKE3 digests of Roc package release assets and their base58 names. `scripts/blake3-vectors.sh` computes them again.

## Release

`.github/workflows/release.yml` makes a release with [roc-lang/release-package](https://github.com/roc-lang/release-package): `gh workflow run release.yml --ref main -f release_version=X.Y.Z`. The tag is `X.Y.Z` with no prefix, and the one package asset is `<hash>.tar.zst` from `roc bundle`.

## License

UPL-1.0, see `LICENSE`.
