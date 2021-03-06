(***
 This is a port of parts of the Coq file Modal.v.
 The Coq file was written by Bruno Woltzenlogel Paleo (bruno@logic.at) and Christoph Benzmueller.
 The port was by Chad E. Brown.
 ***)

(** Preamble **)
(***
 This is a preamble file collecting a few basic logic definitions and results I need in Modal.
***)
Definition False : prop := forall P : prop , P.
(* Unicode False "22A5" *)

Definition True : prop := forall P : prop , P -> P.
(* Unicode True "22A4" *)
Axiom TrueI : True.

Definition not : prop -> prop := fun A : prop => A -> False.
Prefix ~ 700 := not.

Definition and : prop -> prop -> prop := fun A B : prop => forall P : prop , (A -> B -> P) -> P.
Infix /\ 780 left  := and.
Axiom andI : forall A B : prop , A -> B -> A /\ B.
Axiom andEL : forall A B : prop , A /\ B -> A.
Axiom andER : forall A B : prop , A /\ B -> B.

Definition or : prop -> prop -> prop := fun A B : prop => forall P : prop , (A -> P) -> (B -> P) -> P.
Infix \/ 785 left  := or.
Axiom orIL : forall A B : prop , A -> A \/ B.
Axiom orIR : forall A B : prop , B -> A \/ B.
Axiom orE : forall A B C : prop , (A -> C) -> (B -> C) -> A \/ B -> C.

Definition iff : prop -> prop -> prop := fun A B : prop => (A -> B) /\ (B -> A).
Infix <-> 795 := iff.

Section Poly1_eq.
Variable A : SType.
Definition eq : A -> A -> prop := fun x y => forall Q : A -> prop , Q x -> Q y.
Definition neq : A -> A -> prop := fun x y => ~ eq x y.
End Poly1_eq.
Infix = 502 := eq.
Infix <> 502 := neq.
Section Poly1_eqthms.
Variable A : SType.
Axiom eqI : forall x : A , x = x.
Axiom eq_sym : forall x y : A , x = y -> y = x.
End Poly1_eqthms.
Section Poly1_exdef.
Variable A : SType.
Variable Q : A -> prop.
Definition ex : prop := forall P : prop , (forall x : A , Q x -> P) -> P.
End Poly1_exdef.
Binder+ exists , := ex.
Section Poly1_exthms.
Variable A : SType.
Axiom exI : forall P : A -> prop , forall x : A , P x -> exists x : A , P x.
End Poly1_exthms.
Section Poly1.
Variable A : SType.
Variable P : A -> prop.
Variable Q : A -> prop.
Axiom exandE : (exists x : A , P x /\ Q x) -> forall p : prop , (forall x : A , P x -> Q x -> p) -> p.
End Poly1.

Axiom classic : forall P : prop , P \/ ~ P.
Axiom NNPP : forall p : prop , ~ ~ p -> p.

Section RelnPoly1.
Variable A:SType.
Definition symmetric : (A->A->prop)->prop := fun R => forall x y:A, R x y -> R y x.
Definition transitive : (A->A->prop)->prop := fun R => forall x y z:A, R x y -> R y z -> R x z.
Definition per : (A->A->prop)->prop := fun R => symmetric R /\ transitive R.
Axiom per_sym : forall R : A -> A -> prop , per R -> symmetric R.
Axiom per_tra : forall R : A -> A -> prop , per R -> transitive R.
Axiom per_stra1 : forall R : A -> A -> prop , per R -> forall x y z : A , R y x -> R y z -> R x z.
Axiom per_stra2 : forall R : A -> A -> prop , per R -> forall x y z : A , R x y -> R z y -> R x z.
Axiom per_stra3 : forall R : A -> A -> prop , per R -> forall x y z : A , R y x -> R z y -> R x z.
Axiom per_ref1 : forall R : A -> A -> prop , per R -> forall x y : A , R x y -> R x x.
Axiom per_ref2 : forall R : A -> A -> prop , per R -> forall x y : A , R x y -> R y y.
End RelnPoly1.

(** Main Body **)

Definition meq : set->set->(set->prop) := fun x y w => x = y.
Infix :=: 510 := meq.

Definition mnot : (set->prop) -> (set->prop) := fun p w => ~ p w.
Prefix :~: 700 := mnot.

Definition mand : (set->prop) -> (set->prop) -> (set->prop) := fun p q w => p w /\ q w.
Infix :/\: 780 left := mand.

Definition mor : (set->prop) -> (set->prop) -> (set->prop) := fun p q w => p w \/ q w.
Infix :\/: 785 left := mor.

Definition mimplies : (set->prop) -> (set->prop) -> (set->prop) := fun p q w => p w -> q w.
Infix :->: 810 right := mimplies.

Section ModalOps.

Variable R : set -> set -> prop.

Definition box_ : (set->prop) -> set->prop := fun p w => forall u, R w u -> p u.
Definition dia_ : (set->prop) -> set->prop := fun p w => exists u, R w u /\ p u.

(***
 Instead of assuming a domain of R and that R is reflexive on that domain, we only consider worlds where R w w.
 We are interested in the case where R is a per and so R w w follows from R u w (or R w u).
 Hence we will only be considering w where R w w.
 ***)
Definition Valid_ : (set->prop) -> prop := fun p => forall w, R w w -> p w.

End ModalOps.

Section ModalQuants.
Variable A : SType.
Definition ModalAll : (A->set->prop) -> set->prop := fun p w => forall x:A, p x w.
Definition ModalEx : (A->set->prop) -> set->prop := fun p w => exists x:A, p x w.
End ModalQuants.
Binder+ mforall , := ModalAll.
Binder+ mexists , := ModalEx.

Section ModalThms.

Variable R:set->set->prop.

Theorem mp_dia : Valid_ R (mforall p q:set->prop, dia_ R p :->: box_ R (p :->: q) :->: dia_ R q).
let w.
assume Hw: R w w.
let p q.
assume H1: dia_ R p w.
assume H2: box_ R (p :->: q) w.
apply exandE set (R w) p H1.
let u.
assume H3: R w u.
assume H4: p u.
prove exists u, R w u /\ q u.
witness u.
prove R w u /\ q u.
apply andI.
- exact H3.
- exact H2 u H3 H4.
Qed.

Theorem not_dia_box_not : Valid_ R (mforall p:set->prop, :~: dia_ R p :->: box_ R (:~: p)).
let w.
assume Hw: R w w.
let p.
assume H1: ~ dia_ R p w.
let u.
assume H2: R w u.
assume H3: p u.
apply H1.
prove exists u, R w u /\ p u.
witness u.
apply andI (R w u) (p u) H2 H3.
Qed.

Theorem K: Valid_ R (mforall p q:set->prop, box_ R (p :->: q) :->: box_ R p :->: box_ R q).
let w.
assume Hw: R w w.
let p q.
assume H1: box_ R (p :->: q) w.
assume H2: box_ R p w.
let u.
assume H3: R w u.
prove q u.
apply H1 u H3.
prove p u.
exact H2 u H3.
Qed.

Theorem T: Valid_ R (mforall p:set->prop, box_ R p :->: p).
let w.
assume Hw: R w w.
let p.
assume H1: box_ R p w.
prove p w.
exact H1 w Hw.
Qed.

Hypothesis Rper : per set R.

Theorem dia_box_to_box : Valid_ R (mforall p:set->prop, dia_ R (box_ R p) :->: box_ R p).
let w.
assume Hw: R w w.
let p.
assume H1: dia_ R (box_ R p) w.
apply exandE set (R w) (box_ R p) H1.
let u.
assume H2: R w u.
assume H3: box_ R p u.
let v.
assume H4: R w v.
claim L: R u v.
{ exact per_stra1 set R Rper u w v H2 H4. }
prove p v.
exact H3 v L.
Qed.

End ModalThms.