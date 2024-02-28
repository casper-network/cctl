import argparse
import asyncio
import json
import pathlib
import typing

from pycspr import NodeClient
from pycspr import NodeConnectionInfo


# CLI argument parser.
_ARGS = argparse.ArgumentParser("Captures data pertaining to a block range.")

# CLI argument: host address of target node - defaults to CCTL node 1.
_ARGS.add_argument(
    "--node-host",
    default="localhost",
    dest="node_host",
    help="Host address of target node.",
    type=str,
    )

# CLI argument: Node API JSON-RPC port - defaults to 11101 @ CCTL node 1.
_ARGS.add_argument(
    "--node-port-rpc",
    default=11101,
    dest="node_port_rpc",
    help="Node API JSON-RPC port.  Typically 7777 on most nodes.",
    type=int,
    )

# CLI argument: Node API SSE port - defaults to 18101 @ CCTL node 1.
_ARGS.add_argument(
    "--node-port-sse",
    default=18101,
    dest="node_port_sse",
    help="Node API SSE port.  Typically 9999 on most nodes.",
    type=int,
    )

# CLI argument: Block height from which to begin data capture.  Defaults to genesis block.
_ARGS.add_argument(
    "--from",
    default=0,
    dest="range_from",
    help="Block height from which to begin data capture.  Defaults to genesis block.",
    type=int,
    )

# CLI argument: Block height at which data capture ends.  Defaults to 100th block.
_ARGS.add_argument(
    "--to",
    default=100,
    dest="range_to",
    help="Block height at which data capture ends.  Defaults to 100th block.",
    type=int,
    )

# CLI argument: Directory to which to write output.
_ARGS.add_argument(
    "--target",
    dest="io_target",
    help="Directory to which to write output.",
    type=str,
    )


async def main(args: argparse.Namespace):
    """Main entry point.

    :param args: Parsed command line arguments.

    """
    # Set node client.
    client: NodeClient = _get_client(args)

    # Validate range.
    try:
        assert args.range_from >= 0
        assert args.range_to > args.range_from
        assert args.range_to <= client.get_block_height(), client.get_block_height()
    except AssertionError:
        raise Exception("Specified block range is invalid")
    
    # Validate io target.
    io_target = pathlib.Path(args.io_target)
    try:
        assert io_target.is_dir
    except AssertionError:
        raise Exception("Invalid target directory.")

    # Capute blocks within range.
    block_range = range(args.range_from, args.range_to)
    for block in _yield_blocks(client, block_range):
        _write_block(io_target, block)

    print("-" * 74)


def _yield_blocks(client: NodeClient, block_range: typing.Sequence) -> typing.Generator[dict, None, None]:
    """Yields blocks within specified range.

    """
    for block_height in block_range:
        yield client.get_block(block_height)


def _write_block(io_target: pathlib.Path, block: dict):
    """Writes block data to file system.

    """
    fname = f"block-{block["header"]["height"]}.json"
    fpath = io_target / fname

    with open(fpath, 'w') as fhandle:
        fhandle.write(json.dumps(block, indent=4))


def _get_client(args: argparse.Namespace) -> NodeClient:
    """Returns a pycspr client instance.

    """
    return NodeClient(NodeConnectionInfo(
        host=args.node_host,
        port_rpc=args.node_port_rpc,
        port_sse=args.node_port_sse
    ))


# Entry point.
if __name__ == "__main__":
    asyncio.run(main(_ARGS.parse_args()))
