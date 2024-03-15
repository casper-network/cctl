from pycctl.types import AssymetricKeyType


ASSYMETRIC_KEY_FNAME = {
    AssymetricKeyType.PRIVATE: "secret_key.pem",
    AssymetricKeyType.PUBLIC: "public_key_hex",
}


NET_BINARIES = {
    "activate_bid.wasm",
    "add_bid.wasm",
    "casper-client",
    "delegate.wasm",
    "transfer_to_account_u512.wasm",
    "undelegate.wasm",
    "withdraw_bid.wasm",
}

NODE_BINARIES = {
    "1_0_0/casper-node",
    "casper-node-launcher",
}


NODE_CONFIG = {
    "1_0_0/accounts.toml",
    "1_0_0/chainspec.toml",
    "1_0_0/config.toml",
}
