---
tags:
  - "#concept/rust"
  - "#concept/memory"
  - "#architecture/low-level"
---

# Ownership: Exclusivity and Responsibility

## 핵심 통찰 (Aha-moment)
Rust의 `Ownership(소유권)`이라는 명명은 단순히 스마트 포인터나 메모리 해제(free)의 기술적 추상화가 아니다. 이는 하드웨어적 제약을 철학적으로 투영한 단어로, 본질적으로 **'배타성(Exclusivity)'**과 그에 따른 **'책임(Responsibility)'**을 의미한다.

## 물리적 매핑 및 당위성
1. **배타적 권리 (Exclusivity):**
   - Heap 메모리에 할당된 데이터는 오직 단 하나의 Stack 변수(Owner)만이 독점적 권리를 가진다.
   - 대입(`let b = a`)이 일어날 경우, 권리가 복사되는 것이 아니라 **이전(Move)**된다. 기존 소유자는 물리적으로 권리를 박탈당하며, 이를 통해 `Double Free` 버그를 컴파일 타임에 원천 차단한다.
2. **필연적 책임 (Responsibility):**
   - 소유권(등기부등본)을 가진 변수가 자신의 수명(Scope)을 다할 때, 쥐고 있던 Heap 메모리를 파괴(`free()`)해야 할 **책임**을 지게 된다.
   - 컴파일러는 주인이 단 한 명임을 100% 확신할 수 있으므로, 정확한 어셈블리 위치에 `free()`를 하드코딩하여 Zero-cost(런타임 오버헤드 0)로 메모리 누수를 방지한다.

## 시뮬레이터 설계 관점
NPU 시뮬레이터에서 텐서(Tensor)나 하드웨어 노드를 다룰 때, GC(가비지 컬렉터)로 인한 비결정성(Non-determinism)과 사이클 낭비를 피하기 위해 이 소유권 모델이 필수적이다. 데이터를 연산기에 넘길 때는 소유권을 넘기지 않고 **빌림(Borrowing, `&`)**을 통해 접근 권한만 대여하여 오버헤드 없이 안전하게 연산한다.
