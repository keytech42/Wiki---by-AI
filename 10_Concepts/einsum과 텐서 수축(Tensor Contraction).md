# einsum과 텐서 수축(Tensor Contraction)의 기하학적 매핑

## 1. 개요
`einsum`은 아인슈타인 표기법(Einstein Summation Convention)을 바탕으로 한 다차원 텐서 조작 문법이다. 기존의 `matmul`, `view`, `transpose` 등 직관적이지 않은 블랙박스 API에 의존하던 방식에서 벗어나, 엔지니어가 직접 텐서의 **축(Axis)**을 지배하고 기하학적 매핑을 제어할 수 있게 해준다.

## 2. 텐서 수축(Tensor Contraction)의 본질
`einsum`의 유일한 대원칙은 다음과 같다:
> **"입력 텐서의 어떤 축(Axis)을 보존하고, 어떤 축을 압축(Summation/Reduction)하여 소멸시킬 것인가?"**

*   **매핑 문자열 내의 쉼표(`,`):** 단순한 입력 텐서 간의 축 매핑을 위한 자리 구분자.
*   **곱(Product)의 암묵적 내재:** 둘 이상의 텐서가 공유하는 기준 축을 통해 만나면, 그 요소들은 **반드시 1:1로 곱해진다.**
*   **합(Sum)을 통한 소멸:** 화살표(`->`) 우측(출력 차원)에 명시되지 않은 축은, 곱해진 요소들을 해당 축을 따라 전부 **더함으로써(Summation) 차원을 소멸(Reduction)**시킨다. 오직 선형 대수의 핵심인 '곱의 합' 구조만을 지닌다.

## 3. 평행 우주(Parallel Universes)와 축의 역할 분리
배치(Batch) 차원 `b`나 멀티헤드 어텐션의 헤드 차원 `h`와 같이 좌우변에 모두 살아남는 축들은 연산에 직접 참여하지 않는다.
이들은 **평행 우주(Parallel Universes)**를 생성하여, 핵심적인 차원 축소 연산(`nd, md -> nm`)이 서로 섞이거나 간섭하지 않고 `b * h`개의 독립적인 시공간에서 병렬 수행될 수 있도록 격리된 무대를 제공한다.

## 4. 의미론적 알파벳 (Semantic Indexing)
단순히 수학계의 관행인 `i, j, k`를 사용하는 대신, 차원의 실제 물리적 의미를 담은 알파벳을 사용하는 것이 딥러닝 실무의 강력한 베스트 프랙티스이다. (예: `einops` 라이브러리의 철학)
*   `b`: Batch
*   `h`: Head
*   `n`: Sequence length (Query)
*   `m`: Sequence length (Key/Value)
*   `d`: Head dimension

## 5. 실전 사례: Transformer Multi-Head Attention
기존의 복잡한 `transpose`와 `matmul` 조합 없이 `einsum`만으로 어텐션의 기하학적 공간을 제어할 수 있다.

*   **Attention Score 계산 ($Q \times K^T$):**
    *   $Q$: `(B, H, N, D)`
    *   $K$: `(B, H, M, D)`
    *   `einsum('bhnd, bhmd -> bhnm', Q, K)`
    *   해석: `d` 차원을 따라 텐서 수축(내적)이 발생하고, `b`와 `h` 평행 우주 안에서 시퀀스 간의 관계성 행렬(`n \times m`)이 생성된다.
*   **Value 투영 ($S \times V$):**
    *   $S$ (Score): `(B, H, N, M)`
    *   $V$ (Value): `(B, H, M, D)`
    *   `einsum('bhnm, bhmd -> bhnd', S, V)`
    *   해석: 연관도 행렬의 `m` 차원을 기준으로 수축이 발생하여, 다시 원래의 `d` 차원 공간으로 정보가 투영되고 복원된다.

## 연관 개념 (추후 딥다이브 예정)
* [[VJP와 Autograd 엔진의 해체]]
* [[Roofline Model과 연산 강도(Arithmetic Intensity)]]
