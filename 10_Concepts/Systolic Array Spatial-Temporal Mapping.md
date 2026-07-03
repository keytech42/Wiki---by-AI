---
tags:
  - Concept
  - Hardware
  - DeepLearning
aliases:
  - Weight-Stationary Systolic Array
  - Systolic Array Mental Model
---
# Systolic Array Spatial-Temporal Mapping

딥러닝의 행렬 곱셈 $C = A \times B$를 연산할 때, 하드웨어(TPU 등)는 수천 개의 곱셈-누산기(MAC)를 2차원 격자 형태로 묶은 **Systolic Array** 구조를 사용한다. 
이때 2차원의 물리적 한계를 극복하고 데이터 충돌 없이 연산을 수행하기 위해, 데이터를 2차원 공간과 시간 축으로 분산시키는 **시공간적 매핑(Spatial-Temporal Mapping)**이 필수적이다.

## 1. 텐서 차원의 기하학적 매핑과 타일링(Tiling)
- **입력 행렬**: 활성화(Activation) $A$ ($M \times K$), 가중치(Weight) $B$ ($K \times N$)
- **출력 행렬**: 부분합(Partial Sum) $C$ ($M \times N$)

실제 인공신경망의 거대한 행렬은 하드웨어에 한 번에 들어가지 않으므로, PE(Processing Element, 곱셈-누산기 하나를 의미하는 단위 연산기) 배열의 물리적 크기인 $K \times N$ 규격에 맞춰 타일(Tile) 단위로 쪼개져서 처리된다고 가정한다.

Weight-Stationary 방식에서는 가중치 행렬 $B$ 타일을 $K \times N$ PE 배열에 1:1로 고정(Stationary)시킨다. 즉, $\text{PE}[i, j]$는 $B[i, j]$ 값을 영구적으로 쥐고 있다.
이 상태에서 입력 행렬 $A$ 타일은 PE 배열의 왼쪽 가장자리(Left-edge)를 통해 진입해야 한다. 이때 $A$ 타일은 본래 $M \times K$ 차원이지만, 진입구인 왼쪽 가장자리의 높이가 $K$이므로 크기를 맞추기 위해 **$K \times M$ 차원으로 Transpose**되어 밀려 들어간다.

## 2. 시간적 매핑 (Temporal Skewing)
Transpose된 행렬 $A$의 데이터들이 횡대(ㅡ자)로 나란히 진입할 경우, 모든 연산기가 동시에 데이터를 요구하게 되어 데이터 충돌과 타이밍 불일치가 발생한다.
이를 방지하기 위해 데이터를 비스듬히 눕혀서(Skew) 계단식으로 투입한다.

- 첫 번째 행 데이터는 클럭 $t=0$에 진입하지만, 두 번째 행은 $t=1$, 세 번째 행은 $t=2$에 진입하도록 의도적인 **지연(Delay)**을 준다.
- 스큐잉으로 인해 PE 배열이 완전히 채워질 때까지(Pipeline fill-up) 빈 공간(Bubble)이 존재하게 되며, 이는 수식적으로 $N(N+1)/2$ 만큼의 사이클 소모로 나타난다. 하지만 파이프라인이 꽉 차는 Steady-state에 도달하면 매 클럭 100%의 연산 효율을 보장한다.
- 부분합 연산은 누적되며 위에서 아래로 흐른다. $C$ 행렬의 특정 원소 $C[m,n]$의 계산이 완료되는 시점은 세로축 높이 $K$를 모두 통과한 시점이므로, 물리적으로 **$t = m + K + n$** 클럭에서 공장(Array) 밖으로 출력된다.

## 3. 직관적인 멘탈 모델 (1 Physical + 3 Logical Layers)
Systolic Array의 동작은 1개의 물리적 작업대 위에서 3개의 서로 다른 성질을 가진 데이터 층이 겹쳐지는 현상으로 시각화할 수 있다. 서로 상충하는 비유를 배제하면 다음과 같다.

1. **물리적 계층 (1 Physical Layer)**:
   - **Compute Grid**: $K \times N$ 개의 PE로 이루어진 고정된 2차원 하드웨어 보드.

2. **논리적 계층 (3 Logical Layers)**:
   - **부동 레이어 (Stationary Data)**: 하드웨어 보드에 고정된 가중치 타일 $B$.
   - **동적 레이어 1 (Activation Data)**: 가로축을 따라 왼쪽에서 오른쪽으로 흐르는 컨베이어 벨트 (Skewed $A$).
   - **동적 레이어 2 (Partial Sum Data)**: 세로축을 따라 위에서 아래로 누적되며 떨어지는 폭포수 ($C$).
