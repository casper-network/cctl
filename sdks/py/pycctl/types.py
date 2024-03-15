import enum


class AssymetricKeyType(enum.Enum):
    PRIVATE = enum.auto()
    PUBLIC = enum.auto()


class AccountType(enum.Enum):
    FAUCET = enum.auto()
    USER = enum.auto()
    VALIDATOR = enum.auto()
