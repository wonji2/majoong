local $/; $_=<STDIN>;
my $n=0;
# 1) 하교 칩 제거
$n+=s{<span class="time" id="timechip">하교 14~18시</span>}{};
# 2) 시간 슬라이더 바 제거
$n+=s{ <div class="tbar"><span class="now" id="nowBtn">● 실시간</span><input type="range" id="tslider"[^\n]*</div>\n}{};
# 3) tslider 핸들러 제거
$n+=s{tslider\.oninput=e=>\{[^\n]*\n}{};
# 4) timechip 핸들러 제거
$n+=s{/\* 하교 시간대 칩 \*/\ntimechip\.onclick=[^\n]*\n}{};
# 5) ANA 시간대별 사고 → 토스트만
$n+=s{ '⏰ 시간대별 사고':\(\)=>\{toast\("하교 시간대로 이동했어요"\);tslider\.value=15;tslider\.oninput\(\{target:tslider\}\);\},}{ '⏰ 시간대별 사고':()=>toast("오후 2~6시가 가장 위험한 시간이에요"),};
# 6) 데모 마커·원 → 숨김 배열로, preview 때만 표시
$n+=s{L\.circle\(\[SCHOOL\.lat,SCHOOL\.lng\],\{radius:300,color:'\#FF5C8A',weight:1\.5,dashArray:'4 4',fillColor:'\#FF5C8A',fillOpacity:\.05\}\)\.addTo\(map\);\nACC\.forEach\(a=>L\.circle\(\[a\.lat,a\.lng\],\{radius:60,color:'\#ED2831',weight:2,fillColor:'\#ED2831',fillOpacity:\.12\}\)\.addTo\(map\)\.bindTooltip\(a\.y\+' '\+a\.t\+' 사고다발 · '\+a\.n\+'건'\)\);}{const DEMO=[];DEMO.push(L.circle([SCHOOL.lat,SCHOOL.lng],\{radius:300,color:'#FF5C8A',weight:1.5,dashArray:'4 4',fillColor:'#FF5C8A',fillOpacity:.05\}));ACC.forEach(a=>DEMO.push(L.circle([a.lat,a.lng],\{radius:60,color:'#ED2831',weight:2,fillColor:'#ED2831',fillOpacity:.12\})));};
$n+=s{L\.marker\(\[SCHOOL\.lat,SCHOOL\.lng\],ico\('<div class="mk school"><div class="bub">🏫 대림초<small>어린이보호구역</small></div><div class="tail"></div></div>',1000\)\)\.addTo\(map\);}{DEMO.push(L.marker([SCHOOL.lat,SCHOOL.lng],ico('<div class="mk school"><div class="bub">🏫 대림초<small>어린이보호구역</small></div><div class="tail"></div></div>',1000)));};
$n+=s{L\.marker\(\[HOME\.lat,HOME\.lng\],ico\('<div class="mk home"><div class="bub">🏠 집</div><div class="tail"></div></div>',900\)\)\.addTo\(map\);}{DEMO.push(L.marker([HOME.lat,HOME.lng],ico('<div class="mk home"><div class="bub">🏠 집</div><div class="tail"></div></div>',900)));};
$n+=s{L\.marker\(\[DOJANG\.lat,DOJANG\.lng\],ico\('<div class="mk home"><div class="bub">🥋 태권도</div><div class="tail"></div></div>',900\)\)\.addTo\(map\);}{DEMO.push(L.marker([DOJANG.lat,DOJANG.lng],ico('<div class="mk home"><div class="bub">🥋 태권도</div><div class="tail"></div></div>',900)));};
# 7) preview 시 데모 표시
$n+=s{function preview\(key\)\{cur=key;routeMode=true;useAlt=\{\};}{function preview(key)\{DEMO.forEach(x=>x.addTo(map));cur=key;routeMode=true;useAlt=\{\};};
# 8) 홈 공란: 예시 카드 제거 + 통계 숨김
$n+=s{if\(!ps\.length\)\{w\.innerHTML='<div class="favc" onclick="openSearch\(\)"><b>＋ 자주 가는 곳 저장</b><span>집·학교·학원을 저장해두면 한 번에 찾아요</span></div><div class="favc" onclick="preview\(\'home\'\)"><b>🏫 대림초 → 🏠 집</b><span>둘러보기 \(예시\)</span></div>';\}}{if(!ps.length)\{w.innerHTML='<div class="favc" onclick="openSearch()"><b>＋ 자주 가는 곳 저장</b><span>집·학교·학원을 저장해두면 한 번에 찾아요</span></div>';\}};
$n+=s{const sc=document\.getElementById\('savedChips'\);}{const st=document.querySelector('#sh-home .statrow');if(st)st.style.display=ps.length?'':'none';const sr=document.querySelector('#sh-home > .src');if(sr)sr.style.display=ps.length?'':'none';const sc=document.getElementById('savedChips');};
# 9) 분석에 시연 항목 추가
$n+=s{<div class="gi" onclick="show\('sh-report'\)}{<div class="gi" onclick="preview('home');document.querySelectorAll('.pop').forEach(x=>x.classList.add('hide'))">🎬 길 미리보기 시연</div><div class="gi" onclick="show('sh-report')};
print STDERR "subs=$n\n"; print;
