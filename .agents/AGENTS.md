
- 언제나 `_`로 시작하는 파일과 디렉토리를 읽을 것. 아래 스크립트 실행.

```shell
echo "<context_paths>"
find . -type d \( -name .git -o -name node_modules \) -prune \
  -o -type d -name "_*" -prune -exec find {} \; \
  -o -name "_*" -print | sort
echo "</context_paths>"
```

---
