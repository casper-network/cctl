from pycctl.constants import NET_BINARIES
from pycctl.constants import NODE_CONFIG
from pycctl.types import AccountType
from pycctl.types import AssymetricKeyType
from pycctl.fsys import get_path_to_assets
from pycctl.fsys import get_path_to_account_key_directory
from pycctl.fsys import get_path_to_account_key
from pycctl.fsys import get_path_to_binary
from pycctl.fsys import get_path_to_genesis_accounts
from pycctl.fsys import get_path_to_genesis_chainspec
from pycctl.fsys import get_path_to_node
from pycctl.fsys import get_path_to_node_config
from pycctl.fsys import get_path_to_root


def test_path_to_root():
    assert get_path_to_root().exists()


def test_path_to_assets():
    assert get_path_to_assets().exists()


def test_path_to_account_directory():
    for account_type in AccountType:
        if account_type == AccountType.FAUCET:
            assert get_path_to_account_key_directory(account_type).exists()
        else:
            for idx in range(1, 11):
                assert get_path_to_account_key_directory(account_type, idx).exists()


def test_path_to_account_directory_keys():
    for account_type in AccountType:
        for key_type in AssymetricKeyType:
            if account_type == AccountType.FAUCET:
                assert get_path_to_account_key(account_type, key_type).exists()
            else:
                for idx in range(1, 11):
                    assert get_path_to_account_key(account_type, key_type, idx).exists()


def test_path_to_genesis_artefacts():
    assert get_path_to_genesis_accounts().exists()
    assert get_path_to_genesis_chainspec().exists()


def test_path_to_net_binaries():
    for fname in NET_BINARIES:
        assert get_path_to_binary(fname).exists()


def test_path_to_node():
    for idx in range(1, 11):
        assert get_path_to_node(idx).exists()
        for fname in NODE_CONFIG:
            assert get_path_to_node_config(idx, fname).exists()
