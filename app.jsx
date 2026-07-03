const { useState, useEffect, useRef, useCallback } = React;
const { Button, Modal, Input, Radio, Alert, Space, ConfigProvider, message, ColorPicker } = antd;

const firebaseConfig = { apiKey: "AIzaSyCCw9vbQuF9CJzyvhfy__UDIGq9SQO0KA8", authDomain: "thinking-sns.firebaseapp.com", projectId: "thinking-sns", storageBucket: "thinking-sns.firebasestorage.app", messagingSenderId: "133464509665", appId: "1:133464509665:web:c0b8769832c1d56ef9bba0", measurementId: "G-WZCMJ4R2TF" };
firebase.initializeApp(firebaseConfig);
const db = firebase.firestore();
const auth = firebase.auth();
const googleProvider = new firebase.auth.GoogleAuthProvider();
const REACTIONS = ['❤️', '👏', '🤔', '🤝', '✅'];
const POST_DOC_REF = db.collection('post-1').doc('wsbxPa2kQDaexLV9hiVC');

function formatDate(timestamp) {
  if (!timestamp) return '';
  const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
  const y = date.getFullYear();
  const mo = String(date.getMonth() + 1).padStart(2, '0');
  const d = String(date.getDate()).padStart(2, '0');
  const h = String(date.getHours()).padStart(2, '0');
  const mi = String(date.getMinutes()).padStart(2, '0');
  const s = String(date.getSeconds()).padStart(2, '0');
  const offset = -date.getTimezoneOffset();
  const sign = offset >= 0 ? '+' : '-';
  const oh = String(Math.floor(Math.abs(offset) / 60)).padStart(2, '0');
  const om = String(Math.abs(offset) % 60).padStart(2, '0');
  return `${y}年${mo}月${d}日 ${h}:${mi}:${s} UTC${sign}${oh}:${om}`;
}

function PostDetail({ postId, data, open, onClose, onRefresh }) {
  const [replyText, setReplyText] = useState('');
  const [replies, setReplies] = useState([]);
  const [clickedReactions, setClickedReactions] = useState(() => {
    try { return JSON.parse(localStorage.getItem('reactions_' + postId) || '[]'); } catch { return []; }
  });

  const loadReplies = async () => {
    const snap = await POST_DOC_REF.collection('maintext').doc(postId).get();
    if (snap.exists) {
      const repliesData = snap.data().replies || {};
      setReplies(Object.entries(repliesData).map(([id, r]) => ({ id, ...r })));
    }
  };

  useEffect(() => { if (open) loadReplies(); }, [open]);

  const handleReaction = async (reaction) => {
    const docRef = POST_DOC_REF.collection('maintext').doc(postId);
    const snap = await docRef.get();
    if (snap.exists) {
      const reactions = snap.data().reactions || {};
      const isClicked = clickedReactions.includes(reaction);
      if (isClicked) {
        reactions[reaction] = Math.max(0, (reactions[reaction] || 1) - 1);
        const next = clickedReactions.filter(r => r !== reaction);
        setClickedReactions(next);
        localStorage.setItem('reactions_' + postId, JSON.stringify(next));
      } else {
        reactions[reaction] = (reactions[reaction] || 0) + 1;
        const next = [...clickedReactions, reaction];
        setClickedReactions(next);
        localStorage.setItem('reactions_' + postId, JSON.stringify(next));
      }
      await docRef.update({ reactions });
      onRefresh();
    }
  };

  const handleReplySubmit = async () => {
    if (!replyText.trim()) return;
    const docRef = POST_DOC_REF.collection('maintext').doc(postId);
    const snap = await docRef.get();
    if (snap.exists) {
      const repliesData = snap.data().replies || {};
      const replyId = Math.random().toString(36).substring(2, 15);
      repliesData[replyId] = { text: replyText, createdAt: firebase.firestore.FieldValue.serverTimestamp() };
      await docRef.update({ replies: repliesData });
      setReplyText('');
      loadReplies();
      onRefresh();
    }
  };

  return (
    <Modal open={open} onCancel={onClose} footer={null} width="90vw" styles={{ body: { height: 'calc(100vh - 120px)', display: 'flex', flexDirection: 'column', padding: 0, background: '#fff' }, content: { borderRadius: 16 } }}>
      <div style={{ display: 'flex', alignItems: 'center', padding: '16px 20px', borderBottom: '1px solid rgba(0,0,0,0.06)' }}>
        <Button type="text" onClick={onClose} style={{ marginRight: 12, fontSize: 18 }}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M19 12H5"/><path d="M12 19l-7-7 7-7"/></svg>
        </Button>
        <span style={{ fontSize: 16, fontWeight: 600 }}>投稿</span>
      </div>
      <div style={{ flex: 1, overflow: 'auto', padding: '16px 20px', paddingBottom: 80 }}>
        <div style={{ padding: 16, background: data.bg || '#fff', color: data.color || '#000', borderRadius: 24, marginBottom: 16 }}>
          {data.username && <div style={{ fontSize: 14, fontWeight: 600, marginBottom: 6 }}>{data.username}</div>}
          <div style={{ fontSize: 16, lineHeight: 1.6 }}>{data.delay ? (data.text || 'テキストなし') : (data.text || 'テキストなし')}</div>
          <div style={{ fontSize: 12, color: data.color || '#000', opacity: 0.5, marginTop: 8 }}>{formatDate(data.createdAt)}</div>
          <div style={{ marginTop: 8, display: 'flex', flexWrap: 'wrap', gap: 4 }}>
            {REACTIONS.map(r => {
              const isClicked = clickedReactions.includes(r);
              return (
                <button key={r} onClick={() => handleReaction(r)} style={{ padding: '4px 10px', border: isClicked ? 'none' : '1px solid ' + (data.bg || '#fff'), borderRadius: 999, background: isClicked ? (data.color || '#000') + 'dd' : 'transparent', color: isClicked ? (data.bg || '#fff') : (data.color || '#000'), cursor: 'pointer', fontSize: 13 }}>
                  {r} {(data.reactions?.[r] || 0)}
                </button>
              );
            })}
          </div>
        </div>
        {replies.length > 0 ? replies.map(r => (
          <div key={r.id} style={{ padding: 14, marginBottom: 8, background: '#fafafa', borderRadius: 14 }}>
            <div style={{ fontSize: 15, lineHeight: 1.5 }}>{r.text}</div>
            <div style={{ fontSize: 12, color: 'rgba(0,0,0,0.25)', marginTop: 6 }}>{formatDate(r.createdAt)}</div>
          </div>
        )) : <div style={{ textAlign: 'center', color: 'rgba(0,0,0,0.25)', padding: 40 }}>まだ返信がありません</div>}
      </div>
      <div style={{ position: 'absolute', bottom: 0, left: 0, right: 0, padding: 12, background: '#fff', borderTop: '1px solid rgba(0,0,0,0.06)', display: 'flex', gap: 8 }}>
        <Input value={replyText} onChange={e => setReplyText(e.target.value)} placeholder="返信を入力..." style={{ borderRadius: 24 }} onPressEnter={handleReplySubmit} />
        <Button onClick={handleReplySubmit}>送信</Button>
      </div>
    </Modal>
  );
}

function PostBox({ data, postId, onRefresh, onOpen }) {
  const [displayedText, setDisplayedText] = useState(data.delay ? '▮' : (data.text || 'テキストなし'));
  const [expanded, setExpanded] = useState(false);
  const timerRef = useRef(null);
  const [clickedReactions, setClickedReactions] = useState(() => {
    try { return JSON.parse(localStorage.getItem('reactions_' + postId) || '[]'); } catch { return []; }
  });

  useEffect(() => {
    if (data.delay && data.createdAt) {
      const startTime = data.createdAt.toDate ? data.createdAt.toDate().getTime() : new Date(data.createdAt).getTime();
      function tick() {
        const elapsed = (Date.now() - startTime) / 1000;
        const chars = Math.floor(elapsed / 20);
        if (chars >= (data.text || '').length) {
          setDisplayedText(data.text || 'テキストなし');
        } else {
          setDisplayedText((data.text || '').substring(0, chars) + '▮');
          timerRef.current = requestAnimationFrame(tick);
        }
      }
      timerRef.current = requestAnimationFrame(tick);
      return () => cancelAnimationFrame(timerRef.current);
    }
  }, [data]);

  const handleReaction = async (e, reaction) => {
    e.stopPropagation();
    const docRef = POST_DOC_REF.collection('maintext').doc(postId);
    const snap = await docRef.get();
    if (snap.exists) {
      const reactions = snap.data().reactions || {};
      const isClicked = clickedReactions.includes(reaction);
      if (isClicked) {
        reactions[reaction] = Math.max(0, (reactions[reaction] || 1) - 1);
        const next = clickedReactions.filter(r => r !== reaction);
        setClickedReactions(next);
        localStorage.setItem('reactions_' + postId, JSON.stringify(next));
      } else {
        reactions[reaction] = (reactions[reaction] || 0) + 1;
        const next = [...clickedReactions, reaction];
        setClickedReactions(next);
        localStorage.setItem('reactions_' + postId, JSON.stringify(next));
      }
      await docRef.update({ reactions });
      onRefresh();
    }
  };

  const lines = displayedText.split('\n').length;
  const isLong = lines >= 8 && !expanded;

  return (
    <div onClick={() => onOpen(postId, data)} style={{ padding: 16, marginBottom: 12, background: data.bg || '#fff', color: data.color || '#000', borderRadius: 24, boxShadow: '0 1px 2px rgba(0,0,0,0.06)', cursor: 'pointer' }}>
      {data.username && <div style={{ fontSize: 13, fontWeight: 600, marginBottom: 4 }}>{data.username}</div>}
      <div style={{ fontSize: 15, lineHeight: 1.6, whiteSpace: 'pre-wrap', overflow: 'hidden', maxHeight: isLong ? 'calc(1.6em * 8)' : 'none' }}>{displayedText}</div>
      {isLong && <div style={{ fontSize: 13, color: data.color || '#000', opacity: 0.5, marginTop: 4 }} onClick={e => { e.stopPropagation(); setExpanded(true); }}>...続きを見る</div>}
      <div style={{ fontSize: 12, color: data.color || '#000', opacity: 0.5, marginTop: 4 }}>{formatDate(data.createdAt)}</div>
      <div style={{ marginTop: 8, display: 'flex', flexWrap: 'wrap', gap: 4 }} onClick={e => e.stopPropagation()}>
        {REACTIONS.map(r => {
          const isClicked = clickedReactions.includes(r);
          return (
            <button key={r} onClick={(e) => handleReaction(e, r)} style={{ padding: '4px 10px', border: isClicked ? 'none' : '1px solid ' + (data.bg || '#fff'), borderRadius: 999, background: isClicked ? (data.color || '#000') + 'dd' : 'transparent', color: isClicked ? (data.bg || '#fff') : (data.color || '#000'), cursor: 'pointer', fontSize: 13 }}>
              {r} {(data.reactions?.[r] || 0)}
            </button>
          );
        })}
      </div>
    </div>
  );
}

function MiniPostBox({ data }) {
  return (
    <div style={{ display: 'inline-block', padding: 16, marginRight: 12, background: data.bg || '#fff', color: data.color || '#000', borderRadius: 24, boxShadow: '0 1px 2px rgba(0,0,0,0.06)', fontSize: 24, fontWeight: 500 }}>
      {data.text}
    </div>
  );
}

function App() {
  const [user, setUser] = useState(null);
  const [posts, setPosts] = useState([]);
  const [miniPosts, setMiniPosts] = useState([]);
  const [loading, setLoading] = useState(false);
  const [postOpen, setPostOpen] = useState(false);
  const [guideOpen, setGuideOpen] = useState(false);
  const [detailOpen, setDetailOpen] = useState(false);
  const [detailPost, setDetailPost] = useState(null);
  const [detailId, setDetailId] = useState(null);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [dialogTitle, setDialogTitle] = useState('');
  const [dialogContent, setDialogContent] = useState('');
  const [username, setUsername] = useState('');
  const [text, setText] = useState('');
  const [textType, setTextType] = useState('default');
  const [bg, setBg] = useState('#ffffff');
  const [color, setColor] = useState('#000000');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [refreshKey, setRefreshKey] = useState(0);
  const isLoadingRef = useRef(false);
  const lastVisibleRef = useRef(null);

  const showDialog = (title, content) => {
    setDialogTitle(title);
    setDialogContent(content);
    setDialogOpen(true);
  };

  useEffect(() => {
    const unsub = auth.onAuthStateChanged(async u => {
      setUser(u);
      if (u) {
        const snap = await db.collection('users').doc(u.uid).get();
        if (snap.exists && snap.data().username) {
          setUsername(snap.data().username);
        } else {
          setUsername(u.displayName || u.email || '匿名');
        }
      } else {
        setUsername('');
      }
    });
    return unsub;
  }, []);

  const loadPosts = useCallback(async (loadMore = false) => {
    if (isLoadingRef.current) return;
    isLoadingRef.current = true;
    setLoading(true);
    try {
      let q = POST_DOC_REF.collection('maintext').orderBy('createdAt', 'desc').limit(7);
      if (loadMore && lastVisibleRef.current) q = q.startAfter(lastVisibleRef.current);
      const snap = await q.get();
      const newPosts = snap.docs.map(d => ({ id: d.id, ...d.data() }));
      if (loadMore) {
        setPosts(prev => [...prev, ...newPosts]);
      } else {
        setPosts(newPosts);
      }
      lastVisibleRef.current = snap.docs[snap.docs.length - 1] || null;
    } catch (e) {
      showDialog('データ取得エラー', '投稿を取得できませんでした。');
    } finally {
      isLoadingRef.current = false;
      setLoading(false);
    }
  }, []);

  const loadMiniPosts = useCallback(async () => {
    try {
      const snap = await POST_DOC_REF.collection('minitext').orderBy('createdAt', 'desc').limit(13).get();
      setMiniPosts(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    } catch (e) {
      console.error('ミニ投稿取得エラー:', e);
    }
  }, []);

  useEffect(() => {
    loadPosts();
    loadMiniPosts();
  }, [refreshKey]);

  const handleRefresh = () => setRefreshKey(k => k + 1);

  const signInWithGoogle = async () => {
    try {
      const result = await auth.signInWithPopup(googleProvider);
      showDialog('ログイン成功!', `${result.user.displayName}さん、ようこそ!`);
    } catch (e) {
      showDialog('ログインエラー', 'ログインに失敗しました。');
    }
  };

  const signInWithEmail = async () => {
    try {
      const result = await auth.signInWithEmailAndPassword(email, password);
      showDialog('ログイン成功!', `${result.user.email}でログインしました。`);
    } catch (e) {
      showDialog('ログインエラー', 'メールアドレスまたはパスワードが正しくありません。');
    }
  };

  const registerWithEmail = async () => {
    try {
      const result = await auth.createUserWithEmailAndPassword(email, password);
      showDialog('登録成功!', `${result.user.email}で新規登録されました。`);
    } catch (e) {
      showDialog('登録エラー', 'ユーザー登録に失敗しました。');
    }
  };

  const submitPost = async () => {
    if (!text) { showDialog('すっからかん!', 'テキストを入力しましょう'); return; }
    if (textType === 'mini' && text.length !== 3) { showDialog('3文字で!', 'ミニ投稿では3文字しか投稿できません。'); return; }
    try {
      const colName = textType === 'mini' ? 'minitext' : 'maintext';
      await POST_DOC_REF.collection(colName).doc().set({
        text, bg, color,
        username: username || '匿名',
        createdAt: firebase.firestore.FieldValue.serverTimestamp(),
        reactions: {}, replies: {},
        delay: textType === 'delay'
      });
      setText('');
      setBg('#ffffff');
      setColor('#000000');
      setPostOpen(false);
      showDialog('完了!', '投稿が完了しました!');
      lastVisibleRef.current = null;
      handleRefresh();
    } catch (e) {
      showDialog('投稿エラー', '投稿できませんでした。');
    }
  };

  return (
    <ConfigProvider theme={{ token: { colorPrimary: '#000', borderRadius: 10, fontFamily: '"HarmonyOS Sans SC", -apple-system, BlinkMacSystemFont, sans-serif', padding: 18, paddingSM: 24, paddingLG: 24 } }}>
      <div style={{ padding: 24, minHeight: '100vh', background: '#f5f5f5' }}>
        <h1 style={{ fontSize: 26, fontWeight: 600, lineHeight: '36px', marginBottom: 32 }}>thinkSocial</h1>
        <Space style={{ marginBottom: 32 }}>
          <Button onClick={() => setGuideOpen(true)}>ご利用時の注意事項</Button>
          <Button href="https://thinking-grp.github.io/">thinking 公式</Button>
        </Space>

        {!user ? (
          <div style={{ marginBottom: 16, padding: 20, background: '#fff', borderRadius: 24, boxShadow: '0 1px 2px rgba(0,0,0,0.06)' }}>
            <div style={{ marginBottom: 12, fontSize: 15, color: 'rgba(0,0,0,0.65)' }}>ログインすると投稿やリアクションができます</div>
            <Button onClick={signInWithGoogle}>Googleでログイン</Button>
          </div>
        ) : (
          <div style={{ marginBottom: 16 }}>
            <Space>
              <span>ようこそ、{username}さん</span>
              <Button onClick={() => auth.signOut()}>ログアウト</Button>
            </Space>
          </div>
        )}

        <div style={{ overflowX: 'auto', whiteSpace: 'nowrap', marginBottom: 16, paddingBottom: 8 }}>
          {miniPosts.map(p => <MiniPostBox key={p.id} data={p} />)}
        </div>
        {posts.map(p => <PostBox key={p.id} postId={p.id} data={p} onRefresh={handleRefresh} onOpen={(id, data) => { setDetailId(id); setDetailPost(data); setDetailOpen(true); }} />)}
        <Button block style={{ marginTop: 16 }} onClick={() => loadPosts(true)} loading={loading}>
          もっと読み込む
        </Button>

        <button onClick={() => setPostOpen(true)} style={{ position: 'fixed', bottom: 32, right: 32, zIndex: 1000, height: 48, borderRadius: 24, border: '1px solid rgba(0,0,0,0.08)', background: '#fff', boxShadow: '0 4px 12px rgba(0,0,0,0.08)', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 8, padding: '0 20px', fontSize: 15, fontWeight: 500, color: 'rgba(0,0,0,0.85)' }}>
          <span style={{ fontSize: 20 }}>+</span> 新規投稿
        </button>

        <Modal title="新規投稿" open={postOpen} onCancel={() => setPostOpen(false)} onOk={submitPost} okText="投稿" cancelText="キャンセル">
          <Input.TextArea value={text} onChange={e => setText(e.target.value)} placeholder="テキストを入力" rows={5} style={{ marginBottom: 12 }} />
          <Radio.Group value={textType} onChange={e => setTextType(e.target.value)} style={{ marginBottom: 12 }}>
            <Radio.Button value="default">通常テキスト</Radio.Button>
            <Radio.Button value="mini">ミニ投稿</Radio.Button>
            <Radio.Button value="delay">ディレイド投稿</Radio.Button>
          </Radio.Group>
          <Space>
            <span>背景: <ColorPicker value={bg} onChange={(v, hex) => setBg(hex)} size="small" /></span>
            <span>文字: <ColorPicker value={color} onChange={(v, hex) => setColor(hex)} size="small" /></span>
          </Space>
        </Modal>

        <Modal title="ご利用時の注意事項" open={guideOpen} onCancel={() => setGuideOpen(false)} footer={<Button type="primary" onClick={() => setGuideOpen(false)}>完了</Button>}>
          <p>投稿削除について<br/>投稿は容量管理のため、予告なく削除されることがあります。予めご了承ください。</p>
          <p>個人情報の保護<br/>個人情報（氏名、住所、連絡先など）は、絶対に投稿しないでください。</p>
          <p>投稿頻度について<br/>サービスの維持に影響を及ぼす可能性があるため、高すぎる頻度での読み込み・リアクションはご遠慮ください。</p>
          <p>運営について<br/>私たちは利益がないグループで運営しています。そのため、様々な制限の都合により予告なくサービスを一時停止する場合があります。</p>
          <p>バグや不具合の報告<br/>バグや不具合を発見した場合は、投稿を通じてお知らせいただけると助かります。</p>
        </Modal>

        <Modal title={dialogTitle} open={dialogOpen} onCancel={() => setDialogOpen(false)} footer={<Button type="primary" onClick={() => setDialogOpen(false)}>OK</Button>}>
          {dialogContent}
        </Modal>

        <div style={{ height: 80 }}></div>
      </div>

      {detailPost && <PostDetail postId={detailId} data={detailPost} open={detailOpen} onClose={() => setDetailOpen(false)} onRefresh={handleRefresh} />}
    </ConfigProvider>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
