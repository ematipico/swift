// RUN: %target-typecheck-verify-swift
// RUN: %target-swift-frontend -typecheck -debug-generic-signatures %s 2>&1 | %FileCheck %s

protocol P1 {
  associatedtype T
}

protocol P2 {
  associatedtype T : P1
}

struct S1<A, B, C> : P2
    where A : P1, C : P2, B == A.T.T, C.T == A.T {
  typealias T = C.T
}

struct S2<D : P1> : P2 {
  typealias T = D
}

// Make sure that we can resolve the nested type A.T
// in the same-type requirement 'A.T == B.T'.
//
// A is concrete, and S1<C, E, S2<D>>.T resolves to
// S2<D>.T, which is D. The typealias S1.T has a
// structural type 'C.T'; since C is concrete, we
// have to handle the case of an unresolved member
// type with a concrete base.
struct UnresolvedWithConcreteBase<A, B> {
  // CHECK-LABEL: Generic signature: <A, B, C, D, E where A == S1<C, E, S2<D>>, B : P2, C : P1, D == B.T, E == D.T, B.T == C.T>
  init<C, D, E>(_: C)
    where A == S1<C, E, S2<D>>,
          B : P2,
          A.T == B.T,
          C : P1,
          D == C.T,
          E == D.T { }
}