---
tags:
  - concept/learning_theory
  - machine_learning/generalization
  - concept/capacity
  - paper/zhang_2017
---

# Rademacher 복잡도의 한계와 랜덤 라벨 암기 (Zhang et al., 2017)

## 1. 개요
이 문서는 Mehryar Mohri의 "Foundations of Machine Learning" 등 고전 학습 이론에서 다루는 수학적 증명(예: Rademacher Complexity)의 한계와 실증적 현상 간의 괴리를 기록한다. 모델의 일반화 성능을 $\hat{\mathcal{R}}_S(\mathcal{H}) = \mathbb{E}_\sigma \left[ \sup_{h \in \mathcal{H}} \frac{1}{n} \sum_{i=1}^n \sigma_i h(x_i) \right]$ 와 같은 지표로 상한(Bound) 지으려는 시도는, 오버파라미터라이즈드(Over-parameterized) 신경망이 등장함에 따라 실증적인 설명력을 상실했다.

## 2. 수식의 기하학적 실체 (Empirical Translation)
* **$\sigma_i$ (Rademacher Variable):** 데이터의 내재적 패턴을 완전히 배제한 순수한 무작위 난수 라벨(Noise Label).
* **$\sup_{h}$ (Supremum):** 최적화 과정(Gradient Descent)을 통해 주어진 라벨 공간에 결정 경계(Decision Boundary)를 피팅하는 궤적.
* **물리적 본질:** Rademacher 복잡도는 "가설 공간 $\mathcal{H}$가 완전히 무작위인 노이즈 라벨을 얼마나 완벽하게 암기(Memorization)할 수 있는가"에 대한 수용력(Capacity) 지표이다.

## 3. 무작위 라벨 암기 실험 및 결과
Zhang et al.(2017)의 딥러닝 일반화 논문 실험을 추상화하여, 패턴이 전혀 없는 데이터와 랜덤 라벨을 신경망이 어떻게 피팅하는지 재현한다.

### 실험 코드 (PyTorch)
```python
import torch
import torch.nn as nn
import torch.optim as optim

def run_memorization_experiment():
    N, D, H = 1000, 100, 512
    torch.manual_seed(42)
    
    # 패턴이 전혀 없는 데이터와 랜덤 라벨 생성 (\sigma_i의 물리적 구현)
    X = torch.randn(N, D)
    y_random = torch.randint(0, 2, (N,))
    
    # 결정 경계를 유연하게 변형할 수 있는 고용량 아키텍처
    model = nn.Sequential(
        nn.Linear(D, H), nn.ReLU(),
        nn.Linear(H, H), nn.ReLU(),
        nn.Linear(H, 2)
    )
    
    optimizer = optim.Adam(model.parameters(), lr=0.01)
    criterion = nn.CrossEntropyLoss()
    
    print("[Training Logs]")
    for epoch in range(200):
        optimizer.zero_grad()
        logits = model(X)
        loss = criterion(logits, y_random)
        loss.backward()
        optimizer.step()
        
        preds = torch.argmax(logits, dim=1)
        acc = (preds == y_random).float().mean() * 100
        
        if (epoch + 1) % 50 == 0 or epoch == 0:
            print(f"Epoch {epoch+1:3d} | Loss: {loss.item():.4f} | Train Acc: {acc.item():.2f}%")

if __name__ == "__main__":
    run_memorization_experiment()
```

### 실행 결과
```text
[Training Logs]
Epoch   1 | Loss: 0.6926 | Train Acc: 52.50%
Epoch  50 | Loss: 0.0000 | Train Acc: 100.00%
Epoch 100 | Loss: 0.0000 | Train Acc: 100.00%
Epoch 150 | Loss: 0.0000 | Train Acc: 100.00%
Epoch 200 | Loss: 0.0000 | Train Acc: 100.00%
```

## 4. 고전 학습 이론 수식의 붕괴 (Vacuous Bound)
위 실험 결과는 고용량 신경망이 데이터 간의 인과관계 없이도 고차원 공간에서 결정 경계를 극단적으로 변형하여 노이즈를 100% 피팅해 낼 수 있음을 실증한다.

1. **Rademacher Complexity의 상수화:** 딥러닝 모델은 무작위 라벨을 완벽히 암기하므로, 경험적 Rademacher 복잡도는 거의 상한인 최댓값(1.0)에 수렴한다.
2. **이론적 모순:** 일반화 오차 한계 공식($Test Error \le Train Error + Complexity$)에 대입할 경우, 오차 상한선 자체가 최댓값이 되어버린다. 
3. 결론적으로 이는 딥러닝 환경에서 모델의 일반화 성능을 통제하거나 예측하는 데 어떠한 기여도 하지 못하는 무의미한 바운드(Vacuous Bound)로 전락한다.

## 5. 결론
고전 통계학습이론의 하향식(Top-down) 수학적 증명은 기계학습 모델의 상한을 정의하는 데에는 유효했으나, 과도하게 파라미터화된 신경망의 실제 성능을 설명하는 데에는 명확한 한계를 지닌다. 엔지니어는 텐서 연산을 이용한 실증적 재현을 통해 수식의 이론적 한계를 간파하고, 무작위 노이즈 암기 현상이 현대 딥러닝 최적화 과정에 내재된 본질적 특징임을 직관적으로 확인해야 한다.
