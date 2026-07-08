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
#valtype
pub struct Process {
  pid : Int
  priv handle : IoHandle?
}

///|
pub fn Process::close(self : Process) -> Unit {
  if self.handle is Some(io) {
    io.close()
  }
}

///|
#cfg(target="native")
extern "C" fn open_pid_handle(pid : Int) -> @fd_util.Fd = "moonbitlang_async_open_pid_handle"

///|
#cfg(target="wasm")
#unsafe_skip_stub_check
fn open_pid_handle(pid : Int) -> @fd_util.Fd = "moonbitlang/async" "process/open_pid_handle"

///|
pub fn Process::from_pid(pid : Int, context~ : String) -> Process raise {
  let handle = open_pid_handle(pid)
  let handle = if !@fd_util.fd_is_valid(handle) {
    @os_error.check_errno(context)
    None
  } else {
    IoHandle::from_fd(
      handle,
      kind=Unknown,
      is_async=platform is Linux,
      read_only=true,
    )
    |> Some
  }
  { pid, handle }
}

///|
#cfg(target="native")
#borrow(out)
extern "C" fn get_process_result(
  handle : @fd_util.Fd,
  pid : Int,
  out : Ref[Int],
) -> Int = "moonbitlang_async_get_process_result"

///|
#cfg(target="wasm")
fn Process::new(pid : Int, handle : @fd_util.Fd) -> Process raise {
  let handle = if @fd_util.fd_is_valid(handle) {
    Some(IoHandle::from_fd(handle, kind=Unknown, is_async=false))
  } else {
    None
  }
  { pid, handle }
}

///|
#cfg(target="wasm")
pub async fn spawn(
  path : @os_string.OsString,
  args : Bytes,
  args_len~ : Int,
  env~ : Bytes,
  env_len~ : Int,
  inherit_env~ : Bool,
  stdin~ : @fd_util.Fd,
  stdout~ : @fd_util.Fd,
  stderr~ : @fd_util.Fd,
  cwd~ : @os_string.OsString?,
  no_console_window~ : Bool,
  is_orphan~ : Bool,
  context~ : String,
) -> Process {
  let (cwd, has_cwd) = match cwd {
    None => (@os_string.encode(""), false)
    Some(cwd) => (cwd, true)
  }
  let job = Job::spawn(
    path,
    args,
    args_len~,
    env~,
    env_len~,
    inherit_env~,
    stdin~,
    stdout~,
    stderr~,
    cwd~,
    has_cwd~,
    no_console_window~,
    is_orphan~,
  )
  defer job.0.free()
  let pid = perform_job_in_worker(job.0, context~)
  Process::new(pid, job.result_handle())
}

///|
#cfg(target="wasm")
pub async fn Process::wait_pid(self : Process, context~ : String) -> Int {
  guard curr_loop.val is Some(evloop)
  let handle = if self.handle is Some(io) { io.fd } else { @fd_util.invalid_fd }
  let job = Job::wait_for_process(handle, pid=self.pid)
  defer job.free()
  perform_job_in_worker(job, context~, cancel=job_id => {
    evloop.cancel_job_in_worker(job_id, context~)
  })
}
