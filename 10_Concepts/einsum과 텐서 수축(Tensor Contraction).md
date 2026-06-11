---
tags:
  - concept/tensor_calculus
  - concept/geometric_mapping
  - architecture/attention
---

# einsum과 텐서 수축(Tensor Contraction)의 본질과 기하학적 궤적

## 1. 차원의 감옥과 기존 API의 블랙박스 한계
딥러닝 실무에서 대다수의 주니어 엔지니어들은 `RuntimeError: shape mismatch`를 마주하면 에러가 사라질 때까지 `.view()`, `.unsqueeze()`, `.transpose()`를 맹목적으로 끼워 맞춘다. 
예를 들어 어텐션의 $QK^T$를 계산할 때, 단순히 행렬 곱 규칙을 억지로 맞추기 위해 `K.transpose(-1, -2)`를 호출한다. 이는 자신이 메모리 상의 어떤 축을 뒤집고 있는지 물리적 감각이 완전히 결여된, **'차원에 끌려다니는 겉핥기식 코딩'**의 전형이다.

## 2. einsum: 축(Axis)의 완벽한 통제권
`einsum`(Einstein Summation Convention)은 차원을 대충 맞추는 도구가 아니라, **엔지니어가 기하학적 공간의 축을 직접 통제하는 절대적 문법**이다. 
이 문법을 관통하는 단 하나의 거대한 대원칙은 다음과 같다:
> **"입력 텐서들의 어떤 축(Axis)을 보존하고, 어떤 축을 맞닿게 하여 압축(Summation)시킬 것인가?"**

*   **연산자의 암묵적 고정:** `einsum`의 세계관에서는 여러 텐서가 공유하는 축을 통해 만나면 **반드시 1:1로 곱해진다(Product).**
*   **소멸의 유일한 방법:** 출력 차원(화살표 우측)에 명시되지 않은 축은, 앞서 곱해진 요소들을 해당 축을 따라 **전부 더함으로써(Summation) 차원을 소멸(Reduction)**시킨다. `max`나 `mean`은 허용되지 않으며, 오직 '곱의 합' 구조만을 지닌다. 이것이 선형 대수학에서 말하는 **'텐서 수축(Tensor Contraction)'**의 기하학적 본질이다.

## 3. 기하학적 Aha-moment: 평행 우주 (Parallel Universes)
가장 극적인 통찰은 3차원 이상의 텐서(예: Batch Matrix Multiplication)를 다룰 때 발생한다.
```python
einsum('bik, bkj -> bij', X, Y)
```
여기서 좌변과 우변에 모두 살아남는 축 `b` (Batch)는 도대체 연산에 어떻게 참여하는가?
*   **평행 우주의 생성:** `b` 축은 `i`, `j`, `k` 간의 핵심적인 텐서 수축 연산(`ik, kj -> ij`)에 직접 간섭하거나 섞이지 않는다.
*   대신, `b` 차원의 크기만큼 완전히 독립적으로 격리된 **평행 우주(시공간 무대)**를 제공한다.  \
    즉, 핵심 연산은 <u>**공통 축(`k`)의 맞닿음과 소멸**</u>에 있고, 나머지 보존되는 축들은 그 핵심 연산을 브로드캐스팅(Broadcasting)하는 구조적 뼈대 역할만 수행한다.

## 4. 시니어의 설계 철학: 의미론적 알파벳 (Semantic Indexing)
수학계의 관용적 관행인 `i, j, k` 대신, 텐서 차원의 실제 물리적/구조적 의미를 담은 알파벳을 사용하는 것이 딥러닝 인프라의 베스트 프랙티스이다. (예: `einops` 라이브러리의 철학)
*   `b`: Batch (평행 우주)
*   `h`: Head (평행 우주)
*   `n`: Query Sequence length (독립 축)
*   `m`: Key/Value Sequence length (수축 또는 유지되는 축)
*   `d`: Head dimension (수축 또는 투영되는 축)

## 5. 실전 매핑: Transformer Multi-Head Attention의 1:1 직역
어텐션 연산은 수식과 `einsum` 코드가 한 치의 오차 없이 기하학적으로 1:1 매핑된다.

**Step 1: Attention Score 계산 ($Q \times K^T$)**
```python
einsum('bhnd, bhmd -> bhnm', Q, K)
```
*   **물리적 해석:** `b`와 `h`라는 겹겹의 평행 우주 안에서, 쿼리(길이 `n`)와 키(길이 `m`)가 헤드 차원 `d`를 매개체로 만난다. `d` 축을 따라 요소들이 서로 곱해지고 합쳐지면서(수축), 두 시퀀스 간의 관계성을 나타내는 `n \times m` 크기의 2차원 연관도 행렬이 새롭게 창조되어 남는다.

**Step 2: Value 투영 ($S \times V$)**
```python
einsum('bhnm, bhmd -> bhnd', S, V)
```
*   **물리적 해석:** 앞서 창조된 연관도 행렬 $S$와 실제 정보 $V$가 만난다. 이번에는 시퀀스 길이 `m` 축을 매개체로 하여 텐서 수축이 발생한다. `m` 축이 짓눌리며 소멸함과 동시에, 텐서는 다시 원래의 차원 공간인 `d` 공간으로 정보가 투영되어 완벽히 복원된다.

---
**[Insight Summary]**
`einsum`을 마스터한다는 것은 단순히 API의 사용법을 외우는 것이 아니다. 논문에서 아무리 기괴한 다차원의 텐서 수식이 등장하더라도, **어떤 축이 평행 우주를 형성하고 어떤 축이 수축(Contraction)되어 소멸하는지** 그 궤적을 눈으로 정확히 추적하고 코드로 직역해 낼 수 있는 절대적인 자유를 얻는 것이다.
