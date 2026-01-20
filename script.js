const gameBoard = document.getElementById('game-board');
const moveCountElement = document.getElementById('move-count');
let cards = [];
let flippedCards = [];
let moves = 0;
let matchedPairs = 0;
let isProcessing = false; // アニメーション中はクリックを無効化

// ゲームで使用するカードのペア（絵文字）
const cardValues = ['🍎', '🍌', '🍇', '🍓', '🍒', '🍑', '🍍', '🥝'];

// ゲームの初期化
function initGame() {
    gameBoard.innerHTML = '';
    moves = 0;
    matchedPairs = 0;
    moveCountElement.textContent = moves;
    flippedCards = [];
    isProcessing = false;

    // ペアを作ってシャッフル
    const deck = [...cardValues, ...cardValues];
    shuffle(deck);

    // カードを生成して配置
    deck.forEach(value => {
        const card = document.createElement('div');
        card.classList.add('card');
        card.dataset.value = value;
        card.textContent = value; // 答えを持たせておく（CSSで隠す）
        card.addEventListener('click', onCardClick);
        gameBoard.appendChild(card);
    });
}

// 配列をシャッフルする関数 (Fisher-Yates shuffle)
function shuffle(array) {
    for (let i = array.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [array[i], array[j]] = [array[j], array[i]];
    }
}

// カードクリック時の処理
function onCardClick(e) {
    const clickedCard = e.target;

    // 無視する条件: 処理中、既にめくられている、マッチ済み
    if (isProcessing || 
        clickedCard.classList.contains('flipped') || 
        clickedCard.classList.contains('matched')) {
        return;
    }

    // カードをめくる
    flipCard(clickedCard);
    flippedCards.push(clickedCard);

    // 2枚めくった場合の判定
    if (flippedCards.length === 2) {
        moves++;
        moveCountElement.textContent = moves;
        checkForMatch();
    }
}

function flipCard(card) {
    card.classList.add('flipped');
}

function unflipCard(card) {
    card.classList.remove('flipped');
}

function checkForMatch() {
    isProcessing = true;
    const [card1, card2] = flippedCards;

    if (card1.dataset.value === card2.dataset.value) {
        // マッチした場合
        card1.classList.add('matched');
        card2.classList.add('matched');
        matchedPairs++;
        resetTurn();

        // 全ペア揃ったか確認
        if (matchedPairs === cardValues.length) {
            setTimeout(() => alert(`クリア！ 手数: ${moves}`), 500);
        }
    } else {
        // マッチしなかった場合
        setTimeout(() => {
            unflipCard(card1);
            unflipCard(card2);
            resetTurn();
        }, 1000); // 1秒待ってから戻す
    }
}

function resetTurn() {
    flippedCards = [];
    isProcessing = false;
}

// ゲーム開始
initGame();
