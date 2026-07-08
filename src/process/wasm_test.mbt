///|
// Copyright 2025 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///|
#cfg(not(platform="windows"))
async test "wasm collect stdout" {
  let (code, output) = @process.collect_stdout("/bin/sh", [
    "-c", "printf moonbit-process",
  ])
  inspect(code, content="0")
  inspect(output.text(), content="moonbit-process")
}

///|
#cfg(not(platform="windows"))
async test "wasm pass env" {
  let (code, output) = @process.collect_stdout(
    "/bin/sh",
    ["-c", "printf \"$MOONBIT_PROCESS_TEST\""],
    extra_env={ "MOONBIT_PROCESS_TEST": "env-ok" },
  )
  inspect(code, content="0")
  inspect(output.text(), content="env-ok")
}

///|
#cfg(not(platform="windows"))
async test "wasm set cwd" {
  let (code, output) = @process.collect_stdout(
    "/bin/sh",
    ["-c", "ls"],
    cwd="test_directory",
    extra_env={ "LC_ALL": "C" },
  )
  inspect(code, content="0")
  let files = output
    .text()
    .trim(char_set="\n\r ")
    .replace_all(old="\r\n", new="\n")
    .split("\n")
    .to_array()
  files.sort()
  json_inspect(files, content=["file", "inner1"])
}
