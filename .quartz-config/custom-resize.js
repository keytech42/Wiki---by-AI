document.addEventListener("nav", () => {
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
    
    if (side === 'left') {
      resizer.style.right = '-4px'; // Center on the edge
    } else {
      resizer.style.left = '-4px';
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
});
