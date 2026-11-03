# Copyright 2026 StableKite contributors
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

from pathlib import Path
import json
import subprocess
import sys

from ament_index_python import get_package_share_directory
import pytest

from rosidl_generator_py.cli import GeneratePython


def test_cli_accepts_native_type_descriptions_and_retains_legacy_outputs(tmp_path: Path):
    share = Path(get_package_share_directory('test_msgs'))
    idl = share / 'msg' / 'BasicTypes.idl'
    description = share / 'msg' / 'BasicTypes.json'
    assert idl.is_file() and description.is_file()
    interfaces = [str(share) + ':msg/BasicTypes.idl']
    legacy = tmp_path / 'legacy'
    described = tmp_path / 'described'
    # Exercise the real CLI extension in its own interpreter. The SDK EmPy3
    # interpreter retains a process stdout proxy across generator invocations.
    program = '''import json, sys
from pathlib import Path
assert sys.flags.gil is None and not sys._is_gil_enabled()
sys.path[:0] = json.loads(sys.argv[1])
from rosidl_generator_py.cli import GeneratePython
generator = GeneratePython('py', typesupport_implementations=['rosidl_typesupport_c'])
interfaces = json.loads(sys.argv[2])
assert generator.generate('test_msgs', interfaces, [], Path(sys.argv[3]))
assert generator.generate('test_msgs', interfaces, [], Path(sys.argv[4]),
                          type_description_files=[Path(sys.argv[5])])
assert sys.flags.gil is None and not sys._is_gil_enabled()
'''
    completed = subprocess.run(
        [sys.executable, '-I', '-B', '-c', program, json.dumps(sys.path),
         json.dumps(interfaces), str(legacy), str(described), str(description)],
        capture_output=True, text=True, check=False, timeout=60)
    assert completed.returncode == 0, completed.stdout + completed.stderr
    before = {path.relative_to(legacy): path.read_bytes() for path in legacy.rglob('*')
              if path.is_file()}
    after = {path.relative_to(described): path.read_bytes() for path in described.rglob('*')
             if path.is_file()}
    assert before == after
    assert Path('msg/_basic_types.py') in before
    assert Path('msg/_basic_types_s.c') in before


def test_cli_rejects_a_description_for_a_different_interface(tmp_path: Path):
    share = Path(get_package_share_directory('test_msgs'))
    description = share / 'msg' / 'Empty.json'
    assert description.is_file()
    generator = GeneratePython('py', typesupport_implementations=['rosidl_typesupport_c'])
    with pytest.raises(ValueError, match='Type description file not found'):
        generator.generate(
            'test_msgs', [str(share) + ':msg/BasicTypes.idl'], [], tmp_path / 'mismatched',
            type_description_files=[description])
