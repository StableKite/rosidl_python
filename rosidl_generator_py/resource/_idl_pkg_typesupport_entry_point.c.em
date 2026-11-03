// generated from rosidl_generator_py/resource/_idl_pkg_typesupport_entry_point.c.em
// generated code does not contain a copyright notice
@
@#######################################################################
@# EmPy template for generating _<pkg>_s.ep.<ts>.c files
@#
@# Context:
@#  - package_name (string)
@#  - content (IdlContent, combined list of elements across all interface files
@#  - typesupport_impl (string identifying the typesupport used)
@#######################################################################
@
@#######################################################################
@# Handle messages
@#######################################################################
@{
from rosidl_pycommon import convert_camel_case_to_lower_case_underscore
from rosidl_parser.definition import Message

include_directives = set()
register_functions = []
}@
#include <Python.h>

static PyMethodDef @(package_name)__methods[] = {
  {NULL, NULL, 0, NULL}  /* sentinel */
};

@
@[for message in content.get_elements_of_type(Message)]@

@{
TEMPLATE(
    '_msg_pkg_typesupport_entry_point.c.em',
    package_name=package_name, idl_type=message.structure.namespaced_type, message=message,
    typesupport_impl=typesupport_impl, include_directives=include_directives,
    register_functions=register_functions)
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
    '_srv_pkg_typesupport_entry_point.c.em',
    package_name=package_name, idl_type=service.namespaced_type,
    service=service, typesupport_impl=typesupport_impl,
    include_directives=include_directives,
    register_functions=register_functions)
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
    '_action_pkg_typesupport_entry_point.c.em',
    package_name=package_name, idl_type=action.namespaced_type,
    action=action, typesupport_impl=typesupport_impl,
    include_directives=include_directives,
    register_functions=register_functions)
}@
@[end for]@

static int
@(package_name)__exec(PyObject * pymodule)
{
  int8_t err;
@[for register_function in register_functions]@

  err = @(register_function)(pymodule);
  if (err) {
    return -1;
  }
@[end for]@

  return 0;
}

/* Every Python reference belongs to this module's dictionary. Conversion
 * functions retain their inputs, snapshot mutable containers and own native
 * message storage; there is no process-global Python cache or NumPy C table.
 */
static PyModuleDef_Slot @(package_name)__slots[] = {
  {Py_mod_exec, (void *)@(package_name)__exec},
#ifdef Py_GIL_DISABLED
  {Py_mod_gil, Py_MOD_GIL_NOT_USED},
#endif
  {0, NULL}
};

static struct PyModuleDef @(package_name)__module = {
  PyModuleDef_HEAD_INIT,
  "_@(package_name)_support",
  "_@(package_name)_doc",
  0,
  @(package_name)__methods,
  @(package_name)__slots,
  NULL,
  NULL,
  NULL,
};

PyMODINIT_FUNC
PyInit_@(package_name)_s__@(typesupport_impl)(void)
{
  return PyModuleDef_Init(&@(package_name)__module);
}
