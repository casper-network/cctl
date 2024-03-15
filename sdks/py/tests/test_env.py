import pycctl


def test_that_evars_are_declared():
    assert pycctl.env.get_evar(pycctl.env.EVarType.CCTL) is not None
