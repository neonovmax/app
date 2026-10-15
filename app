<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ТанцТеатр - Управление Сценой</title>
    <!-- Подключаем стили, чтобы всё выглядело красиво и современно -->
    <script src="https://jsdelivr.net"></script>
    <link rel="stylesheet" href="https://jsdelivr.net">
    <!-- Подключаем библиотеку для мгновенной связи между устройствами -->
    <script src="https://cloudflare.com"></script>
</head>
<body class="bg-gray-900 text-gray-100 font-sans">

    <!-- Шапка приложения -->
    <header class="bg-gray-800 p-4 text-center border-b border-gray-700 shadow-md">
        <h1 class="text-xl font-bold tracking-wide text-emerald-400">📲 ТАНЦТЕАТР: ПУЛЬТ</h1>
        <div class="flex justify-center gap-2 mt-3">
            <button onclick="switchRole('backstage')" id="btn-backstage" class="px-3 py-1.5 rounded-lg text-xs font-bold uppercase transition bg-emerald-600 text-white">Закулисье</button>
            <button onclick="switchRole('booth')" id="btn-booth" class="px-3 py-1.5 rounded-lg text-xs font-bold uppercase transition bg-gray-700 text-gray-400">Рубка (Педагог)</button>
            <button onclick="switchRole('schedule')" id="btn-schedule" class="px-3 py-1.5 rounded-lg text-xs font-bold uppercase transition bg-gray-700 text-gray-400">Расписание</button>
        </div>
    </header>

    <main class="max-w-md mx-auto p-4 min-h-[calc(100vh-120px)] flex flex-col justify-between">
        
        <!-- ЭКРАН 1: ЗАКУЛИСЬЕ -->
        <section id="role-backstage" class="space-y-6">
            <div class="bg-gray-800 p-4 rounded-xl border border-gray-700">
                <h2 class="text-lg font-bold mb-3 text-gray-300">📋 Чек-лист готовности:</h2>
                <div class="space-y-3">
                    <label class="flex items-center gap-3 p-2 bg-gray-750 rounded-lg cursor-pointer"><input type="checkbox" class="w-5 h-5 rounded accent-emerald-500"> <span>Артисты переоделись</span></label>
                    <label class="flex items-center gap-3 p-2 bg-gray-750 rounded-lg cursor-pointer"><input type="checkbox" class="w-5 h-5 rounded accent-emerald-500"> <span>Реквизит на местах</span></label>
                    <label class="flex items-center gap-3 p-2 bg-gray-750 rounded-lg cursor-pointer"><input type="checkbox" class="w-5 h-5 rounded accent-emerald-500"> <span>Старший на связи</span></label>
                </div>
            </div>
            <button onclick="sendSignal('ГОТОВЫ')" class="w-full py-8 bg-emerald-500 hover:bg-emerald-600 text-white text-2xl font-black rounded-2xl shadow-lg active:scale-95 transition transform uppercase tracking-wider">
                🟢 КУЛИСЫ ГОТОВЫ!
            </button>
            <button onclick="sendSignal('СТОП')" class="w-full py-3 bg-red-600 hover:bg-red-700 text-white text-sm font-bold rounded-xl transition uppercase">
                🚨 СТОП / НЕ ГОТОВЫ
            </button>
        </section>

        <!-- ЭКРАН 2: РУБКА (ПЕДАГОГ) -->
        <section id="role-booth" class="hidden flex-1 flex flex-col items-center justify-center space-y-6">
            <div id="status-card" class="w-full p-8 rounded-2xl border text-center transition-all duration-300 bg-gray-850 border-gray-700">
                <p class="text-sm uppercase tracking-widest text-gray-400">Статус сцены</p>
                <h2 id="status-text" class="text-4xl font-black mt-2 text-yellow-500 animate-pulse">ОЖИДАНИЕ...</h2>
            </div>
            <p class="text-xs text-gray-500 text-center">Сигнал от кулис прилетит сюда мгновенно без перезагрузки экрана.</p>
        </section>

        <!-- ЭКРАН 3: РАСПИСАНИЕ -->
        <section id="role-schedule" class="hidden space-y-4">
            <div class="bg-gray-800 p-4 rounded-xl border border-gray-700">
                <h3 class="font-bold text-emerald-400 text-sm mb-1">Сегодня, 19:00</h3>
                <p class="text-lg font-semibold">Генеральный прогон спектакля</p>
                <p class="text-xs text-gray-400 mt-1">📍 Главная сцена</p>
            </div>
            <div class="bg-gray-800 p-4 rounded-xl border border-gray-700 opacity-60">
                <h3 class="font-bold text-gray-400 text-sm mb-1">Завтра, 15:00</h3>
                <p class="text-lg font-semibold">Классический станок и растяжка</p>
                <p class="text-xs text-gray-400 mt-1">📍 Малый зал</p>
            </div>
        </section>

    </main>

    <script>
        // Настройка бесплатного realtime-канала (работает без VPN в РФ)
        const pubnub = new PubNub({
            publishKey: 'pub-c-69f8c62c-8800-47da-9923-a1789c6d3284', // Демо-ключи (полностью бесплатные)
            subscribeKey: 'sub-c-0fa7ea3d-88b9-4a7b-a3be-ba89df9cc298',
            userId: "theater-device-" + Math.random()
        });

        pubnub.subscribe({ channels: ['dance-stage-channel'] });

        pubnub.addListener({
            message: function(event) {
                const status = event.message.status;
                updateBoothStatus(status);
            }
        });

        function sendSignal(status) {
            pubnub.publish({
                channel: 'dance-stage-channel',
                message: { status: status }
            });
        }

        function updateBoothStatus(status) {
            const card = document.getElementById('status-card');
            const text = document.getElementById('status-text');
            
            if (status === 'ГОТОВЫ') {
                card.className = "w-full p-8 rounded-2xl border text-center transition-all duration-300 bg-emerald-950 border-emerald-500 shadow-[0_0_30px_rgba(16,185,129,0.3)]";
                text.className = "text-4xl font-black mt-2 text-emerald-400 animate-bounce";
                text.innerText = "🟢 ГОТОВЫ!";
            } else {
                card.className = "w-full p-8 rounded-2xl border text-center transition-all duration-300 bg-red-950 border-red-500";
                text.className = "text-4xl font-black mt-2 text-red-500";
                text.innerText = "🚨 СТОП!";
            }
        }

        function switchRole(role) {
            ['backstage', 'booth', 'schedule'].forEach(r => {
                document.getElementById('role-' + r).classList.add('hidden');
                document.getElementById('btn-' + r).className = "px-3 py-1.5 rounded-lg text-xs font-bold uppercase transition bg-gray-700 text-gray-400";
            });
            document.getElementById('role-' + role).classList.remove('hidden');
            document.getElementById('btn-' + role).className = "px-3 py-1.5 rounded-lg text-xs font-bold uppercase transition bg-emerald-600 text-white";
        }
    </script>
</body>
</html>
