---
tags:
  - Concept
  - Hardware
  - NumPy
aliases:
  - Shift Register Simulation
---
# Shift Register Abstraction in NumPy

Systolic Array와 같은 파이프라인 하드웨어를 파이썬 코드로 시뮬레이션할 때, 소프트웨어 개발자는 하드웨어의 '클럭(Clock)'과 '레지스터(Register)'의 동작을 소프트웨어 문법으로 추상화해야 한다.

## 1. 하드웨어 동작의 소프트웨어 추상화
하드웨어의 파이프라인에서는 **시프트 레지스터(Shift Register)**가 매 클럭(Clock Cycle)마다 데이터를 한 방향으로 순차 이동시킨다. 
NumPy에서는 복잡한 루프(for-loop) 없이 **배열 슬라이싱(Slicing)** 연산을 통해, 클럭 엣지(Clock Edge)에서 발생하는 동시다발적인 물리적 데이터 이동을 벡터화하여 추상화한다.

## 2. 구현 패턴 (가로/세로 이동)
Systolic Array의 1 Physical + 3 Logical Layers 멘탈 모델에 따라, 두 가지 동적 레이어(가로로 흐르는 활성화 입력 $A$, 세로로 흐르는 부분합 $C$)의 이동을 파이썬 스니펫으로 구현하면 다음과 같다.

```python
# 1. Activation A (가로축 컨베이어 벨트 - Shift Right)
new_pe_a[:, 1:] = current_pe_a[:, :-1]
new_pe_a[:, 0] = input_a_skewed

# 2. Partial Sum C (세로축 폭포수 - Shift Down)
new_pe_c[1:, :] = current_pe_c[:-1, :]
new_pe_c[0, :] = 0  # 최상단은 이전 누적값이 없으므로 0 주입

# 3. MAC 연산 수행 및 다음 클럭을 위한 상태 업데이트 (Clock Edge 완료)
current_pe_c = new_pe_c + (new_pe_a * stationary_b)
current_pe_a = new_pe_a
```

## 3. 물리적 의미
- 위 연산은 일반적인 텐서 연산을 위한 소프트웨어적인 배열 복사 로직이 아니다.
- `current_pe_a`나 `current_pe_c`는 메모리에 영구 저장된 정적 데이터가 아니라, 파이프라인의 특정 PE(Processing Element) 스테이지에 도달해 있는 **현재 순간의 전압 상태**를 의미한다.
- 배열의 인덱스가 바뀌는 것은 데이터가 이웃한 하드웨어 유닛으로 전송됨을 의미하며, 할당문(`=`)은 다음 클럭 사이클로의 상태 전이(State Transition)가 물리적으로 완료되었음을 강제하는 역할을 한다.
