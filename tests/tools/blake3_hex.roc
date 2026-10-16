# Prints the BLAKE3-256 digest of asset.tar.zst as lowercase hex, with the
# roc builtin (Crypto.BLAKE3). scripts/blake3-vectors.sh copies this file and
# one release asset into one directory, because the embed path is fixed.
import "asset.tar.zst" as data : List(U8)

main! = |_args| {
	echo!("${Crypto.BLAKE3.hash(data).to_hex()}\n")
	Ok({})
}
