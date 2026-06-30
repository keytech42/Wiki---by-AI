document.addEventListener("nav", () => {
  // 모바일 환경(<800px)에서는 스크립트 완전 차단
  if (window.innerWidth < 800) return;

  // Prevent duplicate resizers
  if (document.getElementById('quartz-sidebar-resizer-left')) return;

  const sidebars = [
    { element: document.querySelector('.left.sidebar'), side: 'left' },
    { element: document.querySelector('.right.sidebar'), side: 'right' }
  ];

  sidebars.forEach(({ element: sidebar, side }) => {
    if (!sidebar) return;
    
    // 기본 폭 설정
    if (!sidebar.style.width) {
      sidebar.style.width = '320px';
      sidebar.style.minWidth = '200px';
      sidebar.style.maxWidth = '50vw';
    }

    const resizer = document.createElement('div');
    resizer.id = `quartz-sidebar-resizer-${side}`;
    resizer.style.width = '8px';
    resizer.style.cursor = 'col-resize';
    resizer.style.position = 'absolute';
    
    // 모바일/태블릿 초기 로드 시 우측 사이드바 리사이저 숨김 처리
    if (side === 'right' && window.innerWidth < 1200) {
      resizer.style.display = 'none';
      sidebar.style.width = '';
      sidebar.style.minWidth = '';
      sidebar.style.maxWidth = '';
    }
    
    if (side === 'left') {
      resizer.style.right = '0px'; // 우측 가장자리에 딱 맞춤 (padding 영역 안)
    } else {
      resizer.style.left = '0px';  // 좌측 가장자리에 딱 맞춤
    }
    
    resizer.style.top = '0';
    resizer.style.bottom = '0';
    resizer.style.zIndex = '100';
    resizer.style.backgroundColor = 'transparent';
    resizer.style.transition = 'background-color 0.2s';
    
    let isResizing = false;

    resizer.addEventListener('mouseenter', () => {
      resizer.style.backgroundColor = 'var(--tertiary)';
    });
    resizer.addEventListener('mouseleave', () => {
      if (!isResizing) resizer.style.backgroundColor = 'transparent';
    });
    
    sidebar.appendChild(resizer);
    
    resizer.addEventListener('mousedown', (e) => {
      isResizing = true;
      document.body.style.cursor = 'col-resize';
      resizer.style.backgroundColor = 'var(--tertiary)';
      e.preventDefault();
    });
    
    document.addEventListener('mousemove', (e) => {
      if (!isResizing) return;
      const rect = sidebar.getBoundingClientRect();
      let newWidth;
      
      if (side === 'left') {
        newWidth = e.clientX - rect.left;
      } else {
        newWidth = rect.right - e.clientX;
      }
      
      if (newWidth > 150 && newWidth < window.innerWidth * 0.5) {
        sidebar.style.width = newWidth + 'px';
        sidebar.style.minWidth = newWidth + 'px';
        sidebar.style.maxWidth = newWidth + 'px';
      }
    });
    
    document.addEventListener('mouseup', () => {
      if (isResizing) {
        isResizing = false;
        document.body.style.cursor = 'default';
        resizer.style.backgroundColor = 'transparent';
      }
    });
  });

  // 브라우저 창 크기 동적 변경 대응
  let resizeTimer;
  window.addEventListener('resize', () => {
    // 0. 리사이징 중 애니메이션 억제를 위한 클래스 추가
    document.body.classList.add('is-resizing');
    clearTimeout(resizeTimer);
    resizeTimer = setTimeout(() => {
      document.body.classList.remove('is-resizing');
    }, 150);

    // 1. 모바일 진입 시 (800px 미만): 모든 사이드바 초기화
    if (window.innerWidth < 800) {
      sidebars.forEach(({ element: sidebar, side }) => {
        if (!sidebar) return;
        sidebar.style.width = '';
        sidebar.style.minWidth = '';
        sidebar.style.maxWidth = '';
        const resizer = document.getElementById(`quartz-sidebar-resizer-${side}`);
        if (resizer) resizer.style.display = 'none';
      });
    } 
    // 2. 태블릿 진입 시 (800px ~ 1199px): 우측 사이드바만 초기화 (하단으로 빠지므로)
    else if (window.innerWidth >= 800 && window.innerWidth < 1200) {
      sidebars.forEach(({ element: sidebar, side }) => {
        if (!sidebar) return;
        if (side === 'right') {
          sidebar.style.width = '';
          sidebar.style.minWidth = '';
          sidebar.style.maxWidth = '';
          const resizer = document.getElementById(`quartz-sidebar-resizer-${side}`);
          if (resizer) resizer.style.display = 'none';
        } else {
          // 좌측 사이드바는 활성화
          const resizer = document.getElementById(`quartz-sidebar-resizer-${side}`);
          if (resizer) resizer.style.display = 'block';
        }
      });
    }
    // 3. 데스크탑 진입 시 (1200px 이상): 둘 다 활성화
    else {
      sidebars.forEach(({ side }) => {
        const resizer = document.getElementById(`quartz-sidebar-resizer-${side}`);
        if (resizer) resizer.style.display = 'block';
      });
    }
  });
});
