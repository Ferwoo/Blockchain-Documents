```+go
package bccsp

import (
	"crypto"
	"hash"
)

type Key interface {
	Bytes() ([]byte, error)
	SKI() []byte
	Symmetric() bool
	Private() bool
	PublicKey() (Key, error)
}
type KeyGenOpts interface {
	Algorithm() string
	Ephemeral() bool
}
type KeyDerivOpts interface {
	Algorithm() string
	Ephemeral() bool
}
type KeyImportOpts interface {
	Algorithm() string
	Ephemeral() bool
}
type HashOpts interface {
	Algorithm() string
}
type SignerOpts interface {
	crypto.SignerOpts
}
type EncrypterOpts interface{}
type DecrypterOpts interface{}
type BCCSP interface {
	KeyDeriv(k Key, opts KeyDerivOpts) (dk Key, err error)
	KeyImport(raw interface{}, opts KeyImportOpts) (k Key, err error)
	GetKey(ski []byte) (k Key, err error)
	Hash(msg []byte, opts HashOpts) (hash []byte, err error)
	GetHash(opts HashOpts) (h hash.Hash, err error)
	Sign(k Key, digest []byte, opts SignerOpts) (signature []byte, err error)
	Verify(k Key, signature, digest []byte, opts SignerOpts) (valid bool, err error)
	Encrypt(k Key, plaintext []byte, opts EncrypterOpts) (ciphertext []byte, err error)
	Decrypt(k Key, ciphertext []byte, opts DecrypterOpts) (plaintext []byte, err error)
}

```

