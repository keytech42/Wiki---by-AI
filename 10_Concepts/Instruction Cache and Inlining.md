---
tags:
  - "#concept/architecture"
  - "#optimization/cache"
  - "#compiler/monomorphization"
---

# Instruction Cache (I-Cache) 공간 지역성과 인라인화

## 핵심 통찰
데이터 캐시(D-Cache)가 연속된 배열(Array)에서 극강의 효율을 내듯, 명령어 캐시(I-Cache) 역시 **연속된 명령어(Instruction)의 흐름**에서 캐시 적중률(Hit Rate)이 극대화된다.

## 점프(Jump)와 공간 지역성(Spatial Locality)
- 컴파일러가 가상 함수(vtable)를 통한 분기(Jump)를 혐오하는 이유는, 점프가 발생하는 순간 I-Cache가 주변 메모리를 덩어리째 미리 가져오는(Prefetching) **공간 지역성의 이점**이 산산조각 나기 때문이다.
- 점프를 만나면 CPU는 미리 읽어둔 명령어 파이프라인을 전부 폐기(Pipeline Flush)하고 새로운 주소로 이동해서 처음부터 다시 읽어야 한다.

## 단형성화(Monomorphization)의 진정한 목적
Rust의 제네릭 단형성화와 인라인화(Inlining)는 결국 **"명령어의 공간 지역성을 최대화하기 위한 극단적 선택"**이다.
- 중복된 기계어를 수없이 찍어내어 실행 바이너리 크기가 비대해지는(Binary Bloat) 낭비를 감수하더라도, 함수 호출을 위한 점프를 없애고 명령어들을 1자형 고속도로로 쫙 펴버린다.
- 결과적으로 연산 장치(CPU)는 분기 예측 실패나 파이프라인 정지 없이 순차적으로 I-Cache를 채우며 압도적인 속도로 시뮬레이션 사이클을 밀어붙일 수 있다.
