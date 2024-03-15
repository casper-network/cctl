import enum


class AccountType(enum.Enum):
    FAUCET = enum.auto()
    USER = enum.auto()
    VALIDATOR = enum.auto()
