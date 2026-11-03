# Copyright 2021 Open Source Robotics Foundation, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import importlib
import importlib.util
import pathlib
from collections.abc import Iterable, Sequence
from contextlib import AbstractContextManager
from typing import Protocol, cast

from ament_index_python import get_package_share_directory
from ament_index_python import get_resources

from rosidl_cli.command.generate.extensions import GenerateCommandExtension
import rosidl_cli.command.helpers as _helpers
import rosidl_cli.command.translate.api as _translate_api

from rosidl_generator_py import generate_py

_StrPath = str | pathlib.Path


class _LegacyArguments(Protocol):
    def __call__(
        self, *, package_name: str, interface_files: Sequence[str],
        include_paths: Sequence[_StrPath], templates_path: pathlib.Path,
        output_path: pathlib.Path
    ) -> dict[str, object]: ...


class _ArgumentsFile(Protocol):
    def __call__(self, **kwargs: object) -> AbstractContextManager[str]: ...


class _Translate(Protocol):
    def __call__(
        self, *, package_name: str, interface_files: Sequence[str], output_format: str,
        input_format: str | None = None, include_paths: Sequence[_StrPath] | None = None,
        output_path: pathlib.Path | None = None, translators: Sequence[str] | None = None
    ) -> list[str]: ...


class _DescriptionTuples(Protocol):
    def __call__(
        self, idl_interface_files: Sequence[str], type_description_files: Sequence[_StrPath]
    ) -> list[str]: ...


class _PackagedSDKResources(Protocol):
    def configure_environment(self) -> None: ...


legacy_generator_arguments = cast(_LegacyArguments, getattr(_helpers, 'legacy_generator_arguments'))
generator_arguments_file = cast(_ArgumentsFile, getattr(_helpers, 'generator_arguments_file'))
build_type_description_tuples = cast(_DescriptionTuples, getattr(_helpers, 'build_type_description_tuples'))
translate = cast(_Translate, getattr(_translate_api, 'translate'))


class GeneratePython(GenerateCommandExtension):

    def __init__(
        self, name: str, *, typesupport_implementations: Iterable[str] | None = None
    ) -> None:
        if importlib.util.find_spec('_stablekite_ros_sdk') is not None:
            sdk = cast(_PackagedSDKResources, importlib.import_module('_stablekite_ros_sdk'))
            sdk.configure_environment()
        super().__init__(name)
        if typesupport_implementations is None:
            typesupport_implementations = ['rosidl_typesupport_c']
            typesupport_implementations.extend(
                get_resources('rosidl_typesupport_c'))
        self.__typesupport_implementations = typesupport_implementations

    def generate(
        self,
        package_name: str,
        interface_files: Sequence[str],
        include_paths: Sequence[_StrPath],
        output_path: pathlib.Path,
        type_description_files: Sequence[_StrPath] | None = None
    ) -> list[str]:
        package_share_path = \
            pathlib.Path(get_package_share_directory('rosidl_generator_py'))
        templates_path = package_share_path / 'resource'

        # Normalize interface definition format to .idl
        idl_interface_files: list[str] = []
        non_idl_interface_files: list[str] = []
        for path in interface_files:
            if not path.endswith('.idl'):
                non_idl_interface_files.append(path)
            else:
                idl_interface_files.append(path)
        if non_idl_interface_files:
            idl_interface_files.extend(translate(
                package_name=package_name,
                interface_files=non_idl_interface_files,
                include_paths=include_paths,
                output_format='idl',
                output_path=output_path / 'tmp',
            ))

        # Generate code
        arguments = legacy_generator_arguments(
            package_name=package_name,
            interface_files=idl_interface_files,
            include_paths=include_paths,
            templates_path=templates_path,
            output_path=output_path
        )
        if type_description_files:
            description_tuples = build_type_description_tuples(
                idl_interface_files, type_description_files)
            normalized_descriptions: list[str] = []
            for item in description_tuples:
                relative_idl, separator, description_path = item.partition(':')
                assert separator
                normalized_descriptions.append(
                    pathlib.PurePath(relative_idl).as_posix() + ':' + description_path)
            arguments['type_description_tuples'] = normalized_descriptions
        with generator_arguments_file(**arguments) as path_to_arguments_file:
            return generate_py(
                path_to_arguments_file,
                self.__typesupport_implementations)
