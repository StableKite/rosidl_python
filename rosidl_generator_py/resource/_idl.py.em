# generated from rosidl_generator_py/resource/_idl.py.em
# with input from @(package_name):@(interface_path)
# generated code does not contain a copyright notice

# This is being done at the module level and not on the instance level to avoid looking
# for the same variable multiple times on each instance. This variable is not supposed to
# change during runtime so it makes sense to only look for it once.
from os import getenv

import array as _rosidl_array
import builtins as _rosidl_builtins
from types import GenericAlias as _rosidl_GenericAlias
from typing import TYPE_CHECKING
from typing import TypedDict as _rosidl_TypedDict
from typing import Unpack as _rosidl_Unpack

if TYPE_CHECKING:
    _rosidl_int_array = _rosidl_array.array[_rosidl_builtins.int]
    _rosidl_float_array = _rosidl_array.array[_rosidl_builtins.float]
else:
    # array.array has typed parameters but no runtime __class_getitem__.
    _rosidl_int_array = _rosidl_GenericAlias(_rosidl_array.array, _rosidl_builtins.int)
    _rosidl_float_array = _rosidl_GenericAlias(_rosidl_array.array, _rosidl_builtins.float)

ros_python_check_fields = getenv('ROS_PYTHON_CHECK_FIELDS', default='')
@
@#######################################################################
@# EmPy template for generating _<idl>.py files
@#
@# Context:
@#  - package_name (string)
@#  - interface_path (Path relative to the directory named after the package)
@#  - content (IdlContent, list of elements, e.g. Messages or Services)
@#######################################################################
@{
import_statements = set()
}@
@
@#######################################################################
@# Handle messages
@#######################################################################
@{
from rosidl_parser.definition import Message
}@
@[for message in content.get_elements_of_type(Message)]@
@{
TEMPLATE(
    '_msg.py.em',
    package_name=package_name, interface_path=interface_path, message=message,
    import_statements=import_statements)
}@
@[end for]@
@
@#######################################################################
@# Handle services
@#######################################################################
@{
from rosidl_parser.definition import Service
}@
@[for service in content.get_elements_of_type(Service)]@
@{
TEMPLATE(
    '_srv.py.em',
    package_name=package_name, interface_path=interface_path, service=service,
    import_statements=import_statements)
}@
@[end for]@
@
@#######################################################################
@# Handle actions
@#######################################################################
@{
from rosidl_parser.definition import Action
}@
@[for action in content.get_elements_of_type(Action)]@
@{
TEMPLATE(
    '_action.py.em',
    package_name=package_name, interface_path=interface_path, action=action,
    import_statements=import_statements)
}@
@[end for]@
