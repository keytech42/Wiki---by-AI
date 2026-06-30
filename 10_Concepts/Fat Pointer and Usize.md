---
tags:
  - "#concept/rust"
  - "#concept/memory"
  - "#architecture/ai"
---

# Fat Pointer & usize: Zero-copy 텐서 슬라이싱

## 핵심 통찰
Rust의 슬라이스(`&[f32]`)는 데이터를 통째로 복사하는 것이 아니라, `시작 주소(ptr)`와 `길이(length)`만을 가지는 16 Bytes짜리 **Fat Pointer**를 생성한다. 이를 통해 NPU의 MAC 유닛이 거대한 텐서의 일부분(Tile)만을 가져와 연산할 때 완벽한 제로 카피(Zero-copy)를 달성한다.

## usize의 물리적 당위성
Fat Pointer의 `length` 타입은 고정된 정수가 아닌, CPU 아키텍처의 포인터 크기에 종속되는 `usize` 타입이다.
- 64-bit OS에서는 `usize`가 8 Bytes($2^{64}$)를 차지한다.
- **Aha-moment:** 길이를 표현하는 데 8 Bytes나 사용하는 것을 낭비로 볼 수 없다. 만약 4 Bytes(`u32`)로 강제했다면, 주소 지정의 한계로 인해 배열(텐서) 1개의 최대 크기가 4GB로 제한된다. 수십 GB~수백 GB를 넘나드는 현대 AI(LLM 가중치 등)의 연속된 텐서 공간을 다루기 위해 $2^{64}$를 커버하는 대역폭은 선택이 아닌 필수 불가결한 물리적 스펙이다.

## 시뮬레이터 설계 관점의 이점
파이썬에서 `tensor[0:4]`처럼 객체를 힙(Heap)에 새로 복사하여 메모리를 점유하고 GC 사이클을 낭비하는 대신, 포인터만 던져주되 `length`를 하드웨어적으로 강제 결합(Fat Pointer)하여 메모리 안전성(버퍼 오버플로우 방지)과 성능(Zero-copy)을 동시에 획득한다.
