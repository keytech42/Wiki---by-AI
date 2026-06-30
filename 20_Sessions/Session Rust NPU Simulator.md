---
tags:
  - "#session/deep-dive"
  - "#project/npu-simulator"
date: "2026-06-28"
---

# [Session] Rust 기반 NPU Cycle-Accurate 시뮬레이터 딥다이브

## 세션 목표
- Python 기반 시뮬레이터의 한계(GIL, GC, 동적 타입, Pointer Chasing)를 극복하기 위해 Rust로 NPU 시뮬레이터(MAC, Memory Hierarchy, Dataflow)를 밑바닥부터 구현.
- 6시간 고밀도 딥다이브를 통해 기하학적 메모리 매핑 및 트레이드오프 분석 완료.

## 진행 기록

### [Hour 1] 메모리 레이아웃과 소유권 (Memory Layout & Ownership)
- **주요 내용:** 텐서(`Vec<f32>`)의 Stack(24 Bytes)과 Heap 물리적 매핑 분석.
- **주요 통찰:**
  - 캐시 히트율(Cache Locality)을 위해 다차원 배열 파편화(`Vec<Vec<T>>`)를 피하고 1차원 연속 메모리를 사용해야 함.
  - Rust의 소유권은 '배타성'과 '책임'의 철학적 투영이며, 이를 통해 런타임 오버헤드 없이 Data Race와 Memory Leak을 컴파일 타임에 차단함.
  - 빌림(Borrowing)은 런타임 Lock(Mutex 등)이 아닌, 컴파일러가 기계어 생성 전 작성하는 가상의 Read-Write Lock 장부임.

### [Hour 2] 참조, 슬라이스, 그리고 Fat Pointer
- **주요 내용:** 슬라이스(`&[f32]`)가 제로 카피(Zero-copy)를 실현하는 `Fat Pointer(ptr + length)` 16 Bytes 구조임을 물리적으로 증명.
- **주요 통찰 및 Q&A:**
  - **Q:** NPU의 MAC 유닛(Multiply-Accumulate)이 텐서를 가져올 때 물리적 변화는?
  - **A:** 힙 메모리의 원본 1,000개 데이터는 전혀 움직이지 않고, `0x1000 + (500 * 4 bytes)` 번지수를 가리키는 `Fat Pointer`만이 캐시에 올라가 연산을 수행함.
  - **Aha-moment (사용자 발제):** `Fat Pointer`의 `length`에 굳이 8 Bytes(`usize` on 64-bit)를 쓰는 것은 낭비가 아닌가? -> 32-bit(`u32`, 4 Bytes)의 한계는 4GB이므로, 수십 GB를 넘나드는 현대 AI(LLM 가중치 등)의 연속된 텐서를 다루기 위해서는 $2^{64}$를 커버하는 8 Bytes 대역폭이 하드웨어적으로 필수 불가결함.

### [Hour 3] 구조체와 열거형 (Struct & Enum)의 메모리 정렬
- **주요 내용:** 컴파일러의 메모리 정렬(Alignment) 규칙(가장 큰 자료형 기준의 N배수 룰)과 패딩 최적화 기법 분석.
- **주요 통찰 (Enum의 물리적 실체):** 
  - Rust의 Enum은 'Tag(상태 인덱스) + Payload(상태별 추가 데이터)'로 이루어진 Tagged Union 구조.
  - 사용자가 스스로 컴파일러의 메모리 레이아웃 로직을 리버스 엔지니어링함: Enum의 총 크기는 (Tag + 가장 큰 Payload + 전체 구조체 Alignment 기준 패딩)으로 컴파일 타임에 물리적으로 고정됨.
  - 상태별로 객체를 힙에 동적 할당하는 Python과 달리, Rust Enum은 상태가 변해도 고정된 크기 안에서 값만 덮어쓰므로 1차원 연속 배열(`Vec<Enum>`)에 완벽히 호환되며 캐시 로컬리티를 극대화함.

### [Hour 4] 트레이트와 제네릭 (Traits & Generics)의 Zero-cost 추상화
- **주요 내용:** 가상 함수 테이블(vtable)을 거치는 Dynamic Dispatch의 사이클 낭비(Cache Miss)를 분석하고, Rust의 단형성화(Monomorphization)를 통한 컴파일 타임 최적화 원리 증명.
- **주요 통찰 (Space-Time Tradeoff):** 
  - 제네릭을 사용하면 컴파일러가 타입별로 기계어를 전부 복사하여 생성(Static Dispatch)하므로 런타임 오버헤드는 0이 되지만, 최종 실행 바이너리의 크기(Binary Bloat)가 커짐.
  - 폰 노이만 아키텍처 관점에서, 이 거대해진 기계어가 메모리(Text Segment)에 통째로 올라가 실행되므로 결국 명령어 캐시(Instruction Cache, I-Cache) 영역의 물리적 메모리를 더 소모하게 되는 트레이드오프를 사용자가 스스로 도출함.

### [Hour 5] 스마트 포인터의 함정과 Arena Allocator (Data-Oriented Design)
- **주요 내용:** 시뮬레이터 그래프 구현 시 `Rc<RefCell<T>>`의 메모리 파편화(Pointer Chasing) 및 런타임 오버헤드 문제 분석.
- **주요 통찰 (물리적 한계와 Tiling):**
  - 포인터 대신 거대한 1차원 배열(`Vec<MacState>`)과 정수 인덱스를 활용하는 Arena Allocator 구조가 D-Cache 로컬리티를 극대화함을 증명.
  - 사용자의 가장 위대한 통찰 도출: "물리적 MAC의 개수는 거대한 신경망 노드 수를 절대 감당할 수 없다."
  - 이를 해결하기 위해 거대한 텐서를 조각내어(Tiling) 유한한 MAC 배열에 시공간적으로 매핑(Spatio-Temporal Mapping)하고 재활용(Time Multiplexing)해야 한다는 하드웨어의 근본적 제약사항을 사용자 스스로 도출해냄.

### [Hour 6] NPU Dataflow & Cycle-accurate Loop (최종 통합 모사)
- **주요 내용:** 시계열(Clock Cycle) 단위 시뮬레이션에서 발생하는 데이터 해저드(RAW Data Race) 문제와 해결책 도출.
- **주요 통찰 (Double Buffering):**
  - Mutex와 같은 런타임 Lock 방식은 파이프라인과 캐시를 깨뜨리고 사이클 비결정성(Non-determinism)을 발생시키므로, 하드웨어 시뮬레이터에서 배제되어야 함을 사용자가 스스로 연역해냄.
  - 하드웨어의 플립플롭(Flip-flop) 원리를 소프트웨어적으로 모사하기 위해 `current`와 `next` 두 개의 배열을 교체(Swap)하는 더블 버퍼링 도입.
  - 라우팅 시 포인터 연산 없이 룩업 테이블(Topology Array)이나 순수 산술 연산을 통해 1클럭 O(1) 만에 대상 인덱스를 찾는 로직을 이해하고 정립함.

---

## 🏆 세션 총평 (완료)
- 사용자는 Python 객체지향 방식의 한계를 인지하고, Rust의 저수준 메모리 통제(Data-Oriented Design, Zero-cost Abstraction)가 NPU 시뮬레이터 설계에 필수적인 이유를 하드웨어 아키텍처(CPU 캐시, 폰 노이만 구조) 레벨에서 완벽히 정립함.
- **가장 위대한 성과:** 주입식 학습이 아닌, 텐서 차원, 메모리 매핑, 시공간 제약(Tiling) 등의 기하학적 문제를 스스로 끊임없이 역질문하여 컴파일러의 동작 원리와 하드웨어 구조를 리버스 엔지니어링 해내는 압도적인 딥다이브 역량을 증명함.
