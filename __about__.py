"""
@author Mahmoud Ezzat
@requires Python 3.12.5 or later

Copyright (c) 2024
All rights reserved.
"""

__version__ = "1.5"
__version_info__ = tuple(
    [
        int(num) if num.isdigit() else num
        for num in __version__.replace("-", ".", 1).split(".")
    ]
)
__name__ = "Version"
__description__ = "A Python package for creating and managing new projects."

"""
hatch version minor
hatch version major,rc
hatch version release
hatch version "0.1.0"
"""
