---
tags:
  - "#active_retrieval"
  - "#concept/architecture"
  - "#optimization/cache"
---

# [Exam 01] Rust 아키텍처와 폰 노이만 메모리 매핑

## 📝 문제 1: 메모리 구역(Segments)과 캐시 파이프라인의 물리적 상호작용
**질문:** 객체지향 프로그래밍의 다형성(Dynamic Dispatch, `vtable`)을 사용할 때와 Rust의 단형성화(Monomorphization)를 사용할 때, CPU가 폰 노이만 아키텍처의 4대 메모리 구역(Text, Data, Heap, Stack)을 탐색하는 물리적 궤적을 비교 서술하십시오. 이 궤적의 차이가 I-Cache 파이프라인 붕괴(Flush)와 바이너리 크기(Binary Bloat)에 미치는 트레이드오프를 논증하십시오.

---

## 🛑 사용자 1차 답변 (오개념 포함)
> **사용자 기록:** vtable은 Heap 영역에 보관되어 있어서, 각 함수가 갖는 기계어 코드가 보관된 메모리 주소를 가지고 있다. 중복된 로직은 Text 영역에 보관된다. 하지만 물리적 연속성이 반영 안 되어 cache miss가 나며 연산이 지연된다. 이를 "I-Cache 파이프라인 붕괴"라고 한다. 단형성화에서는 절차적인 로직이 물리적으로 연속적으로 text 영역에 보관되게 함으로써 cache hit이 발생하게 한다. 하지만 Binary Bloat 문제가 생긴다.
> **사용자 질문:** Stack 영역은 로컬 변수 같은 임시 변수들이 쌓이는 공간인데 거기에 객체 포인터가 있나? vtable 참조 시 cache hit/miss 기준은 무엇인가?

---

## 💡 멘토의 정밀 교정 피드백 (Aha-Moment)

### 1. 오개념 교정: 메모리 구역의 실체
- **vtable의 위치:** vtable은 Heap에 있지 않다. 컴파일 타임에 고정되므로 **Data 구역 (RODATA)**에 위치한다. Heap에 있는 것은 동적 객체 본체뿐이며, 그 객체 머리통에 vtable을 가리키는 포인터가 들어있다.
- **Stack과 포인터:** Stack은 크기가 확정된 모든 실물을 담는다. `Box::new()` 등으로 힙에 객체를 만들면, 힙에 뚱뚱한 데이터가 생기고 Stack에는 8바이트짜리 얇은 '손잡이(포인터)'만 임시 변수로 들어간다.

### 2. Pointer Chasing의 재앙 (다형성의 널뛰기 궤적)
다형성을 쓰면 CPU는 다음과 같이 4구역을 널뛰기한다.
1. `Stack`: 객체 포인터 읽기 (D-Cache)
2. `Heap`: 점프하여 객체 본체 찾기 (D-Cache Miss 위험 - 파편화 공간)
3. `Data`: 점프하여 vtable 주소 읽기 (D-Cache Miss 위험)
4. `Text`: 알아낸 주소로 점프하여 기계어 실행 (I-Cache Pipeline Flush)

### 3. I-Cache Pipeline Flush (파이프라인 붕괴)의 원리
CPU는 똑똑하게도 현재 실행 중인 코드 뒤의 명령어들을 미리 읽어 I-Cache 파이프라인에 올려둔다(Prefetch). 그러나 런타임에 vtable을 까보기 전까지 다음 목적지를 모르는 다형성은, 점프(Jump) 순간 CPU가 미리 가져온 파이프라인 레시피를 전부 쓰레기통에 버리게 만든다. 

### 4. 단형성화(Monomorphization)의 구원과 공간 지역성
단형성화는 함수의 주소를 런타임이 아닌 컴파일 타임에 확정한다.
vtable을 없애고, 목적지 함수의 기계어를 호출부(Text 구역)에 그대로 복붙해버린다(**인라인화, Inlining**). CPU는 점프 없이 미리 읽어둔 파이프라인을 그대로 소비하므로 광속 연산이 가능해진다. 데이터 역시 Heap에 흩뿌리지 않고 배열에 일렬로 욱여넣을 수 있어 D-Cache Hit이 보장된다.
