(* Copyright (c) 2015 The Qeditas developers *)
(* Distributed under the MIT software license, see the accompanying
   file COPYING or http://www.opensource.org/licenses/mit-license.php. *)

open Qhashaux

(*** Following the description in http://csrc.nist.gov/groups/STM/cavp/documents/shs/sha256-384-512.pdf ***)
type md256 = int32 * int32 * int32 * int32 * int32 * int32 * int32 * int32

let sha256inithashval : int32 array =
  [| 0x6a09e667l; 0xbb67ae85l; 0x3c6ef372l; 0xa54ff53al;
     0x510e527fl; 0x9b05688cl; 0x1f83d9abl; 0x5be0cd19l |]

let currhashval : int32 array = [| 0l; 0l; 0l; 0l; 0l; 0l; 0l; 0l |]
let currblock : int32 array = [| 0l; 0l; 0l; 0l; 0l; 0l; 0l; 0l; 0l; 0l; 0l; 0l; 0l; 0l; 0l; 0l |]
let expandedmsgblock : int32 array = [| 0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l |]

(*** Got these from https://stackoverflow.com/questions/235493/is-my-ocaml-implementation-of-sha256-sane ***)
let sha256constwords : int32 array = [|
    0x428a2f98l; 0x71374491l; 0xb5c0fbcfl; 0xe9b5dba5l;
    0x3956c25bl; 0x59f111f1l; 0x923f82a4l; 0xab1c5ed5l;
    0xd807aa98l; 0x12835b01l; 0x243185bel; 0x550c7dc3l;
    0x72be5d74l; 0x80deb1fel; 0x9bdc06a7l; 0xc19bf174l;
    0xe49b69c1l; 0xefbe4786l; 0x0fc19dc6l; 0x240ca1ccl;
    0x2de92c6fl; 0x4a7484aal; 0x5cb0a9dcl; 0x76f988dal;
    0x983e5152l; 0xa831c66dl; 0xb00327c8l; 0xbf597fc7l;
    0xc6e00bf3l; 0xd5a79147l; 0x06ca6351l; 0x14292967l;
    0x27b70a85l; 0x2e1b2138l; 0x4d2c6dfcl; 0x53380d13l;
    0x650a7354l; 0x766a0abbl; 0x81c2c92el; 0x92722c85l;
    0xa2bfe8a1l; 0xa81a664bl; 0xc24b8b70l; 0xc76c51a3l;
    0xd192e819l; 0xd6990624l; 0xf40e3585l; 0x106aa070l;
    0x19a4c116l; 0x1e376c08l; 0x2748774cl; 0x34b0bcb5l;
    0x391c0cb3l; 0x4ed8aa4al; 0x5b9cca4fl; 0x682e6ff3l;
    0x748f82eel; 0x78a5636fl; 0x84c87814l; 0x8cc70208l;
    0x90befffal; 0xa4506cebl; 0xbef9a3f7l; 0xc67178f2l
|]

let int32_odd x =
  Int32.logand x Int32.one = Int32.one

let int32_right_rotation x n =
  Int32.logor (Int32.shift_left x (32 - n)) (Int32.shift_right_logical x n)

let a = ref 0l
let b = ref 0l
let c = ref 0l
let d = ref 0l
let e = ref 0l
let f = ref 0l
let g = ref 0l
let h = ref 0l

let bigsigma0 x =
  Int32.logxor
    (int32_right_rotation x 2)
    (Int32.logxor
       (int32_right_rotation x 13)
       (int32_right_rotation x 22))

let bigsigma1 x =
  Int32.logxor
    (int32_right_rotation x 6)
    (Int32.logxor
       (int32_right_rotation x 11)
       (int32_right_rotation x 25))

let sigma0 x =
  Int32.logxor
    (int32_right_rotation x 7)
    (Int32.logxor
       (int32_right_rotation x 18)
       (Int32.shift_right_logical x 3))

let sigma1 x =
  Int32.logxor
    (int32_right_rotation x 17)
    (Int32.logxor
       (int32_right_rotation x 19)
       (Int32.shift_right_logical x 10))

let ch x y z =
  Int32.logxor (Int32.logand x y) (Int32.logand (Int32.lognot x) z)

let maj x y z = 
  Int32.logxor (Int32.logand x y) (Int32.logxor (Int32.logand x z) (Int32.logand y z))

let sha256comprfun () =
  for j = 0 to 63 do
    let t1 = Int32.add !h (Int32.add (bigsigma1 !e) (Int32.add (ch !e !f !g) (Int32.add (sha256constwords.(j)) (expandedmsgblock.(j))))) in
    let t2 = Int32.add (bigsigma0 !a) (maj !a !b !c) in
    h := !g;
    g := !f;
    f := !e;
    e := Int32.add !d t1;
    d := !c;
    c := !b;
    b := !a;
    a := Int32.add t1 t2
  done

let setexpandedmsgblock () =
  for j = 0 to 15 do
    expandedmsgblock.(j) <- currblock.(j)
  done;
  for j = 16 to 63 do
    expandedmsgblock.(j) <-
      Int32.add (sigma1 (expandedmsgblock.(j-2)))
	(Int32.add (expandedmsgblock.(j-7))
	   (Int32.add
	      (sigma0 (expandedmsgblock.(j-15)))
	      (expandedmsgblock.(j-16))))
  done

let sha256round () =
  setexpandedmsgblock();
  a := currhashval.(0);
  b := currhashval.(1);
  c := currhashval.(2);
  d := currhashval.(3);
  e := currhashval.(4);
  f := currhashval.(5);
  g := currhashval.(6);
  h := currhashval.(7);
  sha256comprfun();
  currhashval.(0) <- Int32.add !a currhashval.(0);
  currhashval.(1) <- Int32.add !b currhashval.(1);
  currhashval.(2) <- Int32.add !c currhashval.(2);
  currhashval.(3) <- Int32.add !d currhashval.(3);
  currhashval.(4) <- Int32.add !e currhashval.(4);
  currhashval.(5) <- Int32.add !f currhashval.(5);
  currhashval.(6) <- Int32.add !g currhashval.(6);
  currhashval.(7) <- Int32.add !h currhashval.(7)

let sha256init () =
  currhashval.(0) <- sha256inithashval.(0);
  currhashval.(1) <- sha256inithashval.(1);
  currhashval.(2) <- sha256inithashval.(2);
  currhashval.(3) <- sha256inithashval.(3);
  currhashval.(4) <- sha256inithashval.(4);
  currhashval.(5) <- sha256inithashval.(5);
  currhashval.(6) <- sha256inithashval.(6);
  currhashval.(7) <- sha256inithashval.(7)

let getcurrmd256 () =
  (currhashval.(0),currhashval.(1),currhashval.(2),currhashval.(3),currhashval.(4),currhashval.(5),currhashval.(6),currhashval.(7))

let sha256padnum l =
  let r = (l+1) mod 512 in
  let k = if r <= 448 then 448 - r else 960 - r in
  k

let setbyte32 x y j =
  Int32.logor x (Int32.shift_left (Int32.of_int y) (8 * (3-j)))

let sha256str s =
  let l = String.length s in
  let k = sha256padnum (l * 8) in
  let totl0 = l*8 + k + 1 + 32 in
  let totl08 = totl0/8 in
  let totl = totl0 + 32 in
  let bl = totl / 512 in
  let ch = ref 0 in
  sha256init();
  for b = 1 to bl do
    for i = 0 to 15 do
      currblock.(i) <- 0l;
      if !ch = totl08 then currblock.(i) <- Int32.of_int (l * 8);
      for j = 0 to 3 do
	begin
	  if !ch < l then
	    currblock.(i) <- setbyte32 (currblock.(i)) (Char.code (String.get s !ch)) j
	  else if !ch = l then
	    currblock.(i) <- setbyte32 (currblock.(i)) (0x80) j
	end;
	incr ch
      done
    done;
    sha256round()
  done;
  getcurrmd256()

let sha256dstr s =
  let l = String.length s in
  let k = sha256padnum (l * 8) in
  let totl0 = l*8 + k + 1 + 32 in
  let totl08 = totl0/8 in
  let totl = totl0 + 32 in
  let bl = totl / 512 in
  let ch = ref 0 in
  sha256init();
  for b = 1 to bl do
    for i = 0 to 15 do
      currblock.(i) <- 0l;
      if !ch = totl08 then
	currblock.(i) <- Int32.of_int (l * 8)
      else
	for j = 0 to 3 do
	  begin
	    if !ch < l then
	      currblock.(i) <- setbyte32 (currblock.(i)) (Char.code (String.get s !ch)) j
	    else if !ch = l then
	      currblock.(i) <- setbyte32 (currblock.(i)) (0x80) j
	  end;
	  incr ch
	done
    done;
    sha256round()
  done;
  currblock.(0) <- currhashval.(0);
  currblock.(1) <- currhashval.(1);
  currblock.(2) <- currhashval.(2);
  currblock.(3) <- currhashval.(3);
  currblock.(4) <- currhashval.(4);
  currblock.(5) <- currhashval.(5);
  currblock.(6) <- currhashval.(6);
  currblock.(7) <- currhashval.(7);
  currblock.(8) <- 0x80000000l;
  currblock.(9) <- 0l;
  currblock.(10) <- 0l;
  currblock.(11) <- 0l;
  currblock.(12) <- 0l;
  currblock.(13) <- 0l;
  currblock.(14) <- 0l;
  currblock.(15) <- 256l;
  sha256init();
  sha256round();
  getcurrmd256()
