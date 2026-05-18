% Deklarasi dinamis
:- dynamic(kartu_pemain/2).
:- dynamic(discard_top/1).
:- dynamic(status_UNI/1).

% 1. mainkanKartu_mechanics(NomorUrut)
mainkanKartu_mechanics(_) :-
    \+ gameMulai, !,
    write('Game belum dimulai! Gunakan startGame.').

mainkanKartu_mechanics(NomorUrut) :-
    giliran(Pemain),
    kartu_pemain(Pemain, Hand),

    % Validasi apakah NomorUrut ada di dalam range list kartu di tangan
    length(Hand, Len),
    (NomorUrut < 1 ; NomorUrut > Len), !,
    write('Nomor urut kartu tidak valid! Coba lihatKartu lagi.').

mainkanKartu_mechanics(NomorUrut) :-
    giliran(Pemain),
    kartu_pemain(Pemain, Hand),

    % Ambil kartu dari tangan berdasarkan NomorUrut
    nth1(NomorUrut, Hand, KartuPilihan),
    KartuPilihan = kartu(Tipe, Warna, Nilai),

    % Ambil info kartu teratas di meja
    discard_top(KartuTop),
    KartuTop = kartu(_, WarnaTop, NilaiTop),

    % Validasi: Warna sama, nilai/tipe sama, atau kartu wild (warna hitam)
    (Warna == WarnaTop ; Nilai == NilaiTop ; Warna == hitam), !,

    % Eksekusi: Hapus kartu dari tangan
    hapus_elemen(NomorUrut, Hand, NewHand),
    retract(kartu_pemain(Pemain, _)),
    asserta(kartu_pemain(Pemain, NewHand)),

    % Eksekusi: Update discard pile di meja
    retract(discard_top(_)),
    asserta(discard_top(KartuPilihan)),

    format('~w memainkan kartu: ~w-~w.~n', [Pemain, Warna, Nilai]),

    % Pindah giliran ke pemain selanjutnya (belum efek skip/reverse)
    nextTurn.

% Jika kondisi di atas gagal (kartu tidak cocok)
mainkanKartu_mechanics(_) :-
    write('Kartu tidak valid! Silakan masukkan pilihan kartu kembali.').

% 2. ambilKartu_mechanics
ambilKartu_mechanics :-
    \+ gameMulai, !,
    write('Game belum dimulai! Gunakan startGame.').

ambilKartu_mechanics :-
    giliran(Pemain),
    kartu_pemain(Pemain, Hand),

    % Ambil satu kartu acak (memanggil helper)
    get_random_card(KartuBaru),

    % Tambahkan ke tangan
    append(Hand, [KartuBaru], NewHand),
    retract(kartu_pemain(Pemain, _)),
    asserta(kartu_pemain(Pemain, NewHand)),

    format('~w mendapatkan kartu baru.~n', [Pemain]),

    % Pindah giliran
    nextTurn.

% HELPER FUNCTION (membagi 7 kartu di awal + set kartu pertama di discard pile)

% Helper: Pindah giliran
nextTurn :-
    giliran(PemainSekarang),
    daftarPemain(Urutan),

    % Cari siapa pemain selanjutnya di dalam list
    next_player(PemainSekarang, Urutan, PemainSelanjutnya),

    % Update giliran
    retract(giliran(_)),
    asserta(giliran(PemainSelanjutnya)),
    nl, format('Giliran ~w.~n', [PemainSelanjutnya]).

% Mencari pemain selanjutnya (circular list)
next_player(X, List, Next) :-
    append(_, [X, Next | _], List), !.
next_player(X, List, Next) :-
    last(List, X),
    List = [Next | _], !.

% Helper: Hapus elemen berdasarkan Index
hapus_elemen(1, [_|T], T) :- !.
hapus_elemen(N, [H|T], [H|R]) :-
    N1 is N - 1,
    hapus_elemen(N1, T, R).

% Helper (sementara untuk test code): Ambil kartu acak dari deck.pl
get_random_card(kartu(Tipe, Warna, Nilai)) :-
    findall(kartu(T, W, N), kartu(T, W, N), SemuaKartu),
    random_member(kartu(Tipe, Warna, Nilai), SemuaKartu).



% Helper untuk menarik N kartu penalti secara aman dari deck.pl
tarik_kartu_penalti(N, Pemain) :-
    deck(DeckSekarang),
    playerCard(Pemain, TanganSekarang),
    ( ambilNKartu(N, DeckSekarang, KartuPenalti, DeckBaru) ->
        append(TanganSekarang, KartuPenalti, TanganBaru),
        retract(playerCard(Pemain, TanganSekarang)),
        assertz(playerCard(Pemain, TanganBaru)),
        retract(deck(DeckSekarang)),
        assertz(deck(DeckBaru))
    ;
        write('[Sistem] Deck tidak cukup untuk penalti!'), nl
    ).

% 3. uni(NomorUrutKartuDiTangan)
uni(NomorUrut) :-
    giliran(Pemain),
    playerCard(Pemain, Tangan),
    length(Tangan, L),
    
    ( L =:= 2 ->
        ambilKartuN(NomorUrut, Tangan, KartuPilihan),
        activeCard(KartuAktif),
        KartuPilihan = kartu(WarnaPilihan, JenisPilihan),
        KartuAktif = kartu(WarnaAktif, JenisAktif),
        
        ( (WarnaPilihan == WarnaAktif ; JenisPilihan == JenisAktif ; WarnaPilihan == hitam) ->
            format('~w memainkan kartu: ~w-~w.~n', [Pemain, WarnaPilihan, JenisPilihan]),
            format('~w menyerukan UNI!~n', [Pemain]),
            
            deleteKartu(NomorUrut, Tangan, TanganBaru),
            retract(playerCard(Pemain, Tangan)),
            assertz(playerCard(Pemain, TanganBaru)),
            retract(activeCard(KartuAktif)),
            assertz(activeCard(KartuPilihan)),
            
            assertz(status_UNI(Pemain)),
            
            nextPlayer(PemainBerikutnya),
            retract(giliran(Pemain)),
            assertz(giliran(PemainBerikutnya)),
            format('Giliran ~w.~n', [PemainBerikutnya])
            
        ; 
            format('Kartu tidak valid! ~w mendapatkan 1 kartu penalti.~n', [Pemain]),
            tarik_kartu_penalti(1, Pemain),
            nextPlayer(PemainBerikutnya), retract(giliran(_)), assertz(giliran(PemainBerikutnya)),
            format('Giliran ~w.~n', [PemainBerikutnya])
        )
    ; 
        format('Perintah tidak valid! ~w tidak memenuhi syarat UNI.~n', [Pemain]),
        format('~w mendapatkan 1 kartu penalti.~n', [Pemain]),
        tarik_kartu_penalti(1, Pemain),
        nextPlayer(PemainBerikutnya), retract(giliran(_)), assertz(giliran(PemainBerikutnya)),
        format('Giliran ~w.~n', [PemainBerikutnya])
    ).

% 4. tangkap(NamaPemain)
tangkap(Target) :-
    giliran(PemainAktif),
    ( PemainAktif == Target -> 
        write('Kamu tidak bisa menangkap dirimu sendiri!'), nl
    ; 
        playerCard(Target, TanganTarget),
        length(TanganTarget, L),
        
        ( (L =:= 1, \+ status_UNI(Target)) ->
            format('Tantangan berhasil! ~w tertangkap tidak menyerukan UNI.~n', [Target]),
            format('~w mendapatkan 2 kartu penalti.~n', [Target]),
            tarik_kartu_penalti(2, Target),
            
            nextPlayer(Next), retract(giliran(_)), assertz(giliran(Next)),
            format('Giliran ~w.~n', [Next])
        ;
            format('Tantangan gagal. ~w aman atau tidak melanggar aturan.~n', [Target]),
            format('~w mendapatkan 1 kartu penalti secara acak.~n', [PemainAktif]),
            tarik_kartu_penalti(1, PemainAktif)
        )
    ).

% 5. Deteksi Endgame
poin_kartu(kartu(_, J), Poin) :- integer(J), Poin = J, !.
poin_kartu(kartu(_, skip), 10) :- !.
poin_kartu(kartu(_, reverse), 10) :- !.
poin_kartu(kartu(_, drawTwo), 10) :- !.
poin_kartu(kartu(_, wild), 20) :- !.
poin_kartu(kartu(_, wildFour), 20) :- !.
poin_kartu(kartu(_, mimic), 20) :- !.
poin_kartu(_, 0).

hitung_poin([], 0).
hitung_poin([K|T], Total) :-
    poin_kartu(K, P),
    hitung_poin(T, Sub),
    Total is P + Sub.

kumpulkan_skor([], []).
kumpulkan_skor([Pemain|T], [[Poin, JmlKartu, Index, Pemain]|R]) :-
    playerCard(Pemain, Tangan),
    length(Tangan, JmlKartu),
    hitung_poin(Tangan, Poin),
    daftarPemain(Urutan),
    nth1(Index, Urutan, Pemain), 
    kumpulkan_skor(T, R).

tampil_kalkulasi_poin([]).
tampil_kalkulasi_poin([Pemain|T]) :-
    playerCard(Pemain, Tangan),
    hitung_poin(Tangan, Poin),
    ( Tangan == [] -> 
        format('~w: kartu habis = 0 poin~n', [Pemain])
    ; 
        format('~w: ~d poin~n', [Pemain, Poin])
    ),
    tampil_kalkulasi_poin(T).

tampil_pemenang([], _).
tampil_pemenang([[Poin, _, _, Pemain]|T], Peringkat) :-
    format('~d. ~w (~d poin)~n', [Peringkat, Pemain, Poin]),
    Next is Peringkat + 1,
    tampil_pemenang(T, Next).

endGame :-
    write('Permainan selesai!'), nl, nl,
    write('Berikut perhitungan poin sisa kartu:'), nl,
    daftarPemain(Urutan),
    tampil_kalkulasi_poin(Urutan),
    nl,
    
    kumpulkan_skor(Urutan, SkorBelumUrut),
    sort(SkorBelumUrut, SkorUrut), 
    
    write('Urutan pemenang:'), nl,
    tampil_pemenang(SkorUrut, 1),
    nl,
    SkorUrut = [[_, _, _, PemenangUtama] | _],
    format('Selamat, ~w menjadi pemenang!~n', [PemenangUtama]),
    retractall(gameMulai).