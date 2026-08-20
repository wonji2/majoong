local $/; $_ = <STDIN>;

# 1) SDK에 services 라이브러리
s{sdk\.js\?appkey=860978723be1a27dd6613aa69395b2ad}{sdk.js?appkey=860978723be1a27dd6613aa69395b2ad&libraries=services};

# 2) 스플래시 통삭제
s{ <div class="splash" id="splash">.*?</div>\n\n <div class="top">}{ <div class="top">}s;

# 3) 온보딩 시트 통삭제
s{ <!-- v7 온보딩: 그늘로처럼 첫 실행에 장소·걸음 저장 -->\n <div class="sheet hide" id="sh-onb">.*?</div>\n\n <!-- 홈: 자주 가는 길 -->}{ <!-- 홈: 자주 가는 길 -->}s;

# 4) 홈 시트: 저장 장소 카드 동적
s{  <div class="eyebrow">초1이 혼자 건너는 길 · 자주 가는 길</div>\n  <h2>어디로 갈까요\?</h2>\n  <div class="fav">.*?</div>\n  <div class="statrow">}{  <div class="eyebrow">자주 가는 길</div>\n  <h2>어디로 갈까요?</h2>\n  <div class="fav" id="favWrap"></div>\n  <div class="statrow">}s;

# 5) 검색 시트: 심플 (출발칸 제거, 칩 동적)
s{  <div class="eyebrow">길 찾기</div>\n  <h2>어디에서 어디로 가요\?</h2>\n  <div class="inp"><span class="dot" style="background:var\(--green\)"></span><input id="inFrom" value="서울대림초등학교 \(현재 위치\)" readonly></div>\n  <div class="inp"><span class="dot" style="background:var\(--brand\)"></span><input id="inTo" placeholder="도착지 주소·장소 입력" oninput="searchSuggest\(this\.value\)" autocomplete="off"></div>\n  <div class="chips">.*?</div>\n  <div id="sugList"></div>\n  <div class="src">자주 가는 곳은 저장해두면 한 번에 찾아요\.</div>}{  <div class="eyebrow">마중길</div>\n  <h2>어디로 가요?</h2>\n  <div class="inp"><span>🔍</span><input id="inTo" placeholder="장소·주소 검색 (예: 대림초, 우리 집 주소)" oninput="searchSuggest(this.value)" autocomplete="off"></div>\n  <div class="chips" id="savedChips"></div>\n  <div id="sugList"></div>}s;

# 6) sheets 목록에서 sh-onb 제거
s{const sheets=\['sh-onb','sh-search',}{const sheets=['sh-search',};

# 7) finishOnb/onbSpeed/SUG/openSearch/searchSuggest/pickDest 교체
s{function finishOnb\(\).*?\nonbSpeed\.querySelectorAll.*?\n}{}s;
s{/\* 주소 검색 \(예시: 실주소 일부\) \*/\nconst SUG=.*?\nfunction openSearch.*?\nfunction searchSuggest.*?\nfunction pickDest.*?\n}{
/* ── 카카오 로컬 실검색 + 장소 저장 ── */
const PLACES_KEY='mj_places';
const loadPlaces=()=>{try{return JSON.parse(localStorage.getItem(PLACES_KEY)||'[]')}catch(e){return[]}};
const KP=new kakao.maps.services.Places();
let searchT=null,RES=[],SEL=null,placeMarkers=[];
function openSearch(){if(routeMode)return;show('sh-search');searchSuggest(document.getElementById('inTo').value||'');setTimeout(()=>document.getElementById('inTo').focus(),100);}
function searchSuggest(q){clearTimeout(searchT);if(!q||q.length<2){sugList.innerHTML='<div class="src" style="margin-top:8px">두 글자 이상 입력하면 검색돼요</div>';return;}
 searchT=setTimeout(()=>{KP.keywordSearch(q,(data,status)=>{if(status!==kakao.maps.services.Status.OK){sugList.innerHTML='<div class="src" style="margin-top:8px">검색 결과가 없어요</div>';return;}
  RES=data.slice(0,7);sugList.innerHTML=RES.map((d,i)=>'<div class="sug" onclick="chooseRes('+i+')">📍 '+d.place_name+'<small>'+(d.road_address_name||d.address_name||'')+'</small></div>').join('');});},350);}
function chooseRes(i){SEL=RES[i];map.setView([+SEL.y,+SEL.x],17);
 sugList.innerHTML='<div class="sug" style="border:0">📍 <b>'+SEL.place_name+'</b><small>'+(SEL.road_address_name||SEL.address_name||'')+'</small></div>'
 +'<div class="src" style="margin:6px 0 4px">어떤 곳이에요?</div><div class="chips">'
 +['🏠 집','🏫 학교','📚 학원','👵 할머니집','⭐ 자주 가요'].map(l=>'<span class="chip ok" onclick="savePlace(\x27'+l+'\x27)" style="padding:8px 13px;font-size:13px">'+l+'</span>').join('')
 +'<span class="chip" onclick="goPlaceTemp()" style="padding:8px 13px;font-size:13px">저장 없이 바로 가기</span></div>';}
function savePlace(label){if(!SEL)return;const ps=loadPlaces();ps.push({label:label,name:SEL.place_name,lat:+SEL.y,lng:+SEL.x});localStorage.setItem(PLACES_KEY,JSON.stringify(ps));toast(label+' 저장!');document.getElementById('inTo').value='';renderPlaces();show('sh-home');}
function goPlaceTemp(){if(!SEL)return;map.setView([+SEL.y,+SEL.x],17);show('sh-home');toast('📍 '+SEL.place_name);}
function delPlace(i){const ps=loadPlaces();ps.splice(i,1);localStorage.setItem(PLACES_KEY,JSON.stringify(ps));renderPlaces();}
function goPlace(i){const p=loadPlaces()[i];if(!p)return;
 if(p.label.includes('집')&&dist({lat:p.lat,lng:p.lng},SCHOOL)<1500){preview('home');return;}
 if(p.label.includes('학원')&&dist({lat:p.lat,lng:p.lng},SCHOOL)<1500){preview('dojang');return;}
 map.setView([p.lat,p.lng],17);toast(p.label+' '+p.name);}
function renderPlaces(){const ps=loadPlaces();
 placeMarkers.forEach(m=>m.remove());placeMarkers=ps.map(p=>L.marker([p.lat,p.lng],ico('<div class="mk home"><div class="bub">'+p.label.split(' ')[0]+' '+p.name.slice(0,8)+'</div><div class="tail"></div></div>',850)).addTo(map));
 const w=document.getElementById('favWrap');
 if(!ps.length){w.innerHTML='<div class="favc" onclick="openSearch()"><b>＋ 자주 가는 곳 저장</b><span>집·학교·학원을 저장해두면 한 번에 찾아요</span></div><div class="favc" onclick="preview(\x27home\x27)"><b>🏫 대림초 → 🏠 집</b><span>둘러보기 (예시)</span></div>';}
 else{w.innerHTML=ps.map((p,i)=>'<div class="favc" onclick="goPlace('+i+')" oncontextmenu="event.preventDefault();delPlace('+i+')"><b>'+p.label.split(' ')[0]+' '+p.name.slice(0,10)+'</b><span>'+p.label+'</span></div>').join('')+'<div class="favc add" onclick="openSearch()">＋</div>';}
 const sc=document.getElementById('savedChips');if(sc)sc.innerHTML=ps.map((p,i)=>'<span class="chip ok" onclick="goPlace('+i+');show(\x27sh-home\x27)">'+p.label.split(' ')[0]+' '+p.name.slice(0,8)+'</span>').join('');}
renderPlaces();
show(loadPlaces().length?'sh-home':'sh-search');
}s;
print;
