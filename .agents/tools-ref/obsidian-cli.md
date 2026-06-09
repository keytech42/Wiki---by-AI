# Obsidian Command Line Interface (CLI)

Obsidian v1.12 버전부터 **공식 CLI(Command Line Interface)**가 내장되어 있습니다. 이 도구는 터미널을 통해 Obsidian Vault를 제어하고, 노트를 관리하며, 워크플로우를 자동화하는 데 매우 강력한 가치를 제공합니다. AI 에이전트가 Zettelkasten 시스템을 관리할 때 파일 시스템에 직접 접근하는 것 외에도 애플리케이션 레벨의 제어가 필요할 때 사용합니다.

## 핵심 가치 및 활용도 (에이전트 관점)
1. **노트 및 UI 제어:** 에이전트가 생성한 특정 노트를 사용자의 화면에 즉각적으로 띄워주거나(`open`), 작업 중인 워크스페이스 상태를 제어할 수 있습니다.
2. **명령어 및 플러그인 실행:** Obsidian 내부에 설치된 다양한 서드파티 플러그인(Graph View, Excalidraw 등)을 터미널 명령으로 트리거할 수 있습니다.
3. **통합 및 자동화:** 셸 스크립트와 결합하여, 백그라운드 작업(예: 대규모 마이그레이션 후 옵시디언 캐시 리로드 등)을 자동화할 수 있습니다.

## 설정 방법
- Obsidian 앱 내 **Settings → General** 메뉴에서 **Command Line Interface** 옵션을 활성화해야 합니다.
- 화면의 안내에 따라 시스템 `PATH`에 CLI를 등록합니다.

## 기본 명령어 예시 (공식)
- `obsidian open "노트 이름"` : 특정 노트 열기
- `obsidian search "검색어"` : 앱 내 검색 트리거
- `obsidian command "Command Name"` : 팔레트 명령어 실행

*(추가적으로 `kepano/obsidian-skills`나 `obsidian-vault-cli` 등의 커뮤니티 도구들을 활용하면 MCP나 REST API 형태로도 통신망을 확장할 수 있습니다.)*
