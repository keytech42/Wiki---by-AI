---
tags:
  - "#concept/memory"
  - "#concept/rust"
  - "#architecture/low-level"
  - "#optimization/cache"
---

# Memory Alignment & Struct Padding (메모리 정렬과 구조체 패딩)

## 핵심 통찰
구조체의 메모리 배치는 단순히 변수들을 일렬로 나열하는 것이 아니라, CPU의 메모리 Fetch 규격을 맞추기 위한 **"바이트 단위의 기하학적 테트리스"**다. 이를 간과하면 무의미한 패딩(Padding) 데이터가 캐시(Cache)를 오염시켜 엄청난 대역폭 낭비를 초래한다.

## 하드웨어의 대원칙 (N의 배수 룰)
> **"크기가 N Bytes인 데이터는, 반드시 주소값이 N의 배수인 곳에서 시작해야 한다."**

- `u8` (1 Byte) -> 모든 주소 (1의 배수) 가능
- `u32` (4 Bytes) -> 0, 4, 8, 12... 번지에서 시작
- `u64` (8 Bytes) -> 0, 8, 16, 24... 번지에서 시작

## 구조체 패딩(Padding) 발생 원리와 그룹핑
컴파일러는 위 대원칙을 지키기 위해 변수 사이에 빈 공간(Padding)을 끼워 넣는다. 구조체 전체의 크기 또한 가장 큰 자료형 크기의 배수로 맞춰진다.

### 1. 최악의 배치 (흩어진 경우)
```rust
struct BadPacket {
    flag1: u8, // 1 Byte + 7 Bytes Padding
    data: u64, // 8 Bytes
    flag2: u8, // 1 Byte + 7 Bytes Padding
}
// 총 24 Bytes
```

### 2. 최적의 배치 (작은 변수 그룹핑)
```rust
struct GoodPacket {
    data: u64, // 8 Bytes
    flag1: u8, // 1 Byte
    flag2: u8, // 1 Byte
    // 6 Bytes Padding (구조체 끝에만 발생)
}
// 총 16 Bytes
```
작은 변수들(`u8` 등)을 모아두면, 서로의 정렬 규칙을 방해하지 않고 자투리 공간(Offset)을 차곡차곡 채우게 되어 패딩이 획기적으로 감소한다.

## 시뮬레이터 설계 관점의 교훈
수백만 개의 노드(MAC 상태 등)를 배열로 관리하는 NPU 시뮬레이터에서 구조체의 크기는 성능의 알파와 오메가다. 불필요한 패딩으로 인해 구조체가 비대해지면, CPU L1 Cache에 담을 수 있는 실제 유효 데이터 수가 줄어들어 치명적인 **Cache Miss**를 유발한다. 메모리는 공간의 문제가 아니라 **대역폭과 시간의 문제**임을 잊지 말아야 한다.
