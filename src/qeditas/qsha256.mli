(* Copyright (c) 2015 The Qeditas developers *)
(* Distributed under the MIT software license, see the accompanying
   file COPYING or http://www.opensource.org/licenses/mit-license.php. *)

type md256 = int32 * int32 * int32 * int32 * int32 * int32 * int32 * int32

val sha256init : unit -> unit
val currblock : int32 array
val sha256round : unit -> unit
val getcurrmd256 : unit -> md256

val sha256str : string -> md256
val sha256dstr : string -> md256
