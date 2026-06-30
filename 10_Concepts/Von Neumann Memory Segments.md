---
tags:
  - "#concept/architecture"
  - "#concept/os"
  - "#optimization/cache"
---

# 폰 노이만 구조와 RAM의 4대 구역 매핑 (I-Cache vs D-Cache)

## 핵심 통찰
시뮬레이터의 병목을 추적하려면 코드가 물리적 메모리의 어느 구역(Segment)에 올라가고, CPU의 어떤 입(Cache)을 통해 빨려 들어가는지 투시할 수 있어야 한다.

## 거대한 도서관 (RAM의 4대 구역)
1. **Text 구역 (명령어):** 실행할 기계어 코드 보관 (고정 크기)
2. **Data 구역 (정적 데이터):** 전역 변수, vtable 같은 고정된 라우팅 지도 보관
3. **Heap 구역 (동적 데이터):** 스마트 포인터, 동적 배열 등이 위치하는 식재료 창고
4. **Stack 구역 (지역 변수):** 함수 호출 시 임시로 사용하는 도마

## CPU의 두 개의 입과 캐시 붕괴 현상
- **I-Cache (Instruction Cache):** 오직 Text 구역만 읽어오는 입. 공간 지역성(연속성)을 띄는 일자형 코드를 매우 좋아함.
- **D-Cache (Data Cache):** Data, Heap, Stack 구역을 읽어오는 입.

**다형성(vtable)의 재앙적 흐름:**
객체를 Heap에서 읽음(D-Cache) -> vtable 포인터를 타고 Data 구역으로 점프(D-Cache) -> vtable에서 알아낸 주소로 Text 구역 점프(I-Cache)
이 과정에서 I-Cache가 다음 줄을 미리 읽어두던 파이프라인이 붕괴(Flush)되며 막대한 CPU 사이클이 낭비된다. 단형성화(Monomorphization)는 비록 Text 구역의 덩치를 불리더라도 이 파이프라인 붕괴를 막기 위해 기계어를 복사(하드코딩)하는 공간-시간 트레이드오프다.
