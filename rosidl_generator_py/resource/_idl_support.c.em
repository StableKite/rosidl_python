// generated from rosidl_generator_py/resource/_idl_support.c.em
// with input from @(package_name):@(interface_path)
// generated code does not contain a copyright notice

#include <Python.h>
#include <stdbool.h>
#include <string.h>

/* Exporting the buffer pins its storage; copy mutable exporters while holding
 * their object critical section, including a memoryview's underlying owner.
 * The returned bytes are owned and immutable before entering native ROS code.
 * As with NumPy itself, applications must synchronize simultaneous writes to
 * an ndarray; its buffer export does not promise an atomic message transaction.
 */
static PyObject *
rosidl_generator_py__owned_buffer(PyObject * source)
{
  Py_buffer view;
  if (PyObject_GetBuffer(source, &view, PyBUF_FULL_RO) < 0) {
    return NULL;
  }
  PyObject * result = PyBytes_FromStringAndSize(NULL, view.len);
  if (!result) {
    PyBuffer_Release(&view);
    return NULL;
  }
  PyObject * owner = view.obj ? view.obj : source;
  while (PyMemoryView_Check(owner) && PyMemoryView_GET_BASE(owner)) {
    owner = PyMemoryView_GET_BASE(owner);
  }
  int rc;
#ifdef Py_GIL_DISABLED
  Py_BEGIN_CRITICAL_SECTION(owner);
#endif
  rc = PyBuffer_ToContiguous(PyBytes_AS_STRING(result), &view, view.len, 'C');
#ifdef Py_GIL_DISABLED
  Py_END_CRITICAL_SECTION();
#endif
  PyBuffer_Release(&view);
  if (rc < 0) {
    Py_DECREF(result);
    return NULL;
  }
  return result;
}

/* Import machinery owns synchronization and lifetime of these Python objects.
 * Keep no process-global PyObject cache, and accept genuine message subclasses.
 */
static bool
rosidl_generator_py__check_message(
  PyObject * message, const char * module_name, const char * class_name)
{
  PyObject * module = PyImport_ImportModule(module_name);
  if (!module) {
    return false;
  }
  PyObject * expected = PyObject_GetAttrString(module, class_name);
  Py_DECREF(module);
  if (!expected) {
    return false;
  }
  int matches = PyObject_IsInstance(message, expected);
  Py_DECREF(expected);
  if (matches == 0) {
    PyErr_Format(PyExc_TypeError, "expected an instance of %s.%s", module_name, class_name);
  }
  return matches == 1;
}

@
@#######################################################################
@# EmPy template for generating _<idl>_s.c files
@#
@# Context:
@#  - package_name (string)
@#  - interface_path (Path relative to the directory named after the package)
@#  - content (IdlContent, list of elements, e.g. Messages or Services)
@#######################################################################
@
@#######################################################################
@# Handle messages
@#######################################################################
@{
from rosidl_parser.definition import Message

include_directives = set()
}@
@[for message in content.get_elements_of_type(Message)]@
@{

TEMPLATE(
    '_msg_support.c.em',
    package_name=package_name, interface_path=interface_path,
    message=message, include_directives=include_directives)
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
    '_msg_support.c.em',
    package_name=package_name, interface_path=interface_path,
    message=service.request_message, include_directives=include_directives)
}@

@{
TEMPLATE(
    '_msg_support.c.em',
    package_name=package_name, interface_path=interface_path,
    message=service.response_message, include_directives=include_directives)
}@

@{
TEMPLATE(
    '_msg_support.c.em',
    package_name=package_name, interface_path=interface_path,
    message=service.event_message, include_directives=include_directives)
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
    '_msg_support.c.em',
    package_name=package_name, interface_path=interface_path,
    message=action.goal, include_directives=include_directives)
}@

@{
TEMPLATE(
    '_msg_support.c.em',
    package_name=package_name, interface_path=interface_path,
    message=action.result, include_directives=include_directives)
}@

@{
TEMPLATE(
    '_msg_support.c.em',
    package_name=package_name, interface_path=interface_path,
    message=action.feedback, include_directives=include_directives)
}@

@{
TEMPLATE(
    '_msg_support.c.em',
    package_name=package_name, interface_path=interface_path,
    message=action.send_goal_service.request_message,
    include_directives=include_directives)
}@

@{
TEMPLATE(
    '_msg_support.c.em',
    package_name=package_name, interface_path=interface_path,
    message=action.send_goal_service.response_message,
    include_directives=include_directives)
}@

@{
TEMPLATE(
    '_msg_support.c.em',
    package_name=package_name, interface_path=interface_path,
    message=action.send_goal_service.event_message,
    include_directives=include_directives)
}@

@{
TEMPLATE(
    '_msg_support.c.em',
    package_name=package_name, interface_path=interface_path,
    message=action.get_result_service.request_message,
    include_directives=include_directives)
}@

@{
TEMPLATE(
    '_msg_support.c.em',
    package_name=package_name, interface_path=interface_path,
    message=action.get_result_service.response_message,
    include_directives=include_directives)
}@

@{
TEMPLATE(
    '_msg_support.c.em',
    package_name=package_name, interface_path=interface_path,
    message=action.get_result_service.event_message,
    include_directives=include_directives)
}@

@{
TEMPLATE(
    '_msg_support.c.em',
    package_name=package_name, interface_path=interface_path,
    message=action.feedback_message, include_directives=include_directives)
}@
@[end for]@
